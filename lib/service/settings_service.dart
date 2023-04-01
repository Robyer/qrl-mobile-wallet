import 'dart:convert';

import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/service/shared_preference_service.dart';

class SettingsService {
  final SharedPreferenceService _sharedPreferenceService;
  AppSettings? _appSettings;

  SettingsService(this._sharedPreferenceService);

  Future<AppSettings> getAppSettings() async {
    if (_appSettings == null) {
      String? json =
      await _sharedPreferenceService.getStringValue("app-settings");
      if (json != null) {
        _appSettings = AppSettings.fromJson(jsonDecode(json));
      } else {
        _appSettings = AppSettings();
      }
    }
    return _appSettings!;
  }

  Future<void> saveAppSettings(AppSettings appSettings) async {
    _sharedPreferenceService.setStringValue(
        "app-settings", jsonEncode(appSettings));
    _appSettings = appSettings;
  }

  Future<int> getFeeSetting() async {
    return await _sharedPreferenceService.getIntValue("fee") ?? 1000000;
  }

  Future<void> updateFeeSetting(int fee) async {
    _sharedPreferenceService.setIntValue("fee", fee);
  }
}
