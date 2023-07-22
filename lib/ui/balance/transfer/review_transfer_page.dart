import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addtransaction/review_transaction_page.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_bloc.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_state.dart';
import 'package:mobile_wallet/ui/util/component_util.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/util/string_util.dart';

class ReviewTransferPage
    extends ReviewTransactionPage<AddTransferBloc, AddTransferState> {
  const ReviewTransferPage({super.key});

  @override
  List<Widget> buildWidgets(BuildContext context, AddTransferState state) {
    return [
      ListView.builder(
        itemCount: state.transactionLines.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final TransactionLine transactionLine = state.transactionLines[index];
          return Card(
            elevation: 1,
            color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      AppLocalizations.of(context)!.amount,
                      style: const TextStyle(
                        color: CustomColors.qrlYellowColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      "${StringUtil.formatAmount(transactionLine.amount!)} QRL",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      AppLocalizations.of(context)!.sendingToWalletAddress,
                      style: const TextStyle(
                        color: CustomColors.qrlYellowColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SelectableText(
                      transactionLine.address!,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      if (state.message != null && state.message!.isNotEmpty)
        ComponentUtil.buildLabelValueCard(
            AppLocalizations.of(context)!.message, state.message ?? "")
    ];
  }
}
