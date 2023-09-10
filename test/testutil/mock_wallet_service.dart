import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mockito/mockito.dart';

class MockWalletService extends Mock implements WalletService {
  static final Wallet _wallet1 = Wallet(1, "name-1", "address-1", 1);
  static final Wallet _wallet2 = Wallet(2, "name-2", "address-2", 1);
  static final Wallet _wallet3 = Wallet(3, "name-3", "address-3", 1);
  static final Wallet _wallet4 = Wallet(4, "name-4", "address-4", 1);
  static final List<Wallet> wallets = [_wallet1, _wallet2, _wallet3, _wallet4];

  @override
  Future<int?> getCurrentWalletId() async {
    return Future(() => 2);
  }

  @override
  Future<void> setCurrentWalletId(int id) async {
    return Future(() => {});
  }

  @override
  Future<String> getMnemonic(String hexSeed) async {
    return Future(() => "test-mnemonic");
  }

  @override
  Future<String> getHexSeed(int id) async {
    return Future(() => "test-hexSeed");
  }

  @override
  Future<List<Wallet>> getWallets() async {
    return Future(() => [_wallet1, _wallet2, _wallet3, _wallet4]);
  }

  @override
  Future<void> deleteWallet(int id) async {
    return Future(() => {});
  }

  @override
  Future<Wallet> createWallet(String name,
      {int? treeHeight,
      int? hashFunction,
      String? hexSeed,
      String? mnemonic}) async {
    return Wallet(999, name, "address", 1);
  }

  @override
  Future<ExtendedWalletData> getExtendedWalletData(String walletAddress,
      {bool loadTokenTransaction = false}) async {
    return Future(() => ExtendedWalletData(1337, 25, []));
  }
}
