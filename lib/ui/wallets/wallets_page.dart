import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:mobile_wallet/ui/backupwallet/backup_wallet_page.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/middle_ellipsis_text.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/wallets/changewalletname/change_wallet_name_bloc.dart';
import 'package:mobile_wallet/ui/wallets/changewalletname/change_wallet_name_view.dart';
import 'package:mobile_wallet/ui/wallets/wallets_bloc.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletsBloc>(
        create: (_) => WalletsBloc()..add(InitEvent()),
        child: const _WalletsView());
  }
}

class _WalletsView extends StatelessWidget {
  const _WalletsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(AppLocalizations.of(context)!.wallets,
                style: const TextStyle(
                  color: CustomColors.qrlLightBlueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
          ),
        ),
        Expanded(
          child: _buildWalletsBlocConsumer(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 16),
            child: SizedBox(
              width: 256,
              child: QrlButton(
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddWalletPage()),
                ),
                text: AppLocalizations.of(context)!.addWallet,
                baseColor: CustomColors.qrlLightBlueColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  BlocConsumer<WalletsBloc, WalletsState> _buildWalletsBlocConsumer() {
    return BlocConsumer<WalletsBloc, WalletsState>(
        listenWhen: (previous, current) =>
            current.status == WalletsStatus.noWallets ||
            current.status == WalletsStatus.deletingWallet ||
            current.status == WalletsStatus.walletDeleted ||
            current.status == WalletsStatus.authenticationFailed ||
            current.status == WalletsStatus.authenticated,
        listener: (context, state) {
          switch (state.status) {
            case WalletsStatus.noWallets:
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddWalletPage()),
                  (route) => false);
              break;
            case WalletsStatus.deletingWallet:
              Dialogs.showLoadingDialog(
                  context, AppLocalizations.of(context)!.deletingWallet);
              break;
            case WalletsStatus.walletDeleted:
              Dialogs.hideLoadingDialog(context);
              break;
            case WalletsStatus.authenticationFailed:
              SnackBars.showSnackBar(
                  context, AppLocalizations.of(context)!.authenticationFailed);
              break;
            case WalletsStatus.authenticated:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BackupWalletPage(state.selectedWallet!)),
              );
              break;
          }
        },
        buildWhen: (previous, current) =>
            current.status == WalletsStatus.loadingWallets ||
            current.status == WalletsStatus.ready ||
            current.status == WalletsStatus.walletDeleted,
        builder: (context, state) {
          if (state.status == WalletsStatus.ready) {
            return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: state.wallets?.length ?? 0,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  Wallet wallet = state.wallets![index];
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 24, right: 24, top: 8, bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  wallet.name,
                                  style: const TextStyle(
                                      color: CustomColors.qrlLightBlueColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              MiddleEllipsisText(
                                "Q${wallet.address}",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[500],
                                ),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: Icon(
                                  color: CustomColors.qrlYellowColor,
                                  Icons.edit),
                            ),
                            onTap: () =>
                                _showUpdateWalletName(context, wallet)),
                        InkWell(
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4, right: 4),
                              child: Icon(
                                  color: CustomColors.qrlYellowColor,
                                  Icons.remove_red_eye),
                            ),
                            onTap: () => BlocProvider.of<WalletsBloc>(context)
                                .add(BackupWalletEvent(wallet))),
                        InkWell(
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                  color: CustomColors.qrlYellowColor,
                                  Icons.delete_outline_sharp),
                            ),
                            onTap: () => Dialogs.showConfirmDialog(
                                    context,
                                    AppLocalizations.of(context)!
                                        .confirmRemoveWallet, () {
                                  BlocProvider.of<WalletsBloc>(context)
                                      .add(DeleteWalletEvent(wallet));
                                })),
                      ],
                    ),
                  );
                });
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(AppLocalizations.of(context)!.loadingWallets),
                ],
              ),
            ),
          );
        });
  }

  _showUpdateWalletName(BuildContext context, Wallet wallet) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return BlocProvider<WalletsBloc>.value(
              value: BlocProvider.of<WalletsBloc>(context),
              child: BlocProvider<ChangeWalletNameBloc>(
                  create: (_) => ChangeWalletNameBloc(wallet),
                  child: BlocListener<ChangeWalletNameBloc,
                          ChangeWalletNameState>(
                      listenWhen: (previous, current) =>
                          current.status == ChangeWalletNameStatus.nameSaved,
                      listener: (context, state) {
                        if (state.status == ChangeWalletNameStatus.nameSaved) {
                          BlocProvider.of<WalletsBloc>(context)
                              .add(WalletNameUpdatedEvent(state.wallet));
                          Navigator.of(context).pop();
                        }
                      },
                      child: ChangeWalletNameView(wallet.name))));
        });
  }
}
