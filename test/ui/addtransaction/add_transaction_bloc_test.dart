import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

import '../../testutil/mock_settings_service.dart';
import '../../testutil/mock_wallet_service.dart';
import 'add_transaction_test_util.dart';

void main() {
  group('AddTransactionBloc', () {
    late AddTransactionBloc addTransactionBloc;
    setUpAll(() async {
      SettingsService settingsService = MockSettingsService();
      WalletService walletService = MockWalletService();
      getIt.registerLazySingleton<SettingsService>(() => settingsService);
      getIt.registerLazySingleton<WalletService>(() => walletService);
    });

    setUp(() {
      addTransactionBloc = AddTransactionTestBloc();
    });

    test("test initial state", () {
      expect(addTransactionBloc.state, const AddTransactionTestState());
    });

    blocTest(
      'emits [loadingWallets, loadingExtendedWalletData, ready] when InitEvent',
      build: () => addTransactionBloc,
      act: (bloc) => addTransactionBloc.add(InitEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransactionState>()
              .having((state) => state.status, "status",
                  AddTransactionStatus.loadingWallets)
              .having((state) => state.fee, "fee", 1000000),
          isA<AddTransactionState>()
              .having((state) => state.status, "status",
                  AddTransactionStatus.loadingExtendedWalletData)
              .having((state) => state.wallets.length, "wallet count", 4)
              .having((state) => state.currentWallet!.name,
                  "current wallet name", "name-2"),
          isA<AddTransactionState>()
              .having(
                  (state) => state.status, "status", AddTransactionStatus.ready)
              .having((state) => state.extendedWalletData!.balance,
                  "extended wallet balance", 1337),
        ];
      },
    );

    blocTest(
      'emits [loadingExtendedWalletData and ready] when WalletChangedEvent',
      build: () => addTransactionBloc,
      act: (bloc) async => addTransactionBloc.add(WalletChangedEvent(
          (await getIt<WalletService>().getWallets()).first)),
      wait: const Duration(seconds: 2),
      expect: () {
        return [
          isA<AddTransactionState>()
              .having((state) => state.status, "status",
                  AddTransactionStatus.tokenChanged)
              .having(
                  (state) => state.selectedToken, "current wallet name", null),
          isA<AddTransactionState>()
              .having((state) => state.status, "status",
                  AddTransactionStatus.loadingExtendedWalletData)
              .having((state) => state.currentWallet!.name,
                  "current wallet name", "name-1"),
          isA<AddTransactionState>()
              .having(
                  (state) => state.status, "status", AddTransactionStatus.ready)
              .having((state) => state.extendedWalletData!.balance,
                  "extended wallet balance", 1337),
        ];
      },
    );

    blocTest(
      'emits [new fee] when FeeChangedEvent',
      build: () => addTransactionBloc,
      act: (bloc) => addTransactionBloc.add(const FeeChangedEvent(500000)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransactionState>()
              .having((state) => state.fee, "fee", 500000),
        ];
      },
    );
  });
}
