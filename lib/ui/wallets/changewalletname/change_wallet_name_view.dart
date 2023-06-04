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
          Padding(
            padding:
                const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: QrlTextFormField(
                initialValue: _initialName,
                (value) => BlocProvider.of<ChangeWalletNameBloc>(context)
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
          backgroundColor: CustomColors.qrlLightBlueColorBackground,
        );
      },
    );
  }
}
