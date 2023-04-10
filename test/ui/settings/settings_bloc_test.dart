import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/app_language.dart';
import 'package:mobile_wallet/service/notification_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/settings/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../testutil/mock_notification_service.dart';

void main() {
  group('SettingsBloc', () {
    late SettingsBloc settingsBloc;
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        "app-settings": '''
{
  "useDeviceLogin": false,
  "nodeUrl": "mainnet-1.automated.theqrl.org",
  "port": 19009,
  "appLanguage": "AppLanguage.nl",
  "useTransactionNotification": false,
  "usePriceNotification": false
}
''',
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      setupServiceLocator(sharedPreferences);
      getIt.unregister<NotificationService>();
      getIt.registerLazySingleton<NotificationService>(
          () => MockNotificationService());
    });

    setUp(() {
      settingsBloc = SettingsBloc();
    });

    test("test initial state", () {
      expect(settingsBloc.state, const SettingsState());
    });

    blocTest(
      'emits [loadingAppSettings and ready having AppSettings] when InitEvent()',
      build: () => settingsBloc,
      act: (bloc) => settingsBloc.add(InitSettingsEvent()),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<SettingsState>().having((state) => state.status, "status",
            SettingsStatus.loadingAppSettings),
        isA<SettingsState>()
            .having((state) => state.status, "status", SettingsStatus.ready)
            .having((state) => state.currentAppSettings!.appLanguage,
                "language", AppLanguage.nl),
        isA<SettingsState>().having(
            (state) => state.status, "status", SettingsStatus.noChanges),
      ],
    );

    blocTest(
        'emits [useDeviceLoginChanged and dirty having new value] when UseDeviceLoginChanged()',
        build: () => settingsBloc..add(InitSettingsEvent()),
        act: (bloc) => settingsBloc.add(const UseDeviceLoginChanged(true)),
        wait: const Duration(seconds: 1),
        expect: () => [
              isA<SettingsState>()
                  .having((state) => state.status, "status",
                      SettingsStatus.useDeviceLoginChanged)
                  .having((state) => state.useDeviceLogin, "use device login",
                      true),
              isA<SettingsState>().having(
                  (state) => state.status, "status", SettingsStatus.dirty),
            ],
        skip: 3);

    blocTest(
        'emits [useTransactionNotificationChanged and dirty having new value] when UseTransactionNotificationChanged()',
        build: () => settingsBloc..add(InitSettingsEvent()),
        act: (bloc) =>
            settingsBloc.add(const UseTransactionNotificationChanged(true)),
        wait: const Duration(seconds: 1),
        expect: () => [
              isA<SettingsState>()
                  .having((state) => state.status, "status",
                      SettingsStatus.useTransactionNotificationChanged)
                  .having((state) => state.useTransactionNotification,
                      "use transaction notification", true),
              isA<SettingsState>().having(
                  (state) => state.status, "status", SettingsStatus.dirty),
            ],
        skip: 3);

    blocTest(
        'emits [usePriceNotificationChanged and dirty having new value] when UsePriceNotificationChanged()',
        build: () => settingsBloc..add(InitSettingsEvent()),
        act: (bloc) =>
            settingsBloc.add(const UsePriceNotificationChanged(true)),
        wait: const Duration(seconds: 1),
        expect: () => [
              isA<SettingsState>()
                  .having((state) => state.status, "status",
                      SettingsStatus.usePriceNotificationChanged)
                  .having((state) => state.usePriceNotification,
                      "use price notification", true),
              isA<SettingsState>().having(
                  (state) => state.status, "status", SettingsStatus.dirty),
            ],
        skip: 3);

    blocTest(
        'emits [appLanguageChanged and dirty having new value] when AppLanguageChanged()',
        build: () => settingsBloc..add(InitSettingsEvent()),
        act: (bloc) =>
            settingsBloc.add(const AppLanguageChanged(AppLanguage.ja)),
        wait: const Duration(seconds: 1),
        expect: () => [
              isA<SettingsState>()
                  .having((state) => state.status, "status",
                      SettingsStatus.appLanguageChanged)
                  .having((state) => state.appLanguage, "app language",
                      AppLanguage.ja),
              isA<SettingsState>().having(
                  (state) => state.status, "status", SettingsStatus.dirty),
            ],
        skip: 3);

    blocTest(
        'emits [nodeUrlChanged and dirty having new value] when NodeUrlChanged()',
        build: () => settingsBloc..add(InitSettingsEvent()),
        act: (bloc) => settingsBloc.add(const NodeUrlChanged("test")),
        wait: const Duration(seconds: 1),
        expect: () => [
              isA<SettingsState>()
                  .having((state) => state.status, "status",
                      SettingsStatus.nodeUrlChanged)
                  .having((state) => state.nodeUrl, "node url", "test"),
              isA<SettingsState>().having(
                  (state) => state.status, "status", SettingsStatus.dirty),
            ],
        skip: 3);

    blocTest(
        'emits [portChanged and dirty having new value] when PortChanged()',
        build: () => settingsBloc..add(InitSettingsEvent()),
        act: (bloc) => settingsBloc.add(const PortChanged(9999)),
        wait: const Duration(seconds: 1),
        expect: () => [
              isA<SettingsState>()
                  .having((state) => state.status, "status",
                      SettingsStatus.portChanged)
                  .having((state) => state.port, "port", 9999),
              isA<SettingsState>().having(
                  (state) => state.status, "status", SettingsStatus.dirty),
            ],
        skip: 3);
  });
}
