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
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/shared_preference_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static const _priceNotificationTaskName = "priceNotificationTask";
  static const _transactionNotificationTaskName = "transactionNotificationTask";

  NotificationService() {
    Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: false,
    );
  }

  void schedulePriceNotification() {
    Workmanager().registerPeriodicTask(
      _priceNotificationTaskName,
      _priceNotificationTaskName,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: const Duration(minutes: 15),
    );
  }

  void cancelPriceNotification() {
    Workmanager().cancelByUniqueName(_priceNotificationTaskName);
  }

  void scheduleTransactionNotification() {
    Workmanager().registerPeriodicTask(
      _transactionNotificationTaskName,
      _transactionNotificationTaskName,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: const Duration(minutes: 15),
    );
  }

  void cancelTransactionNotification() {
    Workmanager().cancelByUniqueName(_transactionNotificationTaskName);
  }
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    SharedPreferenceService sharedPreferenceService =
        SharedPreferenceService(sharedPreferences);
    SettingsService settingsService = SettingsService(sharedPreferenceService);
    AppSettings appSettings = await settingsService.getAppSettings();
    AppLocalizations localizations =
        await AppLocalizations.delegate.load(appSettings.appLanguage.locale);
    if (task == "priceNotificationTask" && appSettings.usePriceNotification) {
      await _handlePriceNotificationTask(localizations);
    } else if (task == "transactionNotificationTask" &&
        appSettings.useTransactionNotification) {
      await _handleTransactionNotificationTask(
          settingsService, sharedPreferenceService, localizations);
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
  const settingsAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
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
