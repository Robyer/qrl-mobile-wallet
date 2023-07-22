import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_page.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_bloc.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_event.dart';
import 'package:mobile_wallet/ui/tools/message/review_message_page.dart';

import '../../addtransaction/add_transaction_bloc.dart';

class AddMessagePage extends StatelessWidget {
  const AddMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddMessageBloc>(
        create: (_) => AddMessageBloc()..add(InitEvent()),
        child: const _AddMessageView());
  }
}

class _AddMessageView extends AddTransactionPage<AddMessageBloc> {
  const _AddMessageView({super.key});

  @override
  String getTitleText(BuildContext context) {
    return AppLocalizations.of(context)!.message;
  }

  @override
  List<Widget> buildWidgets(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
        child: QrlTextFormField(
          (value) => BlocProvider.of<AddMessageBloc>(context)
              .add(MessageChangedEvent(value)),
          initialValue: "",
          text: AppLocalizations.of(context)!.message,
          maxLines: 3,
          maxLength: 80,
        ),
      ),
    ];
  }

  @override
  Future<void> onVerified(
      BuildContext context, AddTransactionState state) async {
    Dialogs.hideLoadingDialog(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => BlocProvider<AddMessageBloc>.value(
                value: BlocProvider.of<AddMessageBloc>(context),
                child: const ReviewMessagePage())));
  }
}
