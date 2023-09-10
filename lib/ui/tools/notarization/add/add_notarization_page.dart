import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_page.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_bloc.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_event.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_state.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/review_notarization_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

import '../../../addtransaction/add_transaction_bloc.dart';

class AddNotarizationPage extends StatelessWidget {
  const AddNotarizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddNotarizationBloc>(
        create: (_) => AddNotarizationBloc()..add(InitEvent()),
        child: const _AddNotarizationView());
  }
}

class _AddNotarizationView extends AddTransactionPage<AddNotarizationBloc> {
  const _AddNotarizationView({super.key});

  @override
  String getTitleText(BuildContext context) {
    return AppLocalizations.of(context)!.notarize;
  }

  @override
  List<Widget> buildWidgets(BuildContext context) {
    return [
      _buildDocumentUpload(context),
      _buildMessageComponent(context),
    ];
  }

  Widget _buildDocumentUpload(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: QrlButton(
            () async {
              FilePickerResult? result =
                  await FilePicker.platform.pickFiles(withData: true);
              if (result != null) {
                BlocProvider.of<AddNotarizationBloc>(context)
                    .add(UploadFileEvent(result));
              }
            },
            text: AppLocalizations.of(context)!.uploadDocument.toUpperCase(),
            baseColor: CustomColors.qrlYellowColor,
          ),
        ),
        BlocBuilder<AddNotarizationBloc, AddNotarizationState>(
          buildWhen: (previous, current) =>
              previous.fileName != current.fileName,
          builder: (context, state) {
            if (state.fileName != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 24, right: 24),
                child: Text(
                  state.fileName!,
                  overflow: TextOverflow.visible,
                  maxLines: 3,
                  style: const TextStyle(color: CustomColors.qrlLightBlueColor),
                ),
              );
            }
            return Container();
          },
        )
      ],
    );
  }

  BlocBuilder<AddNotarizationBloc, AddNotarizationState> _buildMessageComponent(
      BuildContext context) {
    return BlocBuilder<AddNotarizationBloc, AddNotarizationState>(
      buildWhen: (previous, current) =>
          previous.hasMessage != current.hasMessage,
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
                    onTap: () => BlocProvider.of<AddNotarizationBloc>(context)
                        .add(const HasMessageChangedEvent(false))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                child: QrlTextFormField(
                  (value) => BlocProvider.of<AddNotarizationBloc>(context)
                      .add(MessageChangedEvent(value)),
                  initialValue: state.message,
                  text: AppLocalizations.of(context)!.message,
                  maxLines: 2,
                  maxLength: 45,
                ),
              ),
            ],
          );
        } else {
          return Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 4),
            child: SizedBox(
              width: double.infinity,
              child: QrlButton(
                () => BlocProvider.of<AddNotarizationBloc>(context)
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
    Dialogs.hideLoadingDialog(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => BlocProvider<AddNotarizationBloc>.value(
                value: BlocProvider.of<AddNotarizationBloc>(context),
                child: const ReviewNotarizationPage())));
  }
}
