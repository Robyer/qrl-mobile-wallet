import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/wallets/wallets_bloc.dart';

import '../../testutil/mock_wallet_service.dart';

void main() {
  group('WalletsBloc', () {
    late WalletsBloc walletsBloc;
    late List<Wallet> wallets;

    setUpAll(() async {
      WalletService walletService = MockWalletService();
      getIt.registerLazySingleton<WalletService>(() => walletService);
      wallets = await walletService.getWallets();
    });

    setUp(() {
      walletsBloc = WalletsBloc();
    });

    test("test initial state", () {
      expect(walletsBloc.state, const WalletsState());
    });

    blocTest(
      'emits [loadingWallets, ready with wallets] when InitEvent',
      build: () => walletsBloc,
      act: (bloc) => walletsBloc.add(InitEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const WalletsState(status: WalletsStatus.loadingWallets),
          isA<WalletsState>()
              .having((state) => state.status, "status", WalletsStatus.ready)
              .having((state) => state.wallets, "wallets", wallets),
        ];
      },
    );

    blocTest(
      'emits [deletingWallet, walletDeleted, ready] when DeleteWalletEvent',
      build: () => walletsBloc,
      seed: () => WalletsState(status: WalletsStatus.ready, wallets: wallets),
      act: (bloc) => walletsBloc.add(DeleteWalletEvent(wallets.first)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const WalletsState(status: WalletsStatus.deletingWallet),
          const WalletsState(status: WalletsStatus.walletDeleted),
          const WalletsState(status: WalletsStatus.ready),
        ];
      },
    );

    blocTest(
      'emits [deletingWallet, walletDeleted, noWallets] when DeleteWalletEvent no more wallets',
      build: () => walletsBloc,
      seed: () =>
          WalletsState(status: WalletsStatus.ready, wallets: <Wallet>[]),
      act: (bloc) => walletsBloc.add(DeleteWalletEvent(wallets.first)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const WalletsState(status: WalletsStatus.deletingWallet),
          const WalletsState(status: WalletsStatus.walletDeleted),
          const WalletsState(status: WalletsStatus.noWallets),
        ];
      },
    );
    blocTest(
      'emits [loadingWallets, ready] when WalletNameUpdatedEvent',
      build: () => walletsBloc,
      seed: () => WalletsState(status: WalletsStatus.ready, wallets: wallets),
      act: (bloc) => walletsBloc.add(WalletNameUpdatedEvent(wallets.first)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const WalletsState(status: WalletsStatus.loadingWallets),
          const WalletsState(status: WalletsStatus.ready),
        ];
      },
    );
  });
}
