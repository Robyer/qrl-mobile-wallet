import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_date_field.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/tools/export/export_transactions_bloc.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class ExportTransactionsPage extends StatelessWidget {
  const ExportTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExportTransactionsBloc>(
      create: (_) => ExportTransactionsBloc()..add(InitEvent()),
      child: const _ExportTransactionsView(),
    );
  }
}

class _ExportTransactionsView extends StatelessWidget {
  const _ExportTransactionsView();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return BlocListener<ExportTransactionsBloc, ExportTransactionsState>(
      listenWhen: (previous, current) =>
          (previous.status != ExportTransactionsStatus.exportComplete &&
              current.status == ExportTransactionsStatus.exportComplete) ||
          (previous.status != ExportTransactionsStatus.exportComplete &&
              current.status == ExportTransactionsStatus.exportComplete) ||
          (previous.status != ExportTransactionsStatus.exporting &&
              current.status == ExportTransactionsStatus.exporting),
      listener: (context, state) {
        switch (state.status) {
          case ExportTransactionsStatus.exporting:
            Dialogs.showLoadingDialog(
                context, AppLocalizations.of(context)!.exporting);
            break;
          case ExportTransactionsStatus.error:
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(context, state.errorMessage ?? "");
            break;
          case ExportTransactionsStatus.exportComplete:
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(context,
                "${AppLocalizations.of(context)!.exportedCSVTo} ${state.fileLocation}");
            break;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: CustomColors.qrlDarkBlueLinearGradient,
          image: DecorationImage(
            image: const AssetImage('assets/images/orange-dots-2.png'),
            alignment: Alignment.bottomCenter,
            colorFilter: ColorFilter.mode(
              CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Scaffold(
          appBar: QrlTitleAppBar(
            titleText: AppLocalizations.of(context)!.exportToolsTitle,
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: NotificationListener(
                  onNotification: (OverscrollIndicatorNotification overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildWalletsBlocBuilder(),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8, top: 8, right: 24, left: 24),
                          child: QrlDateField(
                            (value) {
                              if (value != null) {
                                BlocProvider.of<ExportTransactionsBloc>(context)
                                    .add(FromDateChangedEvent(value));
                              }
                            },
                            title: AppLocalizations.of(context)!.fromDate,
                            mandatory: true,
                            initialValue: DateTime(now.year, now.month, 1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 8, top: 8, right: 24, left: 24),
                          child: QrlDateField(
                            (value) {
                              if (value != null) {
                                BlocProvider.of<ExportTransactionsBloc>(context)
                                    .add(ToDateChangedEvent(value));
                              }
                            },
                            title: AppLocalizations.of(context)!.toDate,
                            mandatory: true,
                            initialValue: DateTime(now.year, now.month + 1, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildExport(context),
            ],
          ),
        ),
      ),
    );
  }

  BlocBuilder<ExportTransactionsBloc, ExportTransactionsState>
      _buildWalletsBlocBuilder() {
    return BlocBuilder<ExportTransactionsBloc, ExportTransactionsState>(
        buildWhen: (previous, current) =>
            previous.status == ExportTransactionsStatus.loadingWallets ||
            current.status == ExportTransactionsStatus.loadingWallets,
        builder: (context, state) {
          if (state.status != ExportTransactionsStatus.loadingWallets &&
              state.currentWallet != null &&
              state.wallets.isNotEmpty) {
            return BottomSheetSelect<Wallet>(
              selectedItem: state.currentWallet!,
              items: state.wallets,
              floatingLabelValue: AppLocalizations.of(context)!.wallet,
              valueChanged: (value) {
                BlocProvider.of<ExportTransactionsBloc>(context)
                    .add(WalletChangedEvent(value));
              },
              labelConverter: (value) {
                return value.name;
              },
              itemWidgetConverter: (value) {
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8, top: 8, right: 16, left: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicWidth(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  value.name,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    color: CustomColors.qrlLightBlueColor,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Q${value.address}",
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[500],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return BottomSheetSelect<String>(
            selectedItem: "",
            items: const [""],
            floatingLabelValue: AppLocalizations.of(context)!.wallet,
            valueChanged: (value) {},
          );
        });
  }

  Widget _buildExport(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        child: SizedBox(
          width: 256,
          child: BlocBuilder<ExportTransactionsBloc, ExportTransactionsState>(
              buildWhen: (previous, current) =>
                  previous.status == ExportTransactionsStatus.exportable ||
                  current.status == ExportTransactionsStatus.exportable,
              builder: (context, state) {
                return QrlButton(
                  state.status == ExportTransactionsStatus.exportable
                      ? () {
                          BlocProvider.of<ExportTransactionsBloc>(context)
                              .add(ExportEvent());
                        }
                      : null,
                  text: AppLocalizations.of(context)!.export,
                  baseColor: CustomColors.qrlLightBlueColor,
                  backgroundColor: CustomColors.qrlLightBlueColorBackground,
                );
              }),
        ),
      ),
    );
  }
}
