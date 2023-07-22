import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_bloc.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_event.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_state.dart';

import '../../../testutil/mock_settings_service.dart';
import '../../../testutil/mock_transaction_service.dart';
import '../../../testutil/mock_wallet_service.dart';

void main() {
  group('AddMessageBloc', () {
    late AddMessageBloc addMessageBloc;
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
      addMessageBloc = AddMessageBloc();
    });

    test("test initial state", () {
      expect(addMessageBloc.state, const AddMessageState());
    });

    blocTest(
      'emits [new message] when MessageChanged',
      build: () => addMessageBloc,
      act: (bloc) => addMessageBloc.add(MessageChangedEvent("new-message")),
      wait: const Duration(seconds: 2),
      expect: () {
        return [
          isA<AddMessageState>()
              .having((state) => state.message, "message", "new-message"),
        ];
      },
    );
  });
}
