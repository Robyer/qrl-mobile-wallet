import 'package:mobile_wallet/service/ffi_wallet_service.dart';
import 'package:mockito/mockito.dart';

class MockFfiWalletService extends Mock implements FfiWalletService {
  @override
  String ffiCreateWalletFromParams(List<int> params) {
    return "hex||address||xmspkk||1";
  }

  @override
  String ffiGetMnemonic(String hexSeed) {
    return "mnemonic";
  }

  @override
  String ffiOpenWalletWithHexSeed(String hexSeed) {
    return "hex||address||xmspkk||1";
  }

  @override
  String ffiOpenWalletWithMnemonic(String mnemonic) {
    return "hex||address||xmspkk||1";
  }

  @override
  bool ffiIsAddressValid(String address) {
    return true;
  }

  @override
  String ffiCreateTransaction(List<Object> params) {
    return "transactionData";
  }
}
