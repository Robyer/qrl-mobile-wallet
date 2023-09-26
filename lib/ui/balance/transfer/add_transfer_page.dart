import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/ui/addressbook/addentry/add_entry_bloc.dart';
import 'package:mobile_wallet/ui/addressbook/addentry/add_entry_view.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_page.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_bloc.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_state.dart';
import 'package:mobile_wallet/ui/balance/transfer/review_transfer_page.dart';
import 'package:mobile_wallet/ui/balance/transfer/transaction_line_component.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

import '../../addtransaction/add_transaction_bloc.dart';
import 'add_transfer_event.dart';

class AddTransferPage extends StatelessWidget {
  const AddTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddTransferBloc>(
        create: (_) => AddTransferBloc()..add(InitEvent()),
        child: const _AddTransferView());
  }
}

class _AddTransferView extends AddTransactionPage<AddTransferBloc> {
  const _AddTransferView({super.key});

  @override
  Widget buildComponent(BuildContext context) {
    return BlocListener<AddTransferBloc, AddTransferState>(
      listenWhen: (previous, current) =>
          (previous.transferStatus != AddTransferStatus.addressInvalid &&
              current.transferStatus == AddTransferStatus.addressInvalid) ||
          (previous.transferStatus != AddTransferStatus.notEnoughFunds &&
              current.transferStatus == AddTransferStatus.notEnoughFunds),
      listener: (context, state) async {
        switch (state.transferStatus) {
          case AddTransferStatus.addressInvalid:
            Util.dismissKeyboard(context);
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.addressNotValid);
            break;
          case AddTransferStatus.notEnoughFunds:
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.insufficientBalance);
            break;
        }
      },
      child: super.buildComponent(context),
    );
  }

  @override
  String getTitleText(BuildContext context) {
    return AppLocalizations.of(context)!.transfer;
  }

  @override
  List<Widget> buildWidgets(BuildContext context) {
    return [
      const TransactionLineComponent(),
      _buildAddRecipientComponent(context),
      _buildAddMessageComponent(context)
    ];
  }

  BlocBuilder<AddTransferBloc, AddTransferState> _buildAddRecipientComponent(
      BuildContext context) {
    return BlocBuilder<AddTransferBloc, AddTransferState>(
      buildWhen: (previous, current) =>
          previous.reviewable || current.reviewable,
      builder: (context, state) {
        if (state.reviewable) {
          return Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: QrlButton(
                () => BlocProvider.of<AddTransferBloc>(context)
                    .add(AddTransactionLineEvent()),
                text: AppLocalizations.of(context)!.addRecipient,
                baseColor: CustomColors.qrlYellowColor,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  BlocBuilder<AddTransferBloc, AddTransferState> _buildAddMessageComponent(
      BuildContext context) {
    return BlocBuilder<AddTransferBloc, AddTransferState>(
      buildWhen: (previous, current) =>
          previous.hasMessage ||
          current.hasMessage ||
          (previous.transactionType != current.transactionType),
      builder: (context, state) {
        if (state.transactionType == TransactionType.transferToken) {
          return Container();
        } else if (state.hasMessage) {
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
                    onTap: () => BlocProvider.of<AddTransferBloc>(context)
                        .add(const HasMessageChangedEvent(false))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                child: QrlTextFormField(
                  (value) => BlocProvider.of<AddTransferBloc>(context)
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
              width: double.infinity,
              child: QrlButton(
                () => BlocProvider.of<AddTransferBloc>(context)
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

  @override
  Future<void> onVerified(
      BuildContext context, AddTransactionState state) async {
    for (TransactionLine transactionLine
        in (state as AddTransferState).transactionLines) {
      if (transactionLine.saveToAddressBook) {
        await _saveToAddressBook(context, transactionLine.address!);
      }
    }
    Dialogs.hideLoadingDialog(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => BlocProvider<AddTransferBloc>.value(
                value: BlocProvider.of<AddTransferBloc>(context),
                child: const ReviewTransferPage())));
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
