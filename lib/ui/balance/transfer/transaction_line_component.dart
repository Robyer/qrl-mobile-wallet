import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/balance/transfer/address_field.dart';

import 'package:mobile_wallet/ui/balance/transfer/add_transfer_bloc.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_event.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_state.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/input_formatter.dart';
import 'package:mobile_wallet/util/string_util.dart';

class TransactionLineComponent extends StatelessWidget {
  const TransactionLineComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddTransferBloc, AddTransferState>(
      buildWhen: (previous, current) =>
          previous.transferStatus !=
              AddTransferStatus.transactionLineCountUpdated &&
          current.transferStatus ==
              AddTransferStatus.transactionLineCountUpdated,
      builder: (context, state) {
        int itemCount = state.transactionLines.length;
        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) => Column(
                children: [
                  itemCount > 1
                      ? Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                              child: const Padding(
                                padding: EdgeInsets.only(top: 4, right: 24),
                                child: Icon(
                                    size: 18,
                                    color: CustomColors.qrlYellowColor,
                                    Icons.close),
                              ),
                              onTap: () =>
                                  BlocProvider.of<AddTransferBloc>(context)
                                      .add(RemoveTransactionLineEvent(index))),
                        )
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
                    child: AddressField(
                        index, state.transactionLines[index].address),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
                    child: _buildSaveToAddressBookBlocBuilder(index),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                    child: _buildAmountBlocBuilder(index),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  BlocBuilder<AddTransferBloc, AddTransferState>
      _buildSaveToAddressBookBlocBuilder(int index) {
    return BlocBuilder<AddTransferBloc, AddTransferState>(
      buildWhen: (previous, current) =>
          previous.transferStatus !=
              AddTransferStatus.saveToAddressBookUpdated &&
          current.transferStatus == AddTransferStatus.saveToAddressBookUpdated,
      builder: (context, state) {
        return SwitchListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -4),
            activeColor: CustomColors.qrlLightBlueColor,
            title: Text(AppLocalizations.of(context)!.saveToAddressBook),
            onChanged: (value) => BlocProvider.of<AddTransferBloc>(context)
                .add(SaveToAddressBookChangedEvent(value, index)),
            value: state.transactionLines[index].saveToAddressBook);
      },
    );
  }

  BlocBuilder<AddTransferBloc, AddTransferState> _buildAmountBlocBuilder(
      int index) {
    return BlocBuilder<AddTransferBloc, AddTransferState>(
      buildWhen: (previous, current) =>
          (previous.status != AddTransactionStatus.ready &&
              current.status == AddTransactionStatus.ready) ||
          previous.fee != current.fee,
      builder: (context, state) => QrlTextFormField(
        (value) => BlocProvider.of<AddTransferBloc>(context)
            .add(AmountChangedEvent(value, index)),
        key: ValueKey("amount-key-${state.transactionLines[index].amount}"),
        initialValue: state.transactionLines[index].amount != null
            ? StringUtil.formatAmount(state.transactionLines[index].amount!)
            : "",
        text: AppLocalizations.of(context)!.amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          InputFormatter.getNumberFormatter(),
          InputFormatter.getCommaDotFormatter(),
          InputFormatter.getNumberDotFormatter(),
          InputFormatter.getMaxValueFormatter(),
          TextInputFormatter.withFunction(
            (oldValue, newValue) {
              if (newValue.text.isNotEmpty) {
                BigInt newValueBigInt =
                    (Decimal.parse(newValue.text) * Decimal.fromInt(1000000000))
                        .toBigInt();
                BigInt availableBalance =
                    BigInt.from(state.extendedWalletData?.balance ?? 0) -
                        BigInt.from(state.fee);
                if (newValueBigInt > availableBalance) {
                  var formattedAmount = StringUtil.formatAmount(
                      availableBalance > BigInt.zero
                          ? availableBalance.toInt()
                          : 0);
                  return newValue.copyWith(
                    selection:
                        const TextSelection(baseOffset: 0, extentOffset: 0),
                    composing: TextRange.empty,
                    text: formattedAmount,
                  );
                }
              }
              return newValue;
            },
          ),
        ],
        minLines: 1,
        maxLines: 5,
      ),
    );
  }
}
