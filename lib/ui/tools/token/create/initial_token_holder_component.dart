import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/address_field.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_bloc.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_event.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_state.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/input_formatter.dart';
import 'package:mobile_wallet/util/string_util.dart';

class InitialTokenHolderComponent extends StatelessWidget {
  const InitialTokenHolderComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTokenBloc, CreateTokenState>(
      buildWhen: (previous, current) =>
          current.createTokenStatus ==
              CreateTokenStatus.initialHolderCountUpdated &&
          previous.createTokenStatus !=
              CreateTokenStatus.initialHolderCountUpdated,
      builder: (context, state) {
        int itemCount = state.initialHolders.length;
        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) => Column(
                children: [
                  itemCount > 1
                      ? Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                              child: const Padding(
                                padding: EdgeInsets.only(top: 4, right: 24),
                                child: Icon(
                                    size: 18,
                                    color: CustomColors.qrlYellowColor,
                                    Icons.close),
                              ),
                              onTap: () =>
                                  BlocProvider.of<CreateTokenBloc>(context)
                                      .add(RemoveInitialHolderEvent(index))),
                        )
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
                    child: AddressField(
                      state.initialHolders[index].address,
                      (value) => BlocProvider.of<CreateTokenBloc>(context)
                          .add(InitialAddressChangedEvent(value, index)),
                      header: AppLocalizations.of(context)!.holderAddress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
                    child: _buildSaveToAddressBook(index),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                    child: _buildInitialTokenBalance(context, index),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  BlocBuilder<CreateTokenBloc, CreateTokenState> _buildSaveToAddressBook(
      int index) {
    return BlocBuilder<CreateTokenBloc, CreateTokenState>(
      buildWhen: (previous, current) =>
          previous.createTokenStatus !=
              CreateTokenStatus.saveToAddressBookUpdated &&
          current.createTokenStatus ==
              CreateTokenStatus.saveToAddressBookUpdated,
      builder: (context, state) {
        return SwitchListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -4),
            activeColor: CustomColors.qrlLightBlueColor,
            title: Text(AppLocalizations.of(context)!.saveToAddressBook),
            onChanged: (value) => BlocProvider.of<CreateTokenBloc>(context).add(
                SaveInitialHolderAddressToAddressBookChangedEvent(
                    value, index)),
            value: state.initialHolders[index].saveToAddressBook);
      },
    );
  }

  Widget _buildInitialTokenBalance(BuildContext context, int index) {
    return BlocBuilder<CreateTokenBloc, CreateTokenState>(
        buildWhen: (previous, current) =>
            previous.tokenDecimals != current.tokenDecimals,
        builder: (context, state) {
          return QrlTextFormField(
            (value) => BlocProvider.of<CreateTokenBloc>(context)
                .add(InitialBalanceChangedEvent(value, index)),
            key: ValueKey(
                "balance-key-${state.tokenDecimals}${state.initialHolders[index].initialBalance}"),
            initialValue: state.initialHolders[index].initialBalance != null
                ? StringUtil.formatAmount(
                    state.initialHolders[index].initialBalance!,
                    decimals: state.tokenDecimals)
                : "",
            text: AppLocalizations.of(context)!.initialBalance,
            maxLines: 1,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              InputFormatter.getNumberFormatter(),
              InputFormatter.getCommaDotFormatter(),
              InputFormatter.getNumberDotFormatter(
                  decimals: state.tokenDecimals),
              InputFormatter.getMaxValueFormatter(
                  decimals: state.tokenDecimals),
            ],
          );
        });
  }
}
