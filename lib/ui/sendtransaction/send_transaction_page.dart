import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/sendtransaction/addressbook/addentry/add_entry_bloc.dart';
import 'package:mobile_wallet/ui/sendtransaction/addressbook/addentry/add_entry_view.dart';
import 'package:mobile_wallet/ui/sendtransaction/bloc/send_transaction_bloc.dart';
import 'package:mobile_wallet/ui/sendtransaction/changefee/change_fee_bloc.dart';
import 'package:mobile_wallet/ui/sendtransaction/changefee/change_fee_view.dart';
import 'package:mobile_wallet/ui/sendtransaction/confirm_transaction_page.dart';
import 'package:mobile_wallet/ui/sendtransaction/transaction_line_component.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';
import 'package:mobile_wallet/util/string_util.dart';

class SendTransactionPage extends StatelessWidget {
  final Wallet _wallet;
  final ExtendedWalletData _extendedWalletData;

  const SendTransactionPage(this._wallet, this._extendedWalletData,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SendTransactionBloc>(
        create: (_) =>
            SendTransactionBloc(_wallet, _extendedWalletData)..add(InitEvent()),
        child: _SendTransactionView(_wallet, _extendedWalletData));
  }
}

class _SendTransactionView extends StatelessWidget {
  final Wallet _wallet;
  final ExtendedWalletData _extendedWalletData;

