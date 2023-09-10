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
      : DynamicLibrary.process();
  return walletLib;
}

String _ffiCreateWalletFromParams(List<int> params) {
  Pointer<Utf8> Function(int treeHeight, int hashFunction) nativeCreateWallet =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Int64, Int64)>>(
              "createWallet")
          .asFunction();
  Pointer<Utf8> resultPtr = nativeCreateWallet(params[0], params[1]);
  String result = resultPtr.toDartString();
  calloc.free(resultPtr);
  return result;
}

String _ffiGetMnemonic(String hexSeed) {
  Pointer<Utf8> nativeHexSeed = hexSeed.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> hexSeed) nativeGetMnemonic =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "getMnemonic")
          .asFunction();
  Pointer<Utf8> mnemonicPtr = nativeGetMnemonic(nativeHexSeed);
  String mnemonic = mnemonicPtr.toDartString();
  calloc.free(nativeHexSeed);
  calloc.free(mnemonicPtr);
  return mnemonic;
}

String _ffiOpenWalletWithHexSeed(String hexSeed) {
  Pointer<Utf8> nativeHexSeed = hexSeed.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> hexSeed) nativeOpenWalletWithHexSeed =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "openWalletWithHexSeed")
          .asFunction();
  Pointer<Utf8> resultPtr = nativeOpenWalletWithHexSeed(nativeHexSeed);
  String result = resultPtr.toDartString();
  calloc.free(nativeHexSeed);
  calloc.free(resultPtr);
  return result;
}

String _ffiOpenWalletWithMnemonic(String mnemonic) {
  Pointer<Utf8> nativeMnemonic = mnemonic.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> hexSeed) nativeOpenWalletWithMnemonic =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "openWalletWithMnemonic")
          .asFunction();
  Pointer<Utf8> resultPtr = nativeOpenWalletWithMnemonic(nativeMnemonic);
  String result = resultPtr.toDartString();
  calloc.free(nativeMnemonic);
  calloc.free(resultPtr);
  return result;
}

bool _ffiIsAddressValid(String address) {
  Pointer<Utf8> nativeAddress = address.toNativeUtf8();
  Pointer<Utf8> Function(Pointer<Utf8> address) nativeIsAddressValid =
      _openWalletLib()
          .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
              "isAddressValid")
          .asFunction();
  Pointer<Utf8> resultPtr = nativeIsAddressValid(nativeAddress);
  String result = resultPtr.toDartString();
  calloc.free(nativeAddress);
  calloc.free(resultPtr);
  return result == "valid";
}

String _ffiCreateTransaction(List<Object> params) {
  Pointer<Utf8> nativeHexSeed = (params[0] as String).toNativeUtf8();
  List<int> concatenatedArray = (params[1] as List<int>);
  int otsIndex = params[2] as int;

  Pointer<Utf8> Function(
    Pointer<Utf8> hexSeed,
    Pointer<Uint8> concatenatedArray,
    int concatenatedArrayLength,
    int otsIndex,
  ) nativeCreateTransaction = _openWalletLib()
      .lookup<
          NativeFunction<
              Pointer<Utf8> Function(
        Pointer<Utf8>,
        Pointer<Uint8>,
        Int64,
        Int64,
      )>>("createTransaction")
      .asFunction();

  final concatenatedArrayPtr = malloc<Uint8>(concatenatedArray.length);
  for (int i = 0; i < concatenatedArray.length; i++) {
    concatenatedArrayPtr[i] = concatenatedArray[i];
  }

  Pointer<Utf8> resultPtr = nativeCreateTransaction(
    nativeHexSeed,
    concatenatedArrayPtr,
    concatenatedArray.length,
    otsIndex,
  );

  String result = resultPtr.toDartString();

  malloc.free(nativeHexSeed);
  malloc.free(concatenatedArrayPtr);
  calloc.free(resultPtr);

  return result;
}
