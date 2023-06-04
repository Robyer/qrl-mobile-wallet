import 'package:decimal/decimal.dart';
import 'package:mobile_wallet/model/market_data.dart';
import 'package:mobile_wallet/service/market_service.dart';
import 'package:mockito/mockito.dart';

class MockMarketService extends Mock implements MarketService {
  @override
  Future<MarketData?> getMarketData() async {
    return Future(() =>
        MarketData(Decimal.ten, Decimal.fromInt(1000000000), Decimal.one));
  }
}
