import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

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

  static RichText buildRichTextWithLinks(String text, List<String> links) {
    int linkIndex = 0;
    final RegExp regExp = RegExp(r"<link>(.*?)</link>");
    int currentIndex = 0;
    List<TextSpan> spans = [];

    for (final match in regExp.allMatches(text)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }
      final linkText = match.group(1);
      String? url;
      if (linkIndex < links.length) {
        url = links[linkIndex];
      }
      spans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(
            decoration: TextDecoration.underline,
            color: CustomColors.qrlYellowColor
          ),
          recognizer: url != null
              ? (TapGestureRecognizer()
                ..onTap = () async {
                  await Util.launchInBrowser(Uri.parse(url!));
                })
              : null,
        ),
      );
      linkIndex++;
      currentIndex = match.end;
    }
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }
    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: "Roboto-Medium",
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}
