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
        child: Container(
          decoration: BoxDecoration(
            gradient: CustomColors.qrlDarkBlueLinearGradient,
            image: DecorationImage(
              image: const AssetImage('assets/images/orange-dots-3.png'),
              alignment: Alignment.bottomCenter,
              colorFilter: ColorFilter.mode(
                CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Scaffold(
            appBar: QrlTitleAppBar(
                titleText: AppLocalizations.of(context)!.walletSetup),
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
          ),
        ));
  }

  List<Widget> _buildWidgets(BuildContext context) {
    List<Widget> widgets = <Widget>[];
    if (_addWalletMode == AddWalletMode.mnemonic ||
        _addWalletMode == AddWalletMode.hexSeed) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 24),
        child: BottomSheetSelect<AddWalletMode>(
          selectedItem: AddWalletMode.mnemonic,
          items: const [AddWalletMode.mnemonic, AddWalletMode.hexSeed],
          floatingLabelValue: "",
          valueChanged: (AddWalletMode? value) {
            if (value != null) {
              BlocProvider.of<AddWalletBloc>(context)
                  .add(WalletModeChangedEvent(value));
            }
          },
          labelConverter: (value) {
            if (value == AddWalletMode.mnemonic) {
              return AppLocalizations.of(context)!.openWithMnemonics;
            }
            return AppLocalizations.of(context)!.openWithHexseed;
          },
          itemConverter: (value) {
            if (value == AddWalletMode.mnemonic) {
              return AppLocalizations.of(context)!.openWithMnemonics;
            }
            return AppLocalizations.of(context)!.openWithHexseed;
          },
        ),
      ));
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        child: QrlTextFormField(
          (value) => BlocProvider.of<AddWalletBloc>(context)
              .add(NameChangedEvent(value)),
          text: AppLocalizations.of(context)!.walletName,
          autoFocus: true,
        ),
      ));
      widgets.add(Padding(
        padding:
            const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 16),
        child: _buildMnemonicHexFieldBuilder(),
      ));
    }
    if (_addWalletMode == AddWalletMode.create) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
        child: QrlTextFormField(
          (value) => BlocProvider.of<AddWalletBloc>(context)
              .add(NameChangedEvent(value)),
          text: AppLocalizations.of(context)!.walletName,
          autoFocus: true,
        ),
      ));
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 24),
        child: BottomSheetSelect<int>(
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
        ),
      ));
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: BottomSheetSelect<int>(
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
        ),
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

  BlocBuilder<AddWalletBloc, AddWalletState> _buildMnemonicHexFieldBuilder() {
    return BlocBuilder<AddWalletBloc, AddWalletState>(
      buildWhen: (previous, current) =>
          previous.addWalletMode != current.addWalletMode,
      builder: (context, state) {
        if (state.addWalletMode == AddWalletMode.mnemonic) {
          return QrlTextFormField(
            (value) => BlocProvider.of<AddWalletBloc>(context)
                .add(MnemonicChangedEvent(value)),
            text: AppLocalizations.of(context)!.mnemonic,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 10,
          );
        } else {
          return const HexSeedField();
        }
      },
    );
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
                  Dialogs.showConfirmDialog(context, () async {
                    BlocProvider.of<AddWalletBloc>(context).add(ConfirmEvent());
                  },
                      header: AppLocalizations.of(context)!.important,
                      message: AppLocalizations.of(context)!.outOfSignatures);
                } else {
                  BlocProvider.of<AddWalletBloc>(context).add(ConfirmEvent());
                }
              }
            : null,
        text: AppLocalizations.of(context)!.confirm,
        baseColor: CustomColors.qrlLightBlueColor,
        backgroundColor: CustomColors.qrlLightBlueColorBackground,
      ),
    );
  }
}
