import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:mobile_wallet/ui/addwallet/bloc/add_wallet_bloc.dart';
import 'package:mobile_wallet/ui/addwallet/hex_seed_field.dart';
import 'package:mobile_wallet/ui/backupwallet/backup_wallet_page.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

Map<int, String> _treeHeightMap = <int, String>{
  8: "Height 8: Signatures 256",
  10: "Height 10: Signatures 1,024",
  12: "Height 12: Signatures 4,096",
  14: "Height 14: Signatures 16,384",
  16: "Height 16: Signatures 262,144",
};

Map<int, String> _hashFunctionMap = <int, String>{
  1: "SHAKE_128",
  2: "SHAKE_256",
  3: "SHA2_256",
};

class AddWalletDataPage extends StatelessWidget {
  final AddWalletMode _addWalletMode;

  const AddWalletDataPage(this._addWalletMode, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddWalletBloc>(
        create: (_) => AddWalletBloc(_addWalletMode),
        child: _AddWalletDataView(_addWalletMode));
  }
}

class _AddWalletDataView extends StatelessWidget {
  final AddWalletMode _addWalletMode;

  const _AddWalletDataView(this._addWalletMode);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddWalletBloc, AddWalletState>(
        listenWhen: (previous, current) =>
            current.status == AddWalletStatus.error ||
            current.status == AddWalletStatus.creating ||
            current.status == AddWalletStatus.created,
        listener: (context, state) {
          if (state.status == AddWalletStatus.creating) {
            Dialogs.showLoadingDialog(
                context, AppLocalizations.of(context)!.creatingWallet);
          } else if (state.status == AddWalletStatus.created) {
            Dialogs.hideLoadingDialog(context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BackupWalletPage(state.createdWallet!)),
                (route) => false);
          } else if (state.status == AddWalletStatus.error) {
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(context,
                "${AppLocalizations.of(context)!.errorWalletCreation} ${state.errorMessage}");
          }
        },
        child: Scaffold(
          appBar: QrlAppBar(),
          body: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _buildWidgets(context)),
                ),
              ),
            ),
          ),
        ));
  }

  List<Widget> _buildWidgets(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    widgets.add(Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(AppLocalizations.of(context)!.walletSetup,
            style: const TextStyle(
              color: CustomColors.qrlLightBlueColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
      ),
    ));
    widgets.add(Center(
        child: Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Text(_getHeader(context)),
    )));
    widgets.add(Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
      child: QrlTextFormField(
        (value) => BlocProvider.of<AddWalletBloc>(context)
            .add(NameChangedEvent(value)),
        text: AppLocalizations.of(context)!.walletName,
        autoFocus: true,
      ),
    ));
    if (_addWalletMode == AddWalletMode.mnemonic) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
        child: QrlTextFormField(
          (value) => BlocProvider.of<AddWalletBloc>(context)
              .add(MnemonicChangedEvent(value)),
          text: AppLocalizations.of(context)!.mnemonic,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 10,
        ),
      ));
    } else if (_addWalletMode == AddWalletMode.hexSeed) {
      widgets.add(const Padding(
        padding: EdgeInsets.only(top: 8, bottom: 8, left: 32, right: 32),
        child: HexSeedField(),
      ));
    } else {
      widgets.add(BottomSheetSelect<int>(
        selectedItem: 10,
        items: _treeHeightMap.keys.toList(),
        floatingLabelValue: AppLocalizations.of(context)!.treeHeight,
        valueChanged: (int? value) {
          if (value != null) {
            BlocProvider.of<AddWalletBloc>(context)
                .add(TreeHeightChangedEvent(value));
          }
        },
        labelConverter: (value) {
          return _treeHeightMap[value]!;
        },
        itemConverter: (value) {
          return _treeHeightMap[value]!;
        },
      ));
      widgets.add(BottomSheetSelect<int>(
        selectedItem: 1,
        items: _hashFunctionMap.keys.toList(),
        floatingLabelValue: AppLocalizations.of(context)!.hashFunction,
        valueChanged: (int? value) {
          if (value != null) {
            BlocProvider.of<AddWalletBloc>(context)
                .add(HashFunctionChangedEvent(value));
          }
        },
        labelConverter: (value) {
          return _hashFunctionMap[value]!;
        },
        itemConverter: (value) {
          return _hashFunctionMap[value]!;
        },
      ));
    }
    widgets.add(Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 36),
          child: SizedBox(
            width: 256,
            child: _buildButtonBlocBuilder(),
          ),
        ),
      ),
    ));
    return widgets;
  }

  String _getHeader(BuildContext context) {
    if (_addWalletMode == AddWalletMode.mnemonic) {
      return AppLocalizations.of(context)!.openWithMnemonics;
    } else if (_addWalletMode == AddWalletMode.hexSeed) {
      return AppLocalizations.of(context)!.openWithHexseed;
    } else {
      return AppLocalizations.of(context)!.createWalletTitle;
    }
  }

  BlocBuilder<AddWalletBloc, AddWalletState> _buildButtonBlocBuilder() {
    return BlocBuilder<AddWalletBloc, AddWalletState>(
      buildWhen: (previous, current) =>
          (previous.status != AddWalletStatus.initial &&
              current.status == AddWalletStatus.initial) ||
          (previous.status != AddWalletStatus.valid &&
              current.status == AddWalletStatus.valid) ||
          (previous.status != AddWalletStatus.error &&
              current.status == AddWalletStatus.error),
      builder: (context, state) => QrlButton(
        state.status == AddWalletStatus.valid
            ? () {
                Util.dismissKeyboard(context);
                if (_addWalletMode == AddWalletMode.create) {
                  Dialogs.showConfirmDialog(
                      context, AppLocalizations.of(context)!.outOfSignatures,
                      () async {
                    BlocProvider.of<AddWalletBloc>(context).add(ConfirmEvent());
                  }, header: AppLocalizations.of(context)!.important);
                } else {
                  BlocProvider.of<AddWalletBloc>(context).add(ConfirmEvent());
                }
              }
            : null,
        text: AppLocalizations.of(context)!.confirm,
        baseColor: CustomColors.qrlLightBlueColor,
      ),
    );
  }
}
