import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';

class InputFormatter {
  static FilteringTextInputFormatter getIntFormatter() {
    return FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  }

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

  static FilteringTextInputFormatter getNumberDotFormatter({int decimals = 9}) {
    return FilteringTextInputFormatter.allow(
        RegExp(r'^\d+\.?\d{0,' + decimals.toString() + '}'));
  }

  static TextInputFormatter getMaxValueFormatter({int decimals = 9}) {
    return TextInputFormatter.withFunction(
      (oldValue, newValue) {
        if (newValue.text.isNotEmpty) {
          if (!(Decimal.parse(newValue.text) *
                  BigInt.from(10).pow(decimals).toDecimal())
              .toBigInt()
              .isValidInt) {
            return newValue.copyWith(
              selection: const TextSelection.collapsed(offset: 20),
              composing: TextRange.empty,
              text: (Decimal.fromInt(9223372036854775807) /
                      BigInt.from(10).pow(decimals).toDecimal())
                  .toDecimal()
                  .toString(),
            );
          }
        }
        return newValue;
      },
    );
  }
}
