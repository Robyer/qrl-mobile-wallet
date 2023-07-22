import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_wallet/ui/addtransaction/review_transaction_page.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_bloc.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_state.dart';
import 'package:mobile_wallet/ui/util/component_util.dart';
import 'package:mobile_wallet/ui/util/util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReviewNotarizationPage
    extends ReviewTransactionPage<AddNotarizationBloc, AddNotarizationState> {
  const ReviewNotarizationPage({super.key});

  @override
  List<Widget> buildWidgets(BuildContext context, AddNotarizationState state) {
    return [
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.fileName, state.fileName ?? ""),
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.fileHash, state.fileHash ?? ""),
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.hashFunction,
          Util.notarizationHashFunctions[state.hashFunction] ?? ""),
      if (state.message.isNotEmpty)
        ComponentUtil.buildLabelValueCard(
            AppLocalizations.of(context)!.message, state.message ?? ""),
    ];
  }
}
