import 'package:mobile_wallet/service/secured_storage_service.dart';
import 'package:mockito/mockito.dart';

class MockSecuredStorageService extends Mock implements SecuredStorageService {
  final Map<String, String> _mockStorage = {};

  @override
  Future<void> setValue(String key, String value) async {
    _mockStorage[key] = value;
  }

  @override
  Future<String?> getValue(String key) async {
    return _mockStorage[key];
  }

  @override
  Future<void> deleteValue(String key) async {
    _mockStorage.remove(key);
  }
}
