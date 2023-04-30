import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/model/market_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/ffi_wallet_service.dart';
import 'package:mobile_wallet/service/grpc_service.dart';
import 'package:mobile_wallet/service/market_service.dart';
import 'package:mobile_wallet/service/secured_storage_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/shared_preference_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart' as foundation;

class NotificationService {
  static const _priceNotificationTaskName = "priceNotificationTask";
  static const _transactionNotificationTaskName = "transactionNotificationTask";

  static void initNotifications() async {
    Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );
    if (Platform.isIOS) {
      SettingsService settingsService = getIt<SettingsService>();
      AppSettings appSettings = await settingsService.getAppSettings();
      if (appSettings.useTransactionNotification) {
        NotificationService().scheduleTransactionNotification();
      }
      if (appSettings.usePriceNotification) {
        NotificationService().schedulePriceNotification();
      }
    }
  }

  void schedulePriceNotification() {
    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(
        _priceNotificationTaskName,
        _priceNotificationTaskName,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        frequency: const Duration(minutes: 60),
      );
    } else {
      Workmanager().registerOneOffTask(
        _priceNotificationTaskName,
        _priceNotificationTaskName,
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    }
  }

  void cancelPriceNotification() {
    Workmanager().cancelByUniqueName(_priceNotificationTaskName);
  }

  void scheduleTransactionNotification() {
    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(
        _transactionNotificationTaskName,
        _transactionNotificationTaskName,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        frequency: const Duration(minutes: 15),
      );
    } else {
      Workmanager().registerOneOffTask(
        _transactionNotificationTaskName,
        _transactionNotificationTaskName,
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    }
  }

  void cancelTransactionNotification() {
    Workmanager().cancelByUniqueName(_transactionNotificationTaskName);
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      SharedPreferenceService sharedPreferenceService =
          SharedPreferenceService(sharedPreferences);
      SettingsService settingsService =
          SettingsService(sharedPreferenceService);
      AppSettings appSettings = await settingsService.getAppSettings();
      AppLocalizations localizations =
          await AppLocalizations.delegate.load(appSettings.appLanguage.locale);
      if (task.contains(Workmanager.iOSBackgroundTask)) {
        if (appSettings.useTransactionNotification) {
          await _handleTransactionNotificationTask(
              settingsService, sharedPreferenceService, localizations);
        }
        if (appSettings.usePriceNotification) {
          await _handlePriceNotificationTask(localizations);
        }
      } else if (task.contains("priceNotificationTask") &&
          appSettings.usePriceNotification) {
        await _handlePriceNotificationTask(localizations);
        if (Platform.isIOS) {
          Workmanager().registerOneOffTask(
            "priceNotificationTask",
            "priceNotificationTask",
            existingWorkPolicy: ExistingWorkPolicy.append,
          );
        }
      } else if (task.contains("transactionNotificationTask") &&
          appSettings.useTransactionNotification) {
        await _handleTransactionNotificationTask(
            settingsService, sharedPreferenceService, localizations);
        if (Platform.isIOS) {
          Workmanager().registerOneOffTask(
            "transactionNotificationTask",
            "transactionNotificationTask",
            existingWorkPolicy: ExistingWorkPolicy.append,
          );
        }
      }
    } on Exception catch (e, stacktrace) {
      foundation.debugPrintStack(stackTrace: stacktrace, label: e.toString());
    }
    return Future.value(true);
  });
}

Future<void> _handlePriceNotificationTask(
    AppLocalizations localizations) async {
  MarketData? marketData = await MarketService().getMarketData();
  if (marketData != null) {
    await _showNotification(
      localizations.priceNotificationHeader,
      localizations.priceNotificationMessage(
          marketData.change24Hr, marketData.price.toStringAsFixed(2)),
      "price_channel",
      "Price Changed",
      0,
    );
  }
}

Future<void> _showNotification(String title, String body, String channel,
    String channelName, int id) async {
  AndroidNotificationDetails androidChannelSpecifics =
      AndroidNotificationDetails(
    channel,
    channelName,
    importance: Importance.high,
    color: CustomColors.qrlDarkBlueMaterial,
    icon: "ic_notification",
  );
  DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(threadIdentifier: channel);
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await (await getLocalNotificationsPlugin()).show(
    id,
    title,
    body,
    platformChannelSpecifics,
  );
}

Future<FlutterLocalNotificationsPlugin> getLocalNotificationsPlugin() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const settingsAndroid = AndroidInitializationSettings("ic_notification");
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  const settings = InitializationSettings(
      android: settingsAndroid, iOS: initializationSettingsDarwin);
  await flutterLocalNotificationsPlugin.initialize(settings);
  return flutterLocalNotificationsPlugin;
}

Future<void> _handleTransactionNotificationTask(
    SettingsService settingsService,
    SharedPreferenceService sharedPreferenceService,
    AppLocalizations localizations) async {
  DateTime lastCheckDateTime =
      await _getAndUpdateLastCheckDateTime(sharedPreferenceService);
  GrpcService grpcService = GrpcService(settingsService);
  SecuredStorageService securedStorageService =
      SecuredStorageService(const FlutterSecureStorage());
  WalletService walletService = WalletService(sharedPreferenceService,
      securedStorageService, grpcService, FfiWalletService());
  List<Wallet> wallets = await walletService.getWallets();
  for (Wallet wallet in wallets) {
    if (await grpcService.hasIncomingTransactionsAfterDate(
        wallet.address, lastCheckDateTime)) {
      await _showNotification(
        localizations.transactionNotificationHeader,
        localizations.transactionNotificationMessage,
        "transaction_channel",
        "Transaction Received",
        1,
      );
      break;
    }
  }
}

Future<DateTime> _getAndUpdateLastCheckDateTime(
    SharedPreferenceService sharedPreferenceService) async {
  DateTime now = DateTime.now();
  DateTime lastCheckDateTime = DateTime.fromMillisecondsSinceEpoch(
      await sharedPreferenceService
              .getIntValue("transaction-last-check-date-time") ??
          now.subtract(const Duration(minutes: 5)).millisecondsSinceEpoch);
  await sharedPreferenceService.setIntValue(
      "transaction-last-check-date-time", now.millisecondsSinceEpoch);
  return lastCheckDateTime;
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {}
