import 'package:flutter/material.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class ComponentUtil {
  static Card buildLabelValueCard(String label, String value) {
    return Card(
      elevation: 1,
      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(label,
                  style: const TextStyle(
                    color: CustomColors.qrlYellowColor,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: SelectableText(
                value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
