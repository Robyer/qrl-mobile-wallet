import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/grpc_service.dart';
import 'package:mobile_wallet/service/shared_preference_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../testutil/mock_ffi_wallet_service.dart';
import '../testutil/mock_secured_storage_service.dart';

class MockGrpcService extends Mock implements GrpcService {}

void main() {
  group('WalletService', () {
    late WalletService walletService;

    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      SharedPreferenceService sharedPreferenceService =
          SharedPreferenceService(sharedPreferences);
      walletService = WalletService(
          sharedPreferenceService,
          MockSecuredStorageService(),
          MockGrpcService(),
          MockFfiWalletService());
    });

    test("test wallet service", () async {
      Wallet wallet = await walletService.createWallet("wallet-1",
          treeHeight: 1, hashFunction: 1);
      wallet = (await walletService.getWallet(wallet.id))!;
      expect(wallet.name, "wallet-1");
      expect(wallet.address, "address");
      expect(wallet.height, 1);
      String hexSeed = await walletService.getHexSeed(wallet.id);
      expect(hexSeed, "hex");
      int count = await walletService.getWalletCount();
      expect(count, 1);
      int? currentWalletId = await walletService.getCurrentWalletId();
      expect(currentWalletId, wallet.id);
      await walletService.deleteWallet(wallet.id);
      count = await walletService.getWalletCount();
      expect(count, 0);
    });

    test("test wallet service multi", () async {
      //create 3 wallets
      Wallet wallet1 = await walletService.createWallet("wallet-1",
          treeHeight: 1, hashFunction: 1);
      Wallet wallet2 =
          await walletService.createWallet("wallet-2", hexSeed: "test-hex");
      Wallet wallet3 = await walletService.createWallet("wallet-3",
          mnemonic: "test-mnemonic");
      //count should be 3
      int count = await walletService.getWalletCount();
      expect(count, 3);
      //current wallet should be id of wallet 1
      int? currentWalletId = await walletService.getCurrentWalletId();
      expect(currentWalletId, wallet1.id);
      await walletService.setCurrentWalletId(wallet3.id);
      //current wallet should be id of wallet 3
      currentWalletId = await walletService.getCurrentWalletId();
      expect(currentWalletId, wallet3.id);
      List<Wallet> storedWallets = await walletService.getWallets();
      expect(
          storedWallets
              .firstWhere((storedWallet) => storedWallet.id == wallet1.id),
          wallet1);
      expect(
          storedWallets
              .firstWhere((storedWallet) => storedWallet.id == wallet2.id),
          wallet2);
      expect(
          storedWallets
              .firstWhere((storedWallet) => storedWallet.id == wallet3.id),
          wallet3);
      await walletService.deleteWallet(wallet3.id);
      //count should be 2
      count = await walletService.getWalletCount();
      expect(count, 2);
      //first wallet should be selected after delete
      currentWalletId = await walletService.getCurrentWalletId();
      expect(currentWalletId, wallet1.id);
      storedWallets = await walletService.getWallets();
      expect(storedWallets.length, 2);
      expect(
          storedWallets
              .firstWhere((storedWallet) => storedWallet.id == wallet1.id),
          wallet1);
      expect(
          storedWallets
              .firstWhere((storedWallet) => storedWallet.id == wallet2.id),
          wallet2);
      await walletService.updateWalletName(wallet1.id, "new name");
      wallet1 = (await walletService.getWallet(wallet1.id))!;
      expect(wallet1.name, "new name");
    });
  });
}
