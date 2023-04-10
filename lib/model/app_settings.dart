import 'package:mobile_wallet/model/app_language.dart';

class AppSettings {
  bool useDeviceLogin;
  String nodeUrl;
  int port;
  AppLanguage appLanguage;
  bool useTransactionNotification;
  bool usePriceNotification;

  AppSettings(
      {this.useDeviceLogin = false,
      this.nodeUrl = "mainnet-1.automated.theqrl.org",
      this.port = 19009,
      this.appLanguage = AppLanguage.en,
      this.useTransactionNotification = false,
      this.usePriceNotification = false});

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      useDeviceLogin: json["useDeviceLogin"],
      nodeUrl: json["nodeUrl"],
      port: json["port"],
      appLanguage: AppLanguage.fromName(json["appLanguage"]),
      useTransactionNotification: json["useTransactionNotification"] ?? false,
      usePriceNotification: json["usePriceNotification"] ?? false,
    );
  }

  Map toJson() => {
        "useDeviceLogin": useDeviceLogin,
        "nodeUrl": nodeUrl,
        "port": port,
        "appLanguage": "$appLanguage",
        "useTransactionNotification": useTransactionNotification,
        "usePriceNotification": usePriceNotification,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          useDeviceLogin == other.useDeviceLogin &&
          nodeUrl == other.nodeUrl &&
          port == other.port &&
          appLanguage == other.appLanguage &&
          useTransactionNotification == other.useTransactionNotification &&
          usePriceNotification == other.usePriceNotification;

  @override
  int get hashCode =>
      useDeviceLogin.hashCode ^
      nodeUrl.hashCode ^
      port.hashCode ^
      appLanguage.hashCode ^
      useTransactionNotification.hashCode ^
      usePriceNotification.hashCode;
}
