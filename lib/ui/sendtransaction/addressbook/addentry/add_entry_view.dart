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
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: CustomColors.qrlYellowColor),
      ),
      backgroundColor: CustomColors.qrlDarkBlueColor,
      child: Container(
        decoration: BoxDecoration(
          gradient: CustomColors.qrlDarkBlueLinearGradient,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context)!.addressBook,
              style: const TextStyle(
                color: CustomColors.qrlLightBlueColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: Text(
              _address,
              textAlign: TextAlign.center,
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: QrlTextFormField(
                (value) => BlocProvider.of<AddEntryBloc>(context)
                    .add(ChangedEvent(value)),
                text: AppLocalizations.of(context)!.walletName,
                autoFocus: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: QrlButton(
                    () {
                      Navigator.of(context).pop();
                    },
                    text: AppLocalizations.of(context)!.cancel,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(child: _buildButtonBlocBuilder()),
              ],
            ),
          ),
        ]),
      ),
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
          backgroundColor: CustomColors.qrlLightBlueColorBackground,
        );
      },
    );
  }
}
