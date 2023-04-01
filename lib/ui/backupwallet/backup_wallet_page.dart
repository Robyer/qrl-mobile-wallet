import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/backupwallet/backup_wallet_bloc.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/main/main_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class BackupWalletPage extends StatelessWidget {
  final Wallet wallet;

  const BackupWalletPage(this.wallet, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BackupWalletBloc>(
        create: (_) => BackupWalletBloc(wallet)..add(InitEvent()),
        child: _BackupWalletView(wallet.address));
  }
}

class _BackupWalletView extends StatelessWidget {
  final String address;

  const _BackupWalletView(this.address);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QrlAppBar(),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(AppLocalizations.of(context)!.recoverySeeds,
                  style: const TextStyle(
                    color: CustomColors.qrlLightBlueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: SelectableText(
                "Q$address",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _buildMnemonicBlocBuilder(),
          _buildHexSeedBlocBuilder(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
              child: Text(AppLocalizations.of(context)!.warning,
                  style: const TextStyle(
                    color: CustomColors.qrlLightBlueColor,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              child: Text(
                AppLocalizations.of(context)!.recoveryWarning,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: 256,
                  child: QrlButton(
                    () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainPage()),
                          (route) => false);
                    },
                    text: AppLocalizations.of(context)!.done,
                    baseColor: CustomColors.qrlLightBlueColor,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  BlocBuilder<BackupWalletBloc, BackupWalletState> _buildMnemonicBlocBuilder() {
    return BlocBuilder<BackupWalletBloc, BackupWalletState>(
        buildWhen: (previous, current) =>
            current.status == BackupWalletStatus.ready,
        builder: (context, state) {
          return _buildCopyColumn(
              context,
              AppLocalizations.of(context)!.mnemonic,
              state.mnemonic,
              AppLocalizations.of(context)!.loadingMnemonic);
        });
  }

  BlocBuilder<BackupWalletBloc, BackupWalletState> _buildHexSeedBlocBuilder() {
    return BlocBuilder<BackupWalletBloc, BackupWalletState>(
      buildWhen: (previous, current) =>
          current.status == BackupWalletStatus.loadingMnemonic,
      builder: (context, state) {
        return _buildCopyColumn(context, AppLocalizations.of(context)!.hexseed,
            state.hexSeed, AppLocalizations.of(context)!.loadingHexSeed);
      },
    );
  }

  Column _buildCopyColumn(BuildContext context, String header, String? value,
      String loadingMessage) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(header,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CustomColors.qrlYellowColor,
                      fontWeight: FontWeight.bold,
                    )),
              )),
              SizedBox(
                width: 32,
                child: IconButton(
                  icon: const Icon(
                    Icons.copy_all,
                  ),
                  tooltip: AppLocalizations.of(context)!.copy,
                  color: CustomColors.qrlYellowColor,
                  onPressed: value != null
                      ? () {
                          _copy(value, context);
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
        value == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(loadingMessage),
                    ],
                  ),
                ),
              )
            : Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: SelectableText(
                    value,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ],
    );
  }

  _copy(String copyValue, BuildContext context) async {
    Clipboard.setData(ClipboardData(text: copyValue)).then((value) {
      SnackBars.showSnackBar(
          context, AppLocalizations.of(context)!.copiedToClipboard);
    });
  }
}
