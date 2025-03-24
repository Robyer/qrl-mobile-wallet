import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveAmountPage extends StatelessWidget {
  final Wallet _currentWallet;

  const ReceiveAmountPage(this._currentWallet, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-2.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        appBar: QrlTitleAppBar(
          titleText: AppLocalizations.of(context)!.receiveTitle,
        ),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(
                    top: 24, left: 24, right: 24, bottom: 32),
                child: SelectableText(
                  "Q${_currentWallet.address}",
                  textAlign: TextAlign.center,
                ),
              )),
              Center(
                child: QrImageView(
                  data: "Q${_currentWallet.address}",
                  version: QrVersions.auto,
                  backgroundColor: Colors.transparent,
                  size: 216.0,
                  eyeStyle: const QrEyeStyle(
                      color: Colors.grey, eyeShape: QrEyeShape.square),
                  dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.grey),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: SizedBox(
                      width: 256,
                      child: QrlButton(
                        () async {
                          Clipboard.setData(ClipboardData(
                                  text: "Q${_currentWallet.address}"))
                              .then((value) {
                            SnackBars.showSnackBar(
                                context,
                                AppLocalizations.of(context)!
                                    .copiedToClipboard);
                          });
                        },
                        text: AppLocalizations.of(context)!.copy,
                        baseColor: CustomColors.qrlLightBlueColor,
                        backgroundColor:
                            CustomColors.qrlLightBlueColorBackground,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
