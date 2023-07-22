import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/ui/tools/notarization/verify/verify_notarization_bloc.dart';

import '../../../../testutil/mock_transaction_service.dart';

void main() {
  group('VerifyNotarizationBloc', () {
    late VerifyNotarizationBloc verifyNotarizationBloc;
    setUpAll(() async {
      TransactionService transactionsService = MockTransactionService();
      getIt
          .registerLazySingleton<TransactionService>(() => transactionsService);
    });

    setUp(() {
      verifyNotarizationBloc = VerifyNotarizationBloc();
    });

    test("test initial state", () {
      expect(verifyNotarizationBloc.state, const VerifyNotarizationState());
    });

    blocTest(
      'emits [new transaction hash] when TransactionHashChangedEvent',
      build: () => verifyNotarizationBloc,
      act: (bloc) => verifyNotarizationBloc
          .add(const TransactionHashChangedEvent("test-hash")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<VerifyNotarizationState>().having(
              (state) => state.transactionHash,
              "transaction hash",
              "test-hash"),
        ];
      },
    );

    blocTest(
      'emits [searching, notarizationNotFound] when SearchEvent',
      build: () => verifyNotarizationBloc,
      seed: () => const VerifyNotarizationState(transactionHash: "search-hash"),
      act: (bloc) => verifyNotarizationBloc.add(SearchEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<VerifyNotarizationState>().having((state) => state.status,
              "status", VerifyNotarizationStatus.searching),
          isA<VerifyNotarizationState>().having((state) => state.status,
              "status", VerifyNotarizationStatus.notarizationNotFound),
        ];
      },
    );
  });
}
