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
    Decimal parseDecimal(dynamic value) {
      if (value != null) {
        try {
          return Decimal.parse(value.toString());
        } catch (e) {
          return Decimal.zero;
        }
      }
      return Decimal.zero;
    }

    return MarketData(
      parseDecimal(json['price']),
      parseDecimal(json['market_cap']),
      parseDecimal(json['change_24hr']),
    );
  }
}
