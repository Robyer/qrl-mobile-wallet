import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addressbook/addentry/add_entry_bloc.dart';
import 'package:mobile_wallet/ui/addressbook/addentry/add_entry_view.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_page.dart';
import 'package:mobile_wallet/ui/component/address_field.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_bloc.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_event.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_state.dart';
import 'package:mobile_wallet/ui/tools/token/create/initial_token_holder_component.dart';
import 'package:mobile_wallet/ui/tools/token/create/review_token_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/input_formatter.dart';
import 'package:mobile_wallet/ui/util/util.dart';

import '../../../addtransaction/add_transaction_bloc.dart';

class CreateTokenPage extends StatelessWidget {
  const CreateTokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateTokenBloc>(
        create: (_) => CreateTokenBloc()..add(InitEvent()),
        child: const _CreateTokenView());
  }
}

class _CreateTokenView extends AddTransactionPage<CreateTokenBloc> {
  const _CreateTokenView({super.key});

  @override
  Widget buildComponent(BuildContext context) {
    return BlocListener<CreateTokenBloc, CreateTokenState>(
      listenWhen: (previous, current) =>
          (previous.createTokenStatus != CreateTokenStatus.addressInvalid &&
              current.createTokenStatus == CreateTokenStatus.addressInvalid) ||
          (previous.createTokenStatus !=
                  CreateTokenStatus.initialBalanceToLarge &&
              current.createTokenStatus ==
                  CreateTokenStatus.initialBalanceToLarge),
      listener: (context, state) async {
        switch (state.createTokenStatus) {
          case CreateTokenStatus.addressInvalid:
            Util.dismissKeyboard(context);
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.addressNotValid);
            break;
          case CreateTokenStatus.initialBalanceToLarge:
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.initialBalanceToLarge);
            break;
        }
      },
      child: super.buildComponent(context),
    );
  }

  @override
  String getTitleText(BuildContext context) {
    return AppLocalizations.of(context)!.createToken;
  }

  @override
  List<Widget> buildWidgets(BuildContext context) {
    return [
      _buildOwnerAddressField(context),
      _buildSaveOwnerAddressToAddressBookField(),
      _buildTokenNameField(context),
      _buildTokenSymbolField(context),
      _buildTokenDecimalsField(context),
      const InitialTokenHolderComponent(),
      _buildAddInitialHolder(context),
    ];
  }

  Padding _buildOwnerAddressField(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 4, top: 8),
        child: AddressField(
            null,
            (value) => BlocProvider.of<CreateTokenBloc>(context)
                .add(OwnerAddressChangedEvent(value)),
            header: AppLocalizations.of(context)!.ownerAddress));
  }

  BlocBuilder<CreateTokenBloc, CreateTokenState>
      _buildSaveOwnerAddressToAddressBookField() {
    return BlocBuilder<CreateTokenBloc, CreateTokenState>(
      buildWhen: (previous, current) =>
          previous.saveOwnerAddressToAddressBook !=
          current.saveOwnerAddressToAddressBook,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SwitchListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -4),
              activeColor: CustomColors.qrlLightBlueColor,
              title: Text(AppLocalizations.of(context)!.saveToAddressBook),
              onChanged: (value) => BlocProvider.of<CreateTokenBloc>(context)
                  .add(SaveOwnerAddressToAddressBookChangedEvent(value)),
              value: state.saveOwnerAddressToAddressBook),
        );
      },
    );
  }

  Padding _buildTokenNameField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
      child: QrlTextFormField(
        (value) => BlocProvider.of<CreateTokenBloc>(context)
            .add(TokenNameChangedEvent(value)),
        initialValue: "",
        text: AppLocalizations.of(context)!.tokenName,
        maxLines: 2,
        maxLength: 30,
      ),
    );
  }

  Padding _buildTokenSymbolField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
      child: QrlTextFormField(
        (value) => BlocProvider.of<CreateTokenBloc>(context)
            .add(TokenSymbolChangedEvent(value)),
        initialValue: "",
        text: AppLocalizations.of(context)!.tokenSymbol,
        maxLines: 1,
        maxLength: 10,
      ),
    );
  }

  Padding _buildTokenDecimalsField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 8),
      child: QrlTextFormField(
        (value) => BlocProvider.of<CreateTokenBloc>(context)
            .add(TokenDecimalsChangedEvent(value)),
        initialValue: "10",
        text: AppLocalizations.of(context)!.decimals,
        maxLines: 1,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: <TextInputFormatter>[
          InputFormatter.getIntFormatter(),
          TextInputFormatter.withFunction(
            (oldValue, newValue) {
              if (newValue.text.isNotEmpty) {
                if (newValue.text.length > 1 && newValue.text.startsWith("0")) {
                  return newValue.copyWith(
                    selection: const TextSelection.collapsed(offset: 1),
                    composing: TextRange.empty,
                    text: newValue.text.substring(1),
                  );
                }
                int newValueInt = int.parse(newValue.text);
                if (newValueInt > 19) {
                  return newValue.copyWith(
                    selection: const TextSelection.collapsed(offset: 2),
                    composing: TextRange.empty,
                    text: "19",
                  );
                }
              } else {
                return newValue.copyWith(
                  selection: const TextSelection.collapsed(offset: 1),
                  composing: TextRange.empty,
                  text: "0",
                );
              }
              return newValue;
            },
          ),
        ],
      ),
    );
  }

  Padding _buildAddInitialHolder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: QrlButton(
          () => BlocProvider.of<CreateTokenBloc>(context)
              .add(AddInitialHolderEvent()),
          text: AppLocalizations.of(context)!.addHolder,
          baseColor: CustomColors.qrlYellowColor,
        ),
      ),
    );
  }

  @override
  Future<void> onVerified(
      BuildContext context, AddTransactionState state) async {
    CreateTokenState createTokenState = state as CreateTokenState;
    if (createTokenState.saveOwnerAddressToAddressBook) {
      await _saveToAddressBook(context, createTokenState.ownerAddress);
    }
    for (InitialHolder initialHolder in createTokenState.initialHolders) {
      if (initialHolder.saveToAddressBook) {
        await _saveToAddressBook(context, initialHolder.address!);
      }
    }
    Dialogs.hideLoadingDialog(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => BlocProvider<CreateTokenBloc>.value(
                value: BlocProvider.of<CreateTokenBloc>(context),
                child: const ReviewTokenPage())));
  }

  Future<bool> _saveToAddressBook(BuildContext context, String address) async {
    return await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return BlocProvider<AddEntryBloc>(
              create: (_) => AddEntryBloc(address),
              child: BlocListener<AddEntryBloc, AddEntryState>(
                  listenWhen: (previous, current) =>
                      current.status == AddEntryStatus.entrySaved,
                  listener: (context, state) {
                    if (state.status == AddEntryStatus.entrySaved) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: AddEntryView(address)));
        });
  }
}
