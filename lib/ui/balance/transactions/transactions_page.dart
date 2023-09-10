import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mobile_wallet/model/notarization_message.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/balance/transactions/transaction_data_page.dart';
import 'package:mobile_wallet/ui/balance/transactions/transactions_bloc.dart';
import 'package:mobile_wallet/ui/component/middle_ellipsis_text.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/util/string_util.dart';

class TransactionsPage extends StatelessWidget {
  final Wallet _wallet;

  const TransactionsPage(this._wallet, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionsBloc>(
        create: (_) => TransactionsBloc(_wallet)..add(InitEvent()),
        child: const _TransactionsView());
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-4.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        appBar: QrlTitleAppBar(
          titleText: AppLocalizations.of(context)!.transactions,
        ),
        body: const TransactionsList(),
      ),
    );
  }
}

class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        if (state.status == TransactionsStatus.noTransactions) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(AppLocalizations.of(context)!.noTransactionsFound),
            ),
          );
        }
        if (state.status == TransactionsStatus.ready) {
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              List<TransactionData> transactions = state.transactions;
              if (index >= transactions.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: CustomColors.qrlYellowColor,
                      ),
                    ),
                  ),
                );
              }
              TransactionData transactionData = transactions[index];
              if (transactionData.transactionType == TransactionType.transfer) {
                return _buildTransferTransaction(transactionData, context);
              } else if (transactionData.transactionType ==
                  TransactionType.token) {
                return _buildTokenTransaction(transactionData, context);
              } else if (transactionData.transactionType ==
                  TransactionType.transferToken) {
                return _buildTransferTokenTransaction(transactionData, context);
              }
              return _buildMessageTransaction(transactionData, context);
            },
            itemCount: state.hasReachedMax
                ? state.transactions.length
                : state.transactions.length + 1,
            controller: _scrollController,
          );
        }
        return Center(
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
                Text(AppLocalizations.of(context)!.loadingTransactions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransferTransaction(
      TransactionData transactionData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        elevation: 1,
        color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
        child: ListTile(
          horizontalTitleGap: 10,
          leading: SizedBox(
            height: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CustomColors.qrlYellowColor)),
              child: Icon(
                transactionData.incoming
                    ? Icons.arrow_back
                    : Icons.arrow_forward,
                color: CustomColors.qrlYellowColor,
                size: 28,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Text(
                        transactionData.incoming
                            ? AppLocalizations.of(context)!
                                .received
                                .toUpperCase()
                            : AppLocalizations.of(context)!.sent.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomColors.qrlLightBlueColor,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        transactionData.unconfirmed
                            ? AppLocalizations.of(context)!.unconfirmed
                            : "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color:
                              CustomColors.qrlYellowMaterial.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat("HH:mm, MMM d yyyy")
                      .format(transactionData.dateTime),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                )
              ],
            ),
          ),
          isThreeLine: true,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${transactionData.incoming ? "+" : "-"} ${StringUtil.formatAmount(transactionData.amount!)} QRL",
                overflow: TextOverflow.ellipsis,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: MiddleEllipsisText(
                  transactionData.incoming
                      ? transactionData.senderAddress
                      : transactionData.receiverAddress!,
                ),
              ),
            ],
          ),
          dense: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionDetailPage(transactionData)),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenTransaction(
      TransactionData transactionData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        elevation: 1,
        color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
        child: ListTile(
          horizontalTitleGap: 10,
          leading: SizedBox(
            height: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CustomColors.qrlYellowColor)),
              child: const Icon(
                Icons.token_outlined,
                color: CustomColors.qrlYellowColor,
                size: 28,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        transactionData.unconfirmed
                            ? AppLocalizations.of(context)!.unconfirmed
                            : "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color:
                              CustomColors.qrlYellowMaterial.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat("HH:mm, MMM d yyyy")
                      .format(transactionData.dateTime),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                )
              ],
            ),
          ),
          subtitle: Text(
            "${transactionData.tokenName} (${transactionData.tokenSymbol})",
            overflow: TextOverflow.ellipsis,
          ),
          dense: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionDetailPage(transactionData)),
          ),
        ),
      ),
    );
  }

  Widget _buildTransferTokenTransaction(
      TransactionData transactionData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        elevation: 1,
        color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
        child: ListTile(
          horizontalTitleGap: 10,
          leading: SizedBox(
            height: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CustomColors.qrlYellowColor)),
              child: Icon(
                transactionData.incoming
                    ? Icons.arrow_back
                    : Icons.arrow_forward,
                color: CustomColors.qrlYellowColor,
                size: 28,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Text(
                        transactionData.incoming
                            ? AppLocalizations.of(context)!.tokenReceived
                            : AppLocalizations.of(context)!.tokenSent,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CustomColors.qrlLightBlueColor,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        transactionData.unconfirmed
                            ? AppLocalizations.of(context)!.unconfirmed
                            : "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color:
                              CustomColors.qrlYellowMaterial.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat("HH:mm, MMM d yyyy")
                      .format(transactionData.dateTime),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                )
              ],
            ),
          ),
          isThreeLine: true,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${transactionData.incoming ? "+" : "-"} ${StringUtil.formatAmount(transactionData.amount!, decimals: transactionData.tokenDecimals!)} ${transactionData.tokenSymbol}",
                overflow: TextOverflow.ellipsis,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: MiddleEllipsisText(
                  transactionData.incoming
                      ? transactionData.senderAddress
                      : transactionData.receiverAddress!,
                ),
              ),
            ],
          ),
          dense: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionDetailPage(transactionData)),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTransaction(
      TransactionData transactionData, BuildContext context) {
    String header;
    String label;
    IconData iconData;
    if (transactionData.messageType == MessageType.text) {
      header = AppLocalizations.of(context)!.message.toUpperCase();
      label = transactionData.message ?? "";
      iconData = Icons.message_outlined;
    } else {
      NotarizationMessage? notarizationMessage =
          NotarizationMessage.fromTransactionData(transactionData);
      if (notarizationMessage != null) {
        header = AppLocalizations.of(context)!.notarization.toUpperCase();
        label = notarizationMessage.additionalMessage.isNotEmpty
            ? notarizationMessage.additionalMessage
            : notarizationMessage.fileHash;
        iconData = Icons.note_add_outlined;
      } else {
        header = AppLocalizations.of(context)!.message.toUpperCase();
        label = transactionData.message ?? "";
        iconData = Icons.message_outlined;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Card(
        elevation: 1,
        color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
        child: ListTile(
          horizontalTitleGap: 10,
          leading: SizedBox(
            height: double.infinity,
            child: Icon(
              iconData,
              color: CustomColors.qrlYellowColor,
              size: 28,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        transactionData.unconfirmed
                            ? AppLocalizations.of(context)!.unconfirmed
                            : "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color:
                              CustomColors.qrlYellowMaterial.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat("HH:mm, MMM d yyyy")
                      .format(transactionData.dateTime),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                )
              ],
            ),
          ),
          subtitle: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
          dense: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionDetailPage(transactionData)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionsBloc>().add(FindTransactionsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
