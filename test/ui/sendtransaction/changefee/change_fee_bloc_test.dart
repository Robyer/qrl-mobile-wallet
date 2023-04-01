import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/ui/sendtransaction/changefee/change_fee_bloc.dart';

import '../../../testutil/mock_settings_service.dart';

void main() {
  group('ChangeFeeBloc', () {
    late ChangeFeeBloc changeFeeBloc;

    setUpAll(() async {
      SettingsService settingsService = MockSettingsService();
      getIt.registerLazySingleton<SettingsService>(() => settingsService);
    });

    setUp(() {
      changeFeeBloc = ChangeFeeBloc(1000);
    });

    test("test initial state", () {
      expect(changeFeeBloc.state, const ChangeFeeState(currentFee: 1000));
    });

    blocTest(
      'emits [dirty] when ChangedEvent with change',
      build: () => changeFeeBloc,
      act: (bloc) => changeFeeBloc.add(const ChangedEvent(2500)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const ChangeFeeState(
              status: ChangeFeeStatus.dirty, currentFee: 1000, newFee: 2500),
        ];
      },
    );

    blocTest(
      'emits [noChange] when ChangedEvent with no change',
      build: () => changeFeeBloc,
      act: (bloc) => changeFeeBloc.add(const ChangedEvent(1000)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const ChangeFeeState(
              status: ChangeFeeStatus.noChange, currentFee: 1000, newFee: 1000),
        ];
      },
    );

    blocTest(
      'emits [feeSaved with change] when ConfirmEvent',
      build: () => changeFeeBloc,
      seed: () => const ChangeFeeState(
          status: ChangeFeeStatus.dirty, currentFee: 1000, newFee: 4000),
      act: (bloc) => changeFeeBloc.add(ConfirmEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const ChangeFeeState(
              status: ChangeFeeStatus.feeSaved, currentFee: 1000, newFee: 4000),
        ];
      },
    );
  });
}
