import 'dart:math';

import 'package:decimal/decimal.dart';

class StringUtil {
  static String reverse(String toReverse) {
    StringBuffer stringBuffer = StringBuffer();
    for (var i = toReverse.length - 1; i >= 0; --i) {
      stringBuffer.write(toReverse[i]);
    }
    return stringBuffer.toString();
  }

  static String formatAmount(int amount, {int decimals = 9}) {
    if (amount <= 0) {
      return "0";
    }
    return (Decimal.fromInt(amount) / BigInt.from(10).pow(decimals).toDecimal())
        .toDecimal()
        .toString();
  }

  static List<int> toBytes(String data) {
    List<int> byteData = List.filled(data.length ~/ 2, 0);
    for (int i = 0; i < data.length; i += 2) {
      byteData[i ~/ 2] = (int.parse(data[i], radix: 16) << 4) +
          int.parse(data[i + 1], radix: 16);
    }
    return byteData;
  }

  static String fromBytes(List<int> bytes) {
    return bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  static List<int> toBigEndianUint64BytesUnsigned(int value) {
    List<int> bytes = [0, 0, 0, 0, 0, 0, 0, 0];
    for (int i = 0; i < 8; i++) {
      bytes[7 - i] = (value >> (i * 8)) & 0xFF;
    }
    return bytes;
  }
}
