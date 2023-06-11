import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_data_page.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

enum AddWalletMode { hexSeed, mnemonic, create }

class AddWalletPage extends StatelessWidget {
  const AddWalletPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-1.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        appBar: QrlAppBar(),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/qrl-tree.png',
                height: 240,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(AppLocalizations.of(context)!.welcomeTo,
                      style: const TextStyle(
                        color: CustomColors.qrlYellowColor,
                        fontSize: 16,
                      )),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(AppLocalizations.of(context)!.ledger,
                      style: const TextStyle(
                        color: CustomColors.qrlYellowColor,
                        fontSize: 16,
                      )),
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Text(AppLocalizations.of(context)!.onBoard),
              )),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: SizedBox(
                    width: 172,
                    child: QrlButton(
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddWalletDataPage(
                                  AddWalletMode.create)),
                        );
                      },
                      text: AppLocalizations.of(context)!.createWallet,
                      baseColor: CustomColors.qrlLightBlueColor,
                      backgroundColor: CustomColors.qrlLightBlueColorBackground,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: SizedBox(
                    width: 172,
                    child: QrlButton(
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddWalletDataPage(
                                  AddWalletMode.mnemonic)),
                        );
                      },
                      text: AppLocalizations.of(context)!.addWallet,
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
