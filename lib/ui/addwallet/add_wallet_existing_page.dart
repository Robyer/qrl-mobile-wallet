import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_data_page.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class AddWalletExistingPage extends StatelessWidget {
  const AddWalletExistingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QrlAppBar(),
      body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context)!.walletSetup,
                    style: const TextStyle(
                      color: CustomColors.qrlLightBlueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
              ),
            ),
            Center(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(AppLocalizations.of(context)!.openExistingWallet),
            )),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 256,
                  child: QrlButton(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddWalletDataPage(
                                AddWalletMode.mnemonic)),
                      );
                    },
                    text: AppLocalizations.of(context)!.openWithMnemonics,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 256,
                  child: QrlButton(
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddWalletDataPage(AddWalletMode.hexSeed)),
                      );
                    },
                    text: AppLocalizations.of(context)!.openWithHexseed,
                  ),
                ),
              ),
            ),
          ]),
    );
  }
}
