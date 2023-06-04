import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';
import 'package:mobile_wallet/util/string_util.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionData _transactionData;

  const TransactionDetailPage(this._transactionData, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-5.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        appBar: QrlTitleAppBar(
            titleText: AppLocalizations.of(context)!.transaction),
        body: Column(mainAxisSize: MainAxisSize.max, children: [
          Expanded(
            child: NotificationListener(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ListView(
                  children: [
                    Card(
                      elevation: 1,
                      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                _transactionData.type,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                "${StringUtil.formatAmount(_transactionData.amount)} QRL",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CustomColors.qrlLightBlueColor,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_transactionData.message != null)
                      Card(
                        elevation: 1,
                        color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  AppLocalizations.of(context)!.message,
                                  style: const TextStyle(
                                    color: CustomColors.qrlYellowColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SelectableText(
                                  _transactionData.message!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Card(
                      elevation: 1,
                      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                AppLocalizations.of(context)!.fromAddress,
                                style: const TextStyle(
                                  color: CustomColors.qrlYellowColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SelectableText(
                                "Q${_transactionData.senderAddress}",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                AppLocalizations.of(context)!.toAddress,
                                style: const TextStyle(
                                  color: CustomColors.qrlYellowColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SelectableText(
                                "Q${_transactionData.receiverAddress}",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Text(
                                AppLocalizations.of(context)!.transactionHash,
                                style: const TextStyle(
                                  color: CustomColors.qrlYellowColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: SelectableText(
                                _transactionData.hash,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: SizedBox(
                width: 256,
                child: QrlButton(
                  () async {
                    Uri url = Uri.parse(
                        "https://explorer.theqrl.org/tx/${_transactionData.hash}");
                    await Util.launchInBrowser(url);
                  },
                  text: AppLocalizations.of(context)!.openInExplorer,
                  baseColor: CustomColors.qrlLightBlueColor,
                  backgroundColor: CustomColors.qrlLightBlueColorBackground,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
