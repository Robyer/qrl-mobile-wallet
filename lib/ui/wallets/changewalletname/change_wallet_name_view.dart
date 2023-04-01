import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/wallets/changewalletname/change_wallet_name_bloc.dart';

class ChangeWalletNameView extends StatelessWidget {
  final String _initialName;

  const ChangeWalletNameView(this._initialName, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: CustomColors.qrlYellowColor),
          borderRadius: BorderRadius.circular(8)),
      backgroundColor: CustomColors.qrlDarkBlueColor,
      insetPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: QrlTextFormField(
          initialValue: _initialName,
          (value) => BlocProvider.of<ChangeWalletNameBloc>(context)
              .add(ChangedEvent(value)),
          text: AppLocalizations.of(context)!.walletName,
          autoFocus: true,
        ),
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
              Navigator.of(context).pop();
            },
            text: AppLocalizations.of(context)!.cancel,
            baseColor: CustomColors.qrlLightBlueColor,
          ),
        )
      ],
    );
  }

  BlocBuilder<ChangeWalletNameBloc, ChangeWalletNameState>
      _buildButtonBlocBuilder() {
    return BlocBuilder<ChangeWalletNameBloc, ChangeWalletNameState>(
      buildWhen: (previous, current) =>
          (previous.status != ChangeWalletNameStatus.dirty &&
              current.status == ChangeWalletNameStatus.dirty) ||
          (previous.status != ChangeWalletNameStatus.noChange &&
              current.status == ChangeWalletNameStatus.noChange),
      builder: (context, state) {
        return QrlButton(
          state.status == ChangeWalletNameStatus.dirty
              ? () {
                  BlocProvider.of<ChangeWalletNameBloc>(context)
                      .add(ConfirmEvent());
                }
              : null,
          text: AppLocalizations.of(context)!.confirm,
          baseColor: CustomColors.qrlLightBlueColor,
        );
      },
    );
  }
}
