import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_bloc.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_event.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_state.dart';

import '../../../../testutil/mock_settings_service.dart';
import '../../../../testutil/mock_transaction_service.dart';
import '../../../../testutil/mock_wallet_service.dart';

void main() {
  group('AddNotarizationBloc', () {
    late AddNotarizationBloc addNotarizationBloc;
    setUpAll(() async {
      SettingsService settingsService = MockSettingsService();
      TransactionService transactionsService = MockTransactionService();
      WalletService walletService = MockWalletService();
      getIt
          .registerLazySingleton<TransactionService>(() => transactionsService);
      getIt.registerLazySingleton<SettingsService>(() => settingsService);
      getIt.registerLazySingleton<WalletService>(() => walletService);
    });

    setUp(() {
      addNotarizationBloc = AddNotarizationBloc();
    });

    test("test initial state", () {
      expect(addNotarizationBloc.state, const AddNotarizationState());
    });

    blocTest(
      'emits [new message] when MessageChanged',
      build: () => addNotarizationBloc,
      act: (bloc) =>
          addNotarizationBloc.add(const MessageChangedEvent("new-message")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddNotarizationState>()
              .having((state) => state.message, "message", "new-message"),
        ];
      },
    );

    blocTest(
      'emits [new hasMessage] when HasMessageChangedEvent',
      build: () => addNotarizationBloc,
      act: (bloc) =>
          addNotarizationBloc.add(const HasMessageChangedEvent(true)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddNotarizationState>()
              .having((state) => state.hasMessage, "has message", true),
        ];
      },
    );
  });
}
