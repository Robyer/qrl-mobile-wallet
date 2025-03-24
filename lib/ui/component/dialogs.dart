import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class Dialogs {
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: CustomColors.qrlYellowColor),
            ),
            backgroundColor: CustomColors.qrlDarkBlueColor,
            child: Container(
              decoration: BoxDecoration(
                gradient: CustomColors.qrlDarkBlueLinearGradient,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: CustomColors.qrlYellowColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(message),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void showConfirmDialog(
      BuildContext context, String message, VoidCallback onConfirm,
      {String? header, String? checkboxLabel}) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        bool isChecked = false;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: CustomColors.qrlYellowColor),
            ),
            backgroundColor: CustomColors.qrlDarkBlueColor,
            child: Container(
              decoration: BoxDecoration(
                gradient: CustomColors.qrlDarkBlueLinearGradient,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (header != null)
                  Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      header,
                      style: const TextStyle(
                        color: CustomColors.qrlLightBlueColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.only(
                      top: 24, left: 24, right: 24, bottom: 16),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (checkboxLabel != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SwitchListTile(
                        activeColor: CustomColors.qrlLightBlueColor,
                        visualDensity: VisualDensity.compact,
                        title: Text(
                          checkboxLabel,
                          style: const TextStyle(fontSize: 13),
                        ),
                        onChanged: (value) => setState(() {
                              isChecked = value;
                            }),
                        value: isChecked),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: QrlButton(
                          () {
                            Navigator.of(context).pop();
                          },
                          text: AppLocalizations.of(context)!.cancel,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: QrlButton(
                        (checkboxLabel != null && !isChecked)
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                onConfirm();
                              },
                        text: AppLocalizations.of(context)!.confirm,
                        baseColor: CustomColors.qrlLightBlueColor,
                        backgroundColor:
                            CustomColors.qrlLightBlueColorBackground,
                      )),
                    ],
                  ),
                ),
              ]),
            ),
          );
        });
      },
    );
  }
}
