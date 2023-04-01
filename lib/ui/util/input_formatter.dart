import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';

class InputFormatter {
  static FilteringTextInputFormatter getNumberFormatter() {
    return FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*'));
  }

  static TextInputFormatter getCommaDotFormatter() {
    return TextInputFormatter.withFunction(
      (oldValue, newValue) => newValue.copyWith(
        text: newValue.text.replaceAll(',', '.'),
      ),
    );
  }

  static FilteringTextInputFormatter getNumberDotFormatter() {
    return FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,9}'));
  }

  static TextInputFormatter getMaxValueFormatter() {
    return TextInputFormatter.withFunction(
      (oldValue, newValue) {
        if (newValue.text.isNotEmpty) {
          if (!(Decimal.parse(newValue.text) * Decimal.fromInt(1000000000))
              .toBigInt()
              .isValidInt) {
            return newValue.copyWith(
              // max range 64bit integer result we can handle
              text: "9223372036.854775807",
            );
          }
        }
        return newValue;
      },
    );
  }
}
