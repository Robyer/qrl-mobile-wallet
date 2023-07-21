import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mobile_wallet/ui/addtransaction/review_transaction_page.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_bloc.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_state.dart';
import 'package:mobile_wallet/ui/util/component_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReviewMessagePage
    extends ReviewTransactionPage<AddMessageBloc, AddMessageState> {
  const ReviewMessagePage({super.key});

  @override
  List<Widget> buildWidgets(BuildContext context, AddMessageState state) {
    return [
      ComponentUtil.buildLabelValueCard(
          AppLocalizations.of(context)!.message, state.message),
    ];
  }
}
