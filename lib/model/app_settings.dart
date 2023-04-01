import 'package:mobile_wallet/model/app_language.dart';

class AppSettings {
  bool useDeviceLogin;
  String nodeUrl;
  int port;
  AppLanguage appLanguage;

  AppSettings(
      {this.useDeviceLogin = false,
      this.nodeUrl = "mainnet-1.automated.theqrl.org",
      this.port = 19009,
      this.appLanguage = AppLanguage.en});

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      useDeviceLogin: json["useDeviceLogin"],
      nodeUrl: json["nodeUrl"],
      port: json["port"],
      appLanguage: AppLanguage.fromName(json["appLanguage"]),
    );
  }

  Map toJson() => {
        "useDeviceLogin": useDeviceLogin,
        "nodeUrl": nodeUrl,
        "port": port,
        "appLanguage": "$appLanguage",
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          useDeviceLogin == other.useDeviceLogin &&
          nodeUrl == other.nodeUrl &&
          port == other.port &&
          appLanguage == other.appLanguage;

  @override
  int get hashCode =>
      useDeviceLogin.hashCode ^
      nodeUrl.hashCode ^
      port.hashCode ^
      appLanguage.hashCode;
}
