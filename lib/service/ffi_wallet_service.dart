import 'dart:ffi';
import 'dart:io';

import "package:ffi/ffi.dart";

class FfiWalletService {
  String ffiCreateWalletFromParams(List<int> params) {
    return _ffiCreateWalletFromParams(params);
  }

  String ffiGetMnemonic(String hexSeed) {
    return _ffiGetMnemonic(hexSeed);
  }

  String ffiOpenWalletWithHexSeed(String hexSeed) {
    return _ffiOpenWalletWithHexSeed(hexSeed);
  }

  String ffiOpenWalletWithMnemonic(String mnemonic) {
    return _ffiOpenWalletWithMnemonic(mnemonic);
  }

  bool ffiIsAddressValid(String address) {
    return _ffiIsAddressValid(address);
  }

  String ffiCreateTransaction(List<Object> params) {
    return _ffiCreateTransaction(params);
  }
}

DynamicLibrary _openWalletLib() {
  DynamicLibrary walletLib = Platform.isAndroid
      ? DynamicLibrary.open("libwallet.so")
      : DynamicLibrary.open("wallet.framework/wallet");
  return walletLib;
}

String _ffiCreateWalletFromParams(List<int> params) {
  Pointer<Utf8> Function(int treeHeight, int hashFunction) nativeCreateWallet =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Int64, Int64)>>(
              "createWallet")
          .asFunction();
  return nativeCreateWallet(params[0], params[1]).toDartString();
}

String _ffiGetMnemonic(String hexSeed) {
  Pointer<Utf8> nativeHexSeed = hexSeed.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> hexSeed) nativeGetMnemonic =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "getMnemonic")
          .asFunction();
  String mnemonic = nativeGetMnemonic(nativeHexSeed).toDartString();
  malloc.free(nativeHexSeed);
  return mnemonic;
}

String _ffiOpenWalletWithHexSeed(String hexSeed) {
  Pointer<Utf8> nativeHexSeed = hexSeed.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> hexSeed) nativeOpenWalletWithHexSeed =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "openWalletWithHexSeed")
          .asFunction();
  String result = nativeOpenWalletWithHexSeed(nativeHexSeed).toDartString();
  malloc.free(nativeHexSeed);
  return result;
}

String _ffiOpenWalletWithMnemonic(String mnemonic) {
  Pointer<Utf8> nativeMnemonic = mnemonic.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> hexSeed) nativeOpenWalletWithMnemonic =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "openWalletWithMnemonic")
          .asFunction();
  String result = nativeOpenWalletWithMnemonic(nativeMnemonic).toDartString();
  malloc.free(nativeMnemonic);
  return result;
}

bool _ffiIsAddressValid(String address) {
  Pointer<Utf8> nativeAddress = address.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> address) nativeIsAddressValid =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "isAddressValid")
          .asFunction();
  String result = nativeIsAddressValid(nativeAddress).toDartString();
  malloc.free(nativeAddress);
  return result == "valid";
}

String _ffiCreateTransaction(List<Object> params) {
  Pointer<Utf8> nativeHexSeed = (params[0] as String).toNativeUtf8();
  List<int> amounts = (params[1] as List<int>);
  List<String> receiverWalletAddresses = (params[2] as List<String>);
  int otsIndex = params[3] as int;
  int fee = params[4] as int;
  int transactionCount = amounts.length;

  Pointer<Utf8> Function(
          Pointer<Utf8> hexSeed,
          Pointer<Int64> amounts,
          Pointer<Pointer<Utf8>> receiverWalletAddresses,
          int transactionCount,
          int otsIndex,
          int fee) nativeCreateTransaction =
      _openWalletLib()
          .lookup<
              NativeFunction<
                  Pointer<Utf8> Function(
                      Pointer<Utf8>,
                      Pointer<Int64>,
                      Pointer<Pointer<Utf8>>,
                      Int32,
                      Int64,
                      Int64)>>("createTransaction")
          .asFunction();

  final amountsPtr = malloc<Int64>(transactionCount);
  for (int i = 0; i < transactionCount; i++) {
    amountsPtr[i] = amounts[i];
  }

  final receiverWalletAddressesPtr = malloc<Pointer<Utf8>>(transactionCount);
  for (int i = 0; i < transactionCount; i++) {
    receiverWalletAddressesPtr[i] = receiverWalletAddresses[i].toNativeUtf8();
  }

  String result = nativeCreateTransaction(nativeHexSeed, amountsPtr,
          receiverWalletAddressesPtr, transactionCount, otsIndex, fee)
      .toDartString();

  malloc.free(nativeHexSeed);
  for (int i = 0; i < transactionCount; i++) {
    malloc.free(receiverWalletAddressesPtr[i]);
  }
  malloc.free(receiverWalletAddressesPtr);
  malloc.free(amountsPtr);

  return result;
}
