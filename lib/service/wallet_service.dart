import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/ffi_wallet_service.dart';
import 'package:mobile_wallet/service/grpc_service.dart';
import 'package:mobile_wallet/service/secured_storage_service.dart';
import 'package:mobile_wallet/service/shared_preference_service.dart';

class WalletService {
  final SharedPreferenceService _sharedPreferenceService;
  final SecuredStorageService _securedStorageService;
  final GrpcService _grpcService;
  final FfiWalletService _ffiWalletService;

  WalletService(this._sharedPreferenceService, this._securedStorageService,
      this._grpcService, this._ffiWalletService);

  Future<int> getWalletCount() async {
    return (await _getWalletIdList()).length;
  }

  Future<List<int>> _getWalletIdList() async {
    String? walletIdListString =
        await _sharedPreferenceService.getStringValue("wallet-id-list");
    if (walletIdListString != null) {
      List<int> walletIdList =
          (jsonDecode(walletIdListString) as List<dynamic>).cast<int>();
      return walletIdList;
    }
    return [];
  }

  Future<int?> getCurrentWalletId() async {
    return await _sharedPreferenceService.getIntValue("current-wallet-id");
  }

  Future<void> setCurrentWalletId(int id) async {
    return await _sharedPreferenceService.setIntValue("current-wallet-id", id);
  }

  Future<Wallet> getWallet(int id) async {
    String? walletString = await _securedStorageService.getValue("wallet-$id");
    if (walletString == null) {
      throw Exception("No wallet with id $id found!");
    }
    return Wallet.fromJson(jsonDecode(walletString));
  }

  Future<List<Wallet>> getWallets() async {
    return await Future.wait((await _getWalletIdList())
        .map((walletId) async => await getWallet(walletId))
        .toList());
  }

  Future<void> deleteWallet(int id) async {
    await _securedStorageService.deleteValue("hexseed-$id");
    await _securedStorageService.deleteValue("xmsspk-$id");
    await _securedStorageService.deleteValue("wallet-$id");
    List<int> walletIdList = await _getWalletIdList();
    walletIdList.removeWhere((element) => element == id);
    if (walletIdList.isNotEmpty) {
      await _sharedPreferenceService.setStringValue(
          "wallet-id-list", jsonEncode(walletIdList));
    } else {
      await _sharedPreferenceService.removeValue("wallet-id-list");
    }
    if (await getCurrentWalletId() == id) {
      if (walletIdList.isNotEmpty) {
        setCurrentWalletId(walletIdList.first);
      } else {
        await _sharedPreferenceService.removeValue("current-wallet-id");
      }
    }
  }

  Future<Wallet> createWallet(String name,
      {int? treeHeight,
      int? hashFunction,
      String? hexSeed,
      String? mnemonic}) async {
    String? createdWalletResult;
    if (treeHeight != null && hashFunction != null) {
      createdWalletResult = await compute<List<int>, String>(
          _ffiWalletService.ffiCreateWalletFromParams,
          [treeHeight, hashFunction]);
    } else if (hexSeed != null) {
      createdWalletResult = await compute<String, String>(
          _ffiWalletService.ffiOpenWalletWithHexSeed, hexSeed);
    } else if (mnemonic != null) {
      createdWalletResult = await compute<String, String>(
          _ffiWalletService.ffiOpenWalletWithMnemonic, mnemonic);
    }
    if (createdWalletResult == null) {
      throw Exception("Unknown error during creation of wallet");
    }
    return _saveWallet(name, createdWalletResult);
  }

  Future<Wallet> _saveWallet(String name, String createdWalletResult) async {
    List<int> walletIdList = await _getWalletIdList();
    int id = _generateRandomId(walletIdList);
    List<String> splitted = createdWalletResult.split("||");
    String hexSeed = splitted[0];
    String address = splitted[1];
    String xmsspk = splitted[2];
    int height = int.parse(splitted[3]);
    Wallet wallet = Wallet(id, name, address, height);
    await _securedStorageService.setValue("hexseed-$id", hexSeed);
    await _securedStorageService.setValue("xmsspk-$id", xmsspk);
    await _securedStorageService.setValue(
        "wallet-$id", jsonEncode(wallet.toJson()));
    walletIdList.add(id);
    await _sharedPreferenceService.setStringValue(
        "wallet-id-list", jsonEncode(walletIdList));
    if (await getCurrentWalletId() == null) {
      await setCurrentWalletId(id);
    }
    return wallet;
  }

  int _generateRandomId(List<int> walletIdList) {
    var nextInt = Random().nextInt(999999);
    if (walletIdList.contains(nextInt)) {
      return _generateRandomId(walletIdList);
    }
    return nextInt;
  }

  Future<String> getMnemonic(String hexSeed) async {
    return await compute<String, String>(
        _ffiWalletService.ffiGetMnemonic, hexSeed);
  }

  Future<String> getHexSeed(int id) async {
    String? hexSeed = await _securedStorageService.getValue("hexseed-$id");
    if (hexSeed == null) {
      throw Exception("No hexseed found for wallet id: $id");
    }
    return hexSeed;
  }

  Future<String> _getXmsspk(int id) async {
    String? xmsspk = await _securedStorageService.getValue("xmsspk-$id");
    if (xmsspk == null) {
      throw Exception("No xmsspk found for wallet id: $id");
    }
    return xmsspk;
  }

  Future<bool> isAddressValid(String address) async {
    return await compute<String, bool>(
        _ffiWalletService.ffiIsAddressValid,
        address.startsWith("Q")
            ? address.substring(1, address.length)
            : address);
  }

  Future<void> sendTransaction(int id, List<int> amounts, List<String> receiverWalletAddresses,
      int otsIndex, int fee) async {
    Wallet wallet = await getWallet(id);
    receiverWalletAddresses = receiverWalletAddresses.map((receiverWalletAddress) => receiverWalletAddress.startsWith("Q")
        ? receiverWalletAddress.substring(1, receiverWalletAddress.length)
        : receiverWalletAddress).toList();
    String transactionData = await compute<List<Object>, String>(
        _ffiWalletService.ffiCreateTransaction,
        [await getHexSeed(id), amounts, receiverWalletAddresses, otsIndex, fee]);
    await _grpcService.sendTransaction(wallet.address, await _getXmsspk(id),
        amounts, receiverWalletAddresses, otsIndex, fee, transactionData);
  }

  updateWalletName(int id, String name) async {
    Wallet wallet = await getWallet(id);
    wallet.name = name;
    await _securedStorageService.setValue(
        "wallet-$id", jsonEncode(wallet.toJson()));
  }
}
