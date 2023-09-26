import 'package:decimal/decimal.dart';

class MarketData {
  final Decimal price;
  final Decimal marketCap;
  final Decimal change24Hr;

  const MarketData(
    this.price,
    this.marketCap,
    this.change24Hr,
  );

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      Decimal.parse(json['price'].toString()),
      Decimal.parse(json['market_cap'].toString()),
      Decimal.parse(json['change_24hr'].toString()),
    );
  }
}