  const _SendTransactionView(this._wallet, this._extendedWalletData);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendTransactionBloc, SendTransactionState>(
      listenWhen: (previous, current) =>
          current.status == SendTransactionStatus.verifying ||
          current.status == SendTransactionStatus.addressInvalid ||
          current.status == SendTransactionStatus.error ||
          current.status == SendTransactionStatus.verified ||
          current.status == SendTransactionStatus.notEnoughFunds,
      listener: (context, state) async {
        switch (state.status) {
          case SendTransactionStatus.verifying:
            Dialogs.showLoadingDialog(
                context, AppLocalizations.of(context)!.verifyingTransaction);
            break;
          case SendTransactionStatus.addressInvalid:
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.addressNotValid);
            break;
          case SendTransactionStatus.error:
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(context,
                "${AppLocalizations.of(context)!.errorSendTransaction} ${state.errorMessage}");
            break;
          case SendTransactionStatus.verified:
            for (TransactionLine transactionLine in state.transactionLines) {
              if (transactionLine.saveToAddressBook) {
                await _saveToAddressBook(context, transactionLine.address!);
              }
            }
            Dialogs.hideLoadingDialog(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => BlocProvider<SendTransactionBloc>.value(
                        value: BlocProvider.of<SendTransactionBloc>(context),
                        child: const ConfirmTransactionPage())));
            break;
          case SendTransactionStatus.notEnoughFunds:
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.insufficientBalance);
            break;
        }
      },
      child: _buildComponent(context),
    );
  }

  Container _buildComponent(BuildContext context) {
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
        resizeToAvoidBottomInset: true,
        appBar:
            QrlTitleAppBar(titleText: AppLocalizations.of(context)!.sendTitle),
        body: Column(
          children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 16, top: 24),
              child: Text(
                "Q${_wallet.address}",
                textAlign: TextAlign.center,
              ),
            )),
            Expanded(
              child: NotificationListener(
                onNotification: (OverscrollIndicatorNotification overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const TransactionLineComponent(),
                    _buildFeeOtsRow(context),
                    _buildAddMessageComponent(context),
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(AppLocalizations.of(context)!.balance),
                    )),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 24, left: 24, right: 24),
                            child: Text(
                                "${StringUtil.formatAmount(_extendedWalletData.balance)} QRL",
                                style: const TextStyle(
                                  color: CustomColors.qrlLightBlueColor,
                                  fontSize: 18,
                                )))),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: 256,
                  child: _buildReviewBlocBuilder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BlocBuilder<SendTransactionBloc, SendTransactionState>
      _buildAddMessageComponent(BuildContext context) {
    return BlocBuilder<SendTransactionBloc, SendTransactionState>(
      buildWhen: (previous, current) =>
          (previous.status == SendTransactionStatus.initializing &&
              current.status == SendTransactionStatus.initial) ||
          current.status == SendTransactionStatus.hasMessageUpdated,
      builder: (context, state) {
        if (state.hasMessage) {
          return Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 4, right: 24),
                      child: Icon(
                          size: 18,
                          color: CustomColors.qrlYellowColor,
                          Icons.close),
                    ),
                    onTap: () => BlocProvider.of<SendTransactionBloc>(context)
                        .add(const HasMessageChangedEvent(false))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                child: QrlTextFormField(
                  (value) => BlocProvider.of<SendTransactionBloc>(context)
                      .add(MessageChangedEvent(value)),
                  initialValue: state.message,
                  text: AppLocalizations.of(context)!.message,
                  maxLines: 3,
                  maxLength: 80,
                ),
              ),
            ],
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 8),
            child: SizedBox(
              width: 256,
              child: QrlButton(
                () => BlocProvider.of<SendTransactionBloc>(context)
                    .add(const HasMessageChangedEvent(true)),
                text: AppLocalizations.of(context)!.addMessage,
                baseColor: CustomColors.qrlYellowColor,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildFeeOtsRow(BuildContext context) {
    return BlocBuilder<SendTransactionBloc, SendTransactionState>(
      buildWhen: (previous, current) =>
          current.status == SendTransactionStatus.transactionLineCountUpdated ||
          current.status == SendTransactionStatus.reviewable ||
          current.status == SendTransactionStatus.initial,
      builder: (context, state) {
        Row row = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _buildFeeBlocBuilder(),
            ),
            Row(
              children: [
                Text(AppLocalizations.of(context)!.otsKeyIndex),
                _getOtsIndexText(),
              ],
            ),
          ],
        );
        Widget widget;
        if (state.status == SendTransactionStatus.reviewable) {
          widget = Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QrlButton(
                  () => BlocProvider.of<SendTransactionBloc>(context)
                      .add(AddTransactionLineEvent()),
                  text: AppLocalizations.of(context)!.addRecipient,
                  baseColor: CustomColors.qrlYellowColor,
                ),
              ),
              row,
            ],
          );
        } else {
          widget = row;
        }
        return Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          child: widget,
        );
      },
    );
  }

  BlocBuilder<SendTransactionBloc, SendTransactionState>
      _buildFeeBlocBuilder() {
    return BlocBuilder<SendTransactionBloc, SendTransactionState>(
      buildWhen: (previous, current) =>
          (previous.status == SendTransactionStatus.initializing &&
              current.status == SendTransactionStatus.initial) ||
          current.status == SendTransactionStatus.feeUpdated,
      builder: (context, state) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.fee,
          ),
          IntrinsicWidth(
            child: Text(
              StringUtil.formatAmount(state.fee),
              style: const TextStyle(
                  fontSize: 14, color: CustomColors.qrlLightBlueColor),
              maxLines: 2,
            ),
          ),
          InkWell(
              child: const Padding(
                padding: EdgeInsets.only(left: 4, right: 4),
                child: Icon(
                    size: 18,
                    color: CustomColors.qrlLightBlueColor,
                    Icons.edit),
              ),
              onTap: () => _showUpdateFee(context, state.fee)),
        ],
      ),
    );
  }

  _showUpdateFee(BuildContext context, int currentFee) {
    Util.dismissKeyboard(context);
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return BlocProvider<SendTransactionBloc>.value(
              value: BlocProvider.of<SendTransactionBloc>(context),
              child: BlocProvider<ChangeFeeBloc>(
                  create: (_) => ChangeFeeBloc(currentFee),
                  child: BlocListener<ChangeFeeBloc, ChangeFeeState>(
                      listenWhen: (previous, current) =>
                          current.status == ChangeFeeStatus.feeSaved,
                      listener: (context, state) {
                        if (state.status == ChangeFeeStatus.feeSaved) {
                          BlocProvider.of<SendTransactionBloc>(context)
                              .add(FeeChangedEvent(state.newFee!));
                          Navigator.of(context).pop();
                        }
                      },
                      child: ChangeFeeView(currentFee))));
        });
  }

  Text _getOtsIndexText() {
    int currentOtsIndex = _extendedWalletData.otsIndex;
    int totalOtsKeys = _getOtsKeysForHeight(_wallet.height);
    int otsKeysLeft = totalOtsKeys - currentOtsIndex;
    return Text(" $currentOtsIndex",
        style: TextStyle(
            color: otsKeysLeft < 16
                ? Colors.redAccent
                : CustomColors.qrlLightBlueColor));
  }

  int _getOtsKeysLeft() {
    int currentOtsIndex = _extendedWalletData.otsIndex;
    int totalOtsKeys = _getOtsKeysForHeight(_wallet.height);
    return totalOtsKeys - currentOtsIndex;
  }

  int _getOtsKeysForHeight(int height) {
    switch (height) {
      case 8:
        return 256;
      case 10:
        return 1024;
      case 12:
        return 4096;
      case 14:
        return 16384;
      case 16:
        return 262144;
    }
    return 0;
  }

  BlocBuilder<SendTransactionBloc, SendTransactionState>
      _buildReviewBlocBuilder() {
    return BlocBuilder<SendTransactionBloc, SendTransactionState>(
      buildWhen: (previous, current) =>
          current.status == SendTransactionStatus.reviewable ||
          (previous.status == SendTransactionStatus.reviewable &&
              current.status != SendTransactionStatus.verifying),
      builder: (context, state) => QrlButton(
        state.status == SendTransactionStatus.reviewable
            ? () {
                int otsKeysLeft = _getOtsKeysLeft();
                if (otsKeysLeft < 1) {
                  SnackBars.showSnackBar(context,
                      "${AppLocalizations.of(context)!.noMoreOts1} ${StringUtil.formatAmount(_extendedWalletData.balance)} ${AppLocalizations.of(context)!.noMoreOts2}");
                } else if (otsKeysLeft < 6) {
                  Dialogs.showConfirmDialog(context,
                      "${AppLocalizations.of(context)!.otsKeysLeft1} $otsKeysLeft ${AppLocalizations.of(context)!.otsKeysLeft2}",
                      header: AppLocalizations.of(context)!.warning, () {
                    BlocProvider.of<SendTransactionBloc>(context)
                        .add(ReviewEvent());
                  });
                } else {
                  BlocProvider.of<SendTransactionBloc>(context)
                      .add(ReviewEvent());
                }
              }
            : null,
        text: AppLocalizations.of(context)!.review,
        baseColor: CustomColors.qrlLightBlueColor,
        backgroundColor: CustomColors.qrlLightBlueColorBackground,
      ),
    );
  }

  Future<bool> _saveToAddressBook(BuildContext context, String address) async {
    return await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return BlocProvider<AddEntryBloc>(
              create: (_) => AddEntryBloc(address),
              child: BlocListener<AddEntryBloc, AddEntryState>(
                  listenWhen: (previous, current) =>
                      current.status == AddEntryStatus.entrySaved,
                  listener: (context, state) {
                    if (state.status == AddEntryStatus.entrySaved) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: AddEntryView(address)));
        });
  }
}
