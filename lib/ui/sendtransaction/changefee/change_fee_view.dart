import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/sendtransaction/changefee/change_fee_bloc.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/input_formatter.dart';
import 'package:mobile_wallet/util/string_util.dart';

class ChangeFeeView extends StatelessWidget {
  final int _initialFee;

  const ChangeFeeView(this._initialFee, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  initialValue: StringUtil.formatAmount(_initialFee),
                  (value) => BlocProvider.of<ChangeFeeBloc>(context).add(
                      ChangedEvent(value.isNotEmpty
                          ? (Decimal.parse(value) * Decimal.fromInt(1000000000))
                              .toBigInt()
                              .toInt()
                          : 1)),
                  text: AppLocalizations.of(context)!.fee,
                  autoFocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    InputFormatter.getNumberFormatter(),
                    InputFormatter.getCommaDotFormatter(),
                    InputFormatter.getNumberDotFormatter(),
                    InputFormatter.getMaxValueFormatter(),
                  ]),
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

  BlocBuilder<ChangeFeeBloc, ChangeFeeState> _buildButtonBlocBuilder() {
    return BlocBuilder<ChangeFeeBloc, ChangeFeeState>(
      buildWhen: (previous, current) =>
          (previous.status != ChangeFeeStatus.dirty &&
              current.status == ChangeFeeStatus.dirty) ||
          (previous.status != ChangeFeeStatus.noChange &&
              current.status == ChangeFeeStatus.noChange),
      builder: (context, state) {
        return QrlButton(
          state.status == ChangeFeeStatus.dirty
              ? () {
                  BlocProvider.of<ChangeFeeBloc>(context).add(ConfirmEvent());
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
