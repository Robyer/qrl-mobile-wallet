import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addtransaction/review_transaction_page.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_bloc.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_state.dart';
import 'package:mobile_wallet/ui/util/component_util.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/util/string_util.dart';

class ReviewTokenPage
    extends ReviewTransactionPage<CreateTokenBloc, CreateTokenState> {
  const ReviewTokenPage({super.key});

  @override
  List<Widget> buildWidgets(BuildContext context, CreateTokenState state) {
    return [
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.ownerAddress, state.ownerAddress),
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.tokenName, state.tokenName),
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.tokenSymbol, state.tokenSymbol),
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.decimals, "${state.tokenDecimals}"),
      ListView.builder(
        itemCount: state.initialHolders.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final InitialHolder initialHolder = state.initialHolders[index];
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
                      StringUtil.formatAmount(initialHolder.initialBalance!,
                          decimals: state.tokenDecimals),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
    ];
  }
}
