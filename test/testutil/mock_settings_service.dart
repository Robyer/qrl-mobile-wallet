import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mockito/mockito.dart';

class MockSettingsService extends Mock implements SettingsService {
  Future<void> updateFeeSetting(int fee) async {
    return Future(() => {});
  }

  Future<int> getFeeSetting() async {
    return Future(() => 1000000);
  }
}
