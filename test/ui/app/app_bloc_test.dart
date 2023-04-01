import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/app_language.dart';
import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/app/app_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppBloc', () {
    late AppBloc appBloc;

    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        "wallet-id-list": '''
[
  1,
  2
]
''',
        "app-settings": '''
{
  "useDeviceLogin": false,
  "nodeUrl": "mainnet-1.automated.theqrl.org",
  "port": 19009,
  "appLanguage": "AppLanguage.nl"
}
''',
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      setupServiceLocator(sharedPreferences);
    });

    setUp(() {
      appBloc = AppBloc();
    });

    test("test initial state", () {
      expect(appBloc.state, AppState(appSettings: AppSettings()));
    });

    blocTest(
      'emits [ready having wallet count and app settings] when InitEvent()',
      build: () => appBloc,
      act: (bloc) => appBloc.add(InitEvent()),
      expect: () => [
        isA<AppState>()
            .having((state) => state.status, "status", AppStatus.ready)
            .having((state) => state.walletCount, "walletCount", 2)
            .having(
                (state) => state.appSettings,
                "appSettings",
                isA<AppSettings>().having(
                    (appSettings) => appSettings.appLanguage,
                    "appLanguage",
                    AppLanguage.nl))
      ],
    );

    blocTest(
      'emits [ready having wallet count and app settings] when SettingsUpdatedEvent()',
      build: () => appBloc,
      seed: () => AppState(
          appSettings: AppSettings(), walletCount: 2, status: AppStatus.ready),
      act: (bloc) => appBloc.add(SettingsUpdatedEvent()),
      expect: () => [
        isA<AppState>()
            .having((state) => state.status, "status", AppStatus.loading),
        isA<AppState>()
            .having((state) => state.status, "status", AppStatus.ready)
            .having((state) => state.walletCount, "walletCount", 2)
            .having(
                (state) => state.appSettings,
                "appSettings",
                isA<AppSettings>().having(
                    (appSettings) => appSettings.appLanguage,
                    "appLanguage",
                    AppLanguage.nl))
      ],
    );
  });
}
