import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/tools/export/export_transactions_bloc.dart';

import '../../../testutil/mock_transaction_service.dart';
import '../../../testutil/mock_wallet_service.dart';

void main() {
  group('ExportTransactionsBloc', () {
    late ExportTransactionsBloc exportTransactionsBloc;
    setUpAll(() async {
      TransactionService transactionsService = MockTransactionService();
      WalletService walletService = MockWalletService();
      getIt
          .registerLazySingleton<TransactionService>(() => transactionsService);
      getIt.registerLazySingleton<WalletService>(() => walletService);
    });

    setUp(() {
      exportTransactionsBloc = ExportTransactionsBloc();
    });

    test("test initial state", () {
      expect(exportTransactionsBloc.state, const ExportTransactionsState());
    });

    blocTest(
      'emits [loadingWallet, exportable] when InitEvent',
      build: () => exportTransactionsBloc,
      act: (bloc) => exportTransactionsBloc.add(InitEvent()),
      wait: const Duration(seconds: 2),
      expect: () {
        DateTime now = DateTime.now();
        return [
          isA<ExportTransactionsState>().having((state) => state.status,
              "status", ExportTransactionsStatus.loadingWallets),
          isA<ExportTransactionsState>()
              .having((state) => state.status, "status",
                  ExportTransactionsStatus.exportable)
              .having((state) => state.fromDate, "from date",
                  DateTime(now.year, now.month, 1))
              .having((state) => state.toDate, "to date",
                  DateTime(now.year, now.month + 1, 0))
              .having((state) => state.wallets.length, "wallets size", 4)
              .having(
                  (state) => state.currentWallet!.id, "current wallet id", 2),
        ];
      },
    );

    blocTest(
      'emits [exportable] when WalletChangedEvent',
      build: () => exportTransactionsBloc,
      act: (bloc) async => exportTransactionsBloc.add(WalletChangedEvent(
          (await getIt<WalletService>().getWallets()).first)),
      wait: const Duration(seconds: 2),
      expect: () {
        return [
          isA<ExportTransactionsState>()
              .having((state) => state.status, "status",
                  ExportTransactionsStatus.exportable)
              .having(
                  (state) => state.currentWallet!.id, "current wallet id", 1),
        ];
      },
    );

    blocTest(
      'emits [new from date] when FromDateChangedEvent',
      build: () => exportTransactionsBloc,
      act: (bloc) async => exportTransactionsBloc
          .add(FromDateChangedEvent(DateTime(2024, 1, 1))),
      wait: const Duration(seconds: 2),
      expect: () {
        return [
          isA<ExportTransactionsState>().having(
              (state) => state.fromDate, "from date", DateTime(2024, 1, 1)),
        ];
      },
    );

    blocTest(
      'emits [new to date] when ToDateChangedEvent',
      build: () => exportTransactionsBloc,
      act: (bloc) async =>
          exportTransactionsBloc.add(ToDateChangedEvent(DateTime(2024, 1, 1))),
      wait: const Duration(seconds: 2),
      expect: () {
        return [
          isA<ExportTransactionsState>()
              .having((state) => state.toDate, "to date", DateTime(2024, 1, 1)),
        ];
      },
    );
  });
}
