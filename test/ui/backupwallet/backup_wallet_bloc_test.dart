import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/backupwallet/backup_wallet_bloc.dart';

import '../../testutil/mock_wallet_service.dart';

void main() {
  group('BackupWalletBloc', () {
    late BackupWalletBloc backupWalletBloc;
    setUpAll(() async {
      WalletService walletService = MockWalletService();
      getIt.registerLazySingleton<WalletService>(() => walletService);
    });

    Wallet wallet = Wallet(0, "name", "address", 1);
    setUp(() {
      backupWalletBloc = BackupWalletBloc(wallet);
    });

    test("test initial state", () {
      expect(backupWalletBloc.state, BackupWalletState(wallet: wallet));
    });

    blocTest(
      'emits [ready having hex seed and mnemonic] when InitEvent()',
      build: () => backupWalletBloc,
      act: (bloc) => backupWalletBloc.add(InitEvent()),
      wait: const Duration(seconds: 5),
      expect: () => [
        BackupWalletState(
            status: BackupWalletStatus.loadingHexSeed, wallet: wallet),
        isA<BackupWalletState>()
            .having((state) => state.status, "status",
                BackupWalletStatus.loadingMnemonic)
            .having((state) => state.wallet, "wallet", wallet)
            .having((state) => state.hexSeed, "hexSeed", "test-hexSeed"),
        isA<BackupWalletState>()
            .having((state) => state.status, "status", BackupWalletStatus.ready)
            .having((state) => state.wallet, "wallet", wallet)
            .having((state) => state.hexSeed, "hexSeed", "test-hexSeed")
            .having((state) => state.mnemonic, "mnemonic", "test-mnemonic"),
      ],
    );
  });
}
