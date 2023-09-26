import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mobile_wallet/model/notarization_message.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/util/component_util.dart';
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
                    _buildMainCard(context),
                    ComponentUtil.buildLabelValueCard(
                        AppLocalizations.of(context)!.transactionHash,
                        _transactionData.hash),
                    ComponentUtil.buildLabelValueCard(
                        AppLocalizations.of(context)!.fromAddress,
                        "Q${_transactionData.senderAddress}"),
                    if (_transactionData.receiverAddress != null)
                      ComponentUtil.buildLabelValueCard(
                          AppLocalizations.of(context)!.toAddress,
                          "Q${_transactionData.receiverAddress}"),
                    if (_transactionData.transactionType !=
                            TransactionType.message &&
                        _transactionData.message != null)
                      ComponentUtil.buildLabelValueCard(
                          AppLocalizations.of(context)!.message,
                          _transactionData.message!),
                    ..._buildExtraDataWidgets(context),
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

  Widget _buildMainCard(BuildContext context) {
    if (_transactionData.transactionType == TransactionType.transfer) {
      return _buildTransferCard(context);
    } else if (_transactionData.transactionType == TransactionType.message) {
      return _buildMessageCard(context);
    } else if (_transactionData.transactionType == TransactionType.token) {
      return _buildTokenCard(context);
    } else if (_transactionData.transactionType ==
        TransactionType.transferToken) {
      return _buildTransferTokenCard(context);
    }
    return Container();
  }

  Card _buildTransferCard(BuildContext context) {
    return Card(
      elevation: 1,
      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
      child: ListTile(
        isThreeLine: true,
        horizontalTitleGap: 10,
        leading: SizedBox(
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CustomColors.qrlYellowColor)),
            child: Icon(
              _transactionData.incoming
                  ? Icons.arrow_back
                  : Icons.arrow_forward,
              color: CustomColors.qrlYellowColor,
              size: 28,
            ),
          ),
        ),
        subtitle: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Text(
                          _transactionData.incoming
                              ? AppLocalizations.of(context)!
                                  .received
                                  .toUpperCase()
                              : AppLocalizations.of(context)!
                                  .sent
                                  .toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomColors.qrlLightBlueColor,
                          )),
                      _buildUnconfirmedWidget(context),
                    ],
                  ),
                  _buildDateWidget()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "${_transactionData.incoming ? "+" : "-"} ${StringUtil.formatAmount(_transactionData.amount!)} QRL",
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _transactionData.type.toUpperCase(),
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.fee} ",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    "${StringUtil.formatAmount(_transactionData.fee)} QRL",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildMessageCard(BuildContext context) {
    String header;
    String label;
    IconData iconData;
    if (_transactionData.messageType == MessageType.text) {
      header = AppLocalizations.of(context)!.message.toUpperCase();
      label = _transactionData.message ?? "";
      iconData = Icons.message_outlined;
    } else {
      NotarizationMessage? notarizationMessage =
          NotarizationMessage.fromTransactionData(_transactionData);
      if (notarizationMessage != null) {
        header = AppLocalizations.of(context)!.notarization.toUpperCase();
        label = notarizationMessage.additionalMessage.isNotEmpty
            ? notarizationMessage.additionalMessage
            : notarizationMessage.fileHash;
        iconData = Icons.note_add_outlined;
      } else {
        header = AppLocalizations.of(context)!.message.toUpperCase();
        label = _transactionData.message ?? "";
        iconData = Icons.message_outlined;
      }
    }
    return Card(
      elevation: 1,
      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
      child: ListTile(
        horizontalTitleGap: 10,
        isThreeLine: true,
        leading: SizedBox(
          height: double.infinity,
          child: Icon(
            iconData,
            color: CustomColors.qrlYellowColor,
            size: 28,
          ),
        ),
        subtitle: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Text(header,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomColors.qrlLightBlueColor,
                          )),
                      _buildUnconfirmedWidget(context),
                    ],
                  ),
                  _buildDateWidget()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.fee} ",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    "${StringUtil.formatAmount(_transactionData.fee)} QRL",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildTokenCard(BuildContext context) {
    return Card(
      elevation: 1,
      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
      child: ListTile(
        horizontalTitleGap: 10,
        isThreeLine: true,
        leading: const SizedBox(
          height: double.infinity,
          child: Icon(
            Icons.token_outlined,
            color: CustomColors.qrlYellowColor,
            size: 28,
          ),
        ),
        subtitle: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.tokenCreation,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomColors.qrlLightBlueColor,
                          )),
                      _buildUnconfirmedWidget(context),
                    ],
                  ),
                  _buildDateWidget()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${_transactionData.tokenName} (${_transactionData.tokenSymbol})",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.fee} ",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    "${StringUtil.formatAmount(_transactionData.fee)} QRL",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildTransferTokenCard(BuildContext context) {
    return Card(
      elevation: 1,
      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
      child: ListTile(
        isThreeLine: true,
        horizontalTitleGap: 10,
        leading: SizedBox(
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CustomColors.qrlYellowColor)),
            child: Icon(
              _transactionData.incoming
                  ? Icons.arrow_back
                  : Icons.arrow_forward,
              color: CustomColors.qrlYellowColor,
              size: 28,
            ),
          ),
        ),
        subtitle: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Text(
                          _transactionData.incoming
                              ? AppLocalizations.of(context)!.tokenReceived
                              : AppLocalizations.of(context)!.tokenSent,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: CustomColors.qrlLightBlueColor,
                          )),
                      _buildUnconfirmedWidget(context),
                    ],
                  ),
                  _buildDateWidget()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "${_transactionData.incoming ? "+" : "-"} ${StringUtil.formatAmount(_transactionData.amount!, decimals: _transactionData.tokenDecimals!)} ${_transactionData.tokenSymbol}",
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _transactionData.type.toUpperCase(),
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.fee} ",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    "${StringUtil.formatAmount(_transactionData.fee)} QRL",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildUnconfirmedWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        _transactionData.unconfirmed
            ? AppLocalizations.of(context)!.unconfirmed
            : "",
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: CustomColors.qrlYellowMaterial.withOpacity(0.5),
        ),
      ),
    );
  }

  Text _buildDateWidget() {
    return Text(
      DateFormat("HH:mm, MMM d yyyy").format(_transactionData.dateTime),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.grey[500],
      ),
    );
  }

  List<Widget> _buildExtraDataWidgets(BuildContext context) {
    if (_transactionData.messageType == MessageType.hex) {
      NotarizationMessage? notarizationMessage =
          NotarizationMessage.fromTransactionData(_transactionData);
      if (notarizationMessage != null) {
        return [
          ComponentUtil.buildLabelValueCard(
              AppLocalizations.of(context)!.fileHash,
              notarizationMessage.fileHash ?? ""),
          ComponentUtil.buildLabelValueCard(
              AppLocalizations.of(context)!.hashFunction,
              Util.notarizationHashFunctions[
                      notarizationMessage.hashFunction] ??
                  ""),
        ];
      }
    } else if (_transactionData.transactionType ==
        TransactionType.transferToken) {
      return [
        ComponentUtil.buildLabelValueCard(
            AppLocalizations.of(context)!.tokenTransactionHash,
            _transactionData.tokenHash ?? ""),
      ];
    } else if (_transactionData.transactionType == TransactionType.token) {
      return [
        ComponentUtil.buildLabelValueCard(
            AppLocalizations.of(context)!.ownerAddress,
            _transactionData.tokenOwnerAddress ?? ""),
        ...buildInitialHolderComponents(context)
      ];
    }
    return [];
  }

  List<Card> buildInitialHolderComponents(BuildContext context) {
    return (_transactionData.initialTokenHolders ?? [])
        .map((initialHolder) => Card(
              elevation: 1,
              color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        AppLocalizations.of(context)!.holderAddress,
                        style: const TextStyle(
                          color: CustomColors.qrlYellowColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SelectableText(
                        initialHolder.address ?? "",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        AppLocalizations.of(context)!.initialBalance,
                        style: const TextStyle(
                          color: CustomColors.qrlYellowColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        StringUtil.formatAmount(initialHolder.amount,
                            decimals: _transactionData.tokenDecimals!),
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }
}
