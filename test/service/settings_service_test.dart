import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/app_language.dart';
import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/shared_preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SettingsService? settingsService;
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      "fee": 100,
    });
    settingsService = SettingsService(
        SharedPreferenceService(await SharedPreferences.getInstance()));
  });

  test("test default values", () async {
    AppSettings appSettings = await settingsService!.getAppSettings();
    expect(appSettings.useDeviceLogin, false);
    expect(appSettings.nodeUrl, "mainnet-1.automated.theqrl.org");
    expect(appSettings.port, 19009);
    expect(appSettings.appLanguage, AppLanguage.en);
    int fee = await settingsService!.getFeeSetting();
    expect(fee, 100);
  });

  test("test update values", () async {
    await settingsService!.saveAppSettings(AppSettings(
        useDeviceLogin: true,
        nodeUrl: "test.update.node.com",
        port: 54321,
        appLanguage: AppLanguage.nl));
    await settingsService!.updateFeeSetting(500);
    AppSettings appSettings = await settingsService!.getAppSettings();
    expect(appSettings.useDeviceLogin, true);
    expect(appSettings.nodeUrl, "test.update.node.com");
    expect(appSettings.port, 54321);
    expect(appSettings.appLanguage, AppLanguage.nl);
    int fee = await settingsService!.getFeeSetting();
    expect(fee, 500);
  });
}
