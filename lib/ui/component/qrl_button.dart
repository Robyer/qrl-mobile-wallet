import 'package:flutter/material.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class QrlButton extends OutlinedButton {
  final VoidCallback? _onPressed;
  static const Color _defaultColor = CustomColors.qrlYellowColor;
  static const Color _defaultBackgroundColor = CustomColors.qrlYellowColorBackground;

  QrlButton(this._onPressed, {super.key, String? text, Color? baseColor, Color? backgroundColor})
      : super(
          style: OutlinedButton.styleFrom(
              side: BorderSide(color: baseColor ?? _defaultColor, width: 1),
              foregroundColor: baseColor ?? _defaultColor,
              backgroundColor: (backgroundColor ?? _defaultBackgroundColor),
              disabledForegroundColor:
                  baseColor?.withOpacity(0.5) ?? _defaultColor.withOpacity(0.5),
              disabledBackgroundColor:
                  (backgroundColor ?? _defaultBackgroundColor).withOpacity(0.5)),
          onPressed: _onPressed,
          child: Text(text ?? ""),
        );
}
