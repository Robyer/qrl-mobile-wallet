import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/sendtransaction/addressbook/addentry/add_entry_bloc.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class AddEntryView extends StatelessWidget {
  final String _address;

  const AddEntryView(this._address, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: CustomColors.qrlYellowColor),
          borderRadius: BorderRadius.circular(8)),
      backgroundColor: CustomColors.qrlDarkBlueColor,
      insetPadding: const EdgeInsets.all(24),
      title: Text(
        AppLocalizations.of(context)!.addressBook,
        style: const TextStyle(
          color: CustomColors.qrlLightBlueColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              _address,
              textAlign: TextAlign.center,
            ),
          )),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: QrlTextFormField(
              (value) => BlocProvider.of<AddEntryBloc>(context)
                  .add(ChangedEvent(value)),
              text: AppLocalizations.of(context)!.walletName,
              autoFocus: true,
            ),
          )
        ],
      ),
      contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 36),
      actionsPadding:
          const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 24),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        SizedBox(
          width: 120,
          child: _buildButtonBlocBuilder(),
        ),
        SizedBox(
          width: 120,
          child: QrlButton(
            () {
              Navigator.of(context).pop(false);
            },
            text: AppLocalizations.of(context)!.cancel,
            baseColor: CustomColors.qrlLightBlueColor,
          ),
        )
      ],
    );
  }

  BlocBuilder<AddEntryBloc, AddEntryState> _buildButtonBlocBuilder() {
    return BlocBuilder<AddEntryBloc, AddEntryState>(
      buildWhen: (previous, current) =>
          (previous.status != AddEntryStatus.dirty &&
              current.status == AddEntryStatus.dirty) ||
          (previous.status != AddEntryStatus.noChange &&
              current.status == AddEntryStatus.noChange),
      builder: (context, state) {
        return QrlButton(
          state.status == AddEntryStatus.dirty
              ? () {
                  BlocProvider.of<AddEntryBloc>(context).add(ConfirmEvent());
                }
              : null,
          text: AppLocalizations.of(context)!.confirm,
          baseColor: CustomColors.qrlLightBlueColor,
        );
      },
    );
  }
}
