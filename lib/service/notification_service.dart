import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_wallet/model/app_language.dart';
import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/ffi_wallet_service.dart';
import 'package:mobile_wallet/service/grpc_service.dart';
import 'package:mobile_wallet/service/secured_storage_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/shared_preference_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';

class NotificationService {
  static final Map<String, String> _priceNotificationChannels =
      <String, String>{
    AppLanguage.en.name: "priceNotificationsEn",
    AppLanguage.zh.name: "priceNotificationsZh",
    AppLanguage.ja.name: "priceNotificationsJa",
    AppLanguage.nl.name: "priceNotificationsNl",
    AppLanguage.ko.name: "priceNotificationsKo",
    AppLanguage.de.name: "priceNotificationsDe",
    AppLanguage.it.name: "priceNotificationsIt",
    AppLanguage.es.name: "priceNotificationsEs",
  };
  static const _notificationTaskName = "notificationTask";
  static const _transactionNotificationTaskName = "transactionNotificationTask";
  static const _transactionNotificationTopicName = "transactionNotifications";

  static Future<void> initNotifications() async {
    SharedPreferenceService sharedPreferenceService =
        getIt<SharedPreferenceService>();
    SettingsService settingsService = getIt<SettingsService>();
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'fb_high_importance_channel',
        'High Importance Notifications Firebase',
        importance: Importance.max,
      );
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRemoteDataMessage(
          message, sharedPreferenceService, settingsService);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null && Platform.isAndroid) {
        await _showNotification(
            message.notification!.title ?? "",
            message.notification!.body ?? "",
            'fb_high_importance_channel',
            'High Importance Notifications Firebase',
            3,
            tag: message.notification!.android?.tag);
      } else {
        await _handleRemoteDataMessage(
            message, sharedPreferenceService, settingsService);
      }
    });
    AppSettings appSettings = await settingsService.getAppSettings();
    if (appSettings.useTransactionNotification ||
        appSettings.usePriceNotification) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true,
      );
    }
  }

  Future<void> schedulePriceNotification(String languageCode) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if ((await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: true,
          sound: true,
        ))
            .authorizationStatus !=
        AuthorizationStatus.denied) {
      String? channel = _priceNotificationChannels[languageCode];
      if (channel != null) {
        await messaging.subscribeToTopic(channel);
      }
    }
  }

  Future<void> cancelPriceNotification() async {
    for (var channel in _priceNotificationChannels.values) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(channel);
    }
  }

  Future<void> scheduleTransactionNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if ((await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: true,
          sound: true,
        ))
            .authorizationStatus !=
        AuthorizationStatus.denied) {
      await messaging.subscribeToTopic(_transactionNotificationTopicName);
    }
  }

  Future<void> cancelTransactionNotification() async {
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(_transactionNotificationTopicName);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    SharedPreferenceService sharedPreferenceService =
        SharedPreferenceService(sharedPreferences);
    SettingsService settingsService = SettingsService(sharedPreferenceService);
    await _handleRemoteDataMessage(
        message, sharedPreferenceService, settingsService);
  } on Exception catch (e, stacktrace) {
    foundation.debugPrintStack(stackTrace: stacktrace, label: e.toString());
  }
}

Future<void> _handleRemoteDataMessage(
    RemoteMessage message,
    SharedPreferenceService sharedPreferenceService,
    SettingsService settingsService) async {
  if (message.data.isNotEmpty) {
    String? type = message.data["type"];
    if (type != null) {
      AppSettings appSettings = await settingsService.getAppSettings();
      if (type == NotificationService._transactionNotificationTaskName &&
          appSettings.useTransactionNotification) {
        await _handleTransactionNotificationTask(
            settingsService,
            sharedPreferenceService,
            await AppLocalizations.delegate
                .load(appSettings.appLanguage.locale));
      } else if (type == NotificationService._notificationTaskName) {
        await _showNotification(
          message.data["header"] ?? "QRL notification",
          message.data["body"] ?? "QRL",
          "notification_channel",
          "Notification Received",
          2,
        );
      }
    }
  }
}

Future<void> _showNotification(
    String title, String body, String channel, String channelName, int id,
    {String? tag}) async {
  AndroidNotificationDetails androidChannelSpecifics =
      AndroidNotificationDetails(channel, channelName,
          importance: Importance.max,
          color: CustomColors.qrlDarkBlueMaterial,
          icon: "ic_notification",
          tag: tag);
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
          now.subtract(const Duration(minutes: 20)).millisecondsSinceEpoch);
  await sharedPreferenceService.setIntValue(
      "transaction-last-check-date-time", now.millisecondsSinceEpoch);
  return lastCheckDateTime;
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {}
