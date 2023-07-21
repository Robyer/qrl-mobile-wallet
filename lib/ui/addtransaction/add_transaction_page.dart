import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/changefee/change_fee_bloc.dart';
import 'package:mobile_wallet/ui/changefee/change_fee_view.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';
import 'package:mobile_wallet/util/string_util.dart';

abstract class AddTransactionPage<T extends AddTransactionBloc>
    extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<T, AddTransactionState>(
      listenWhen: (previous, current) =>
          (previous.status != AddTransactionStatus.verifying &&
              current.status == AddTransactionStatus.verifying) ||
          (previous.status != AddTransactionStatus.error &&
              current.status == AddTransactionStatus.error) ||
          (previous.status != AddTransactionStatus.verified &&
              current.status == AddTransactionStatus.verified),
      listener: (context, state) async {
        switch (state.status) {
          case AddTransactionStatus.verifying:
            Dialogs.showLoadingDialog(
                context, AppLocalizations.of(context)!.verifyingTransaction);
            break;
          case AddTransactionStatus.error:
            Util.dismissKeyboard(context);
            Dialogs.hideLoadingDialog(context);
            SnackBars.showSnackBar(context,
                "${AppLocalizations.of(context)!.errorSendTransaction} ${state.errorMessage}");
            break;
          case AddTransactionStatus.verified:
            await onVerified(context, state);
            break;
        }
      },
      child: buildComponent(context),
    );
  }

  Widget buildComponent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-5.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        appBar: QrlTitleAppBar(titleText: getTitleText(context)),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: NotificationListener(
                onNotification: (OverscrollIndicatorNotification overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: ListView(
                  children: [
                    _buildWalletsBlocBuilder(),
                    _buildBalanceComponent(context),
                    _buildOtsComponent(context),
                    _buildFeeBlocBuilder(context),
                    ...buildWidgets(context),
                  ],
                ),
              ),
            ),
            _buildReview(context),
          ],
        ),
      ),
    );
  }

  BlocBuilder<T, AddTransactionState> _buildWalletsBlocBuilder() {
    return BlocBuilder<T, AddTransactionState>(
        buildWhen: (previous, current) =>
            previous.status == AddTransactionStatus.loadingWallets ||
            current.status == AddTransactionStatus.loadingWallets,
        builder: (context, state) {
          if (state.status != AddTransactionStatus.loadingWallets &&
              state.currentWallet != null &&
              state.wallets.isNotEmpty) {
            return BottomSheetSelect<Wallet>(
              selectedItem: state.currentWallet!,
              items: state.wallets,
              floatingLabelValue: AppLocalizations.of(context)!.wallet,
              valueChanged: (value) {
                BlocProvider.of<T>(context).add(WalletChangedEvent(value));
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

  Widget _buildBalanceComponent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text("${AppLocalizations.of(context)!.balance}:"),
          ),
          BlocBuilder<T, AddTransactionState>(
              buildWhen: (previous, current) =>
                  previous.status != AddTransactionStatus.ready &&
                  current.status == AddTransactionStatus.ready,
              builder: (context, state) {
                if (state.extendedWalletData != null) {
                  return Text(
                      "${StringUtil.formatAmount(state.extendedWalletData?.balance ?? 0)} QRL",
                      style: const TextStyle(
                          color: CustomColors.qrlLightBlueColor));
                }
                return Container();
              }),
        ],
      ),
    );
  }

  BlocBuilder<T, AddTransactionState> _buildFeeBlocBuilder(
      BuildContext context) {
    return BlocBuilder<T, AddTransactionState>(
        buildWhen: (previous, current) => previous.fee != current.fee,
        builder: (context, state) {
          return Padding(
            padding:
                const EdgeInsets.only(top: 4, bottom: 8, left: 24, right: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    AppLocalizations.of(context)!.fee,
                  ),
                ),
                IntrinsicWidth(
                  child: Text(
                    StringUtil.formatAmount(state.fee),
                    style:
                        const TextStyle(color: CustomColors.qrlLightBlueColor),
                    maxLines: 2,
                  ),
                ),
                InkWell(
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4, right: 4),
                      child: Icon(
                          size: 18,
                          color: CustomColors.qrlLightBlueColor,
                          Icons.edit),
                    ),
                    onTap: () => _showUpdateFee(context, state.fee)),
              ],
            ),
          );
        });
  }

  _showUpdateFee(BuildContext context, int currentFee) {
    Util.dismissKeyboard(context);
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return BlocProvider<T>.value(
              value: BlocProvider.of<T>(context),
              child: BlocProvider<ChangeFeeBloc>(
                  create: (_) => ChangeFeeBloc(currentFee),
                  child: BlocListener<ChangeFeeBloc, ChangeFeeState>(
                      listenWhen: (previous, current) =>
                          current.status == ChangeFeeStatus.feeSaved,
                      listener: (context, state) {
                        if (state.status == ChangeFeeStatus.feeSaved) {
                          BlocProvider.of<T>(context)
                              .add(FeeChangedEvent(state.newFee!));
                          Navigator.of(context).pop();
                        }
                      },
                      child: ChangeFeeView(currentFee))));
        });
  }

  Widget _buildOtsComponent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 24),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(AppLocalizations.of(context)!.otsKeyIndex),
          ),
          BlocBuilder<T, AddTransactionState>(
              buildWhen: (previous, current) =>
                  previous.status != AddTransactionStatus.ready &&
                  current.status == AddTransactionStatus.ready,
              builder: (context, state) {
                if (state.currentWallet != null &&
                    state.extendedWalletData != null) {
                  return Util.getOtsIndexText(
                      state.currentWallet!, state.extendedWalletData!);
                }
                return Container();
              }),
        ],
      ),
    );
  }

  Widget _buildReview(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, top: 8),
        child: SizedBox(
          width: 256,
          child: BlocBuilder<T, AddTransactionState>(
              buildWhen: (previous, current) =>
                  previous.reviewable != current.reviewable,
              builder: (context, state) {
                return QrlButton(
                  state.reviewable
                      ? () {
                          int otsKeysLeft = Util.getOtsKeysLeft(
                              state.currentWallet!, state.extendedWalletData!);
                          if (otsKeysLeft < 1) {
                            SnackBars.showSnackBar(context,
                                "${AppLocalizations.of(context)!.noMoreOts1} ${StringUtil.formatAmount(state.extendedWalletData!.balance)} ${AppLocalizations.of(context)!.noMoreOts2}");
                          } else if (otsKeysLeft < 6) {
                            Dialogs.showConfirmDialog(context,
                                "${AppLocalizations.of(context)!.otsKeysLeft1} $otsKeysLeft ${AppLocalizations.of(context)!.otsKeysLeft2}",
                                header: AppLocalizations.of(context)!.warning,
                                () {
                              BlocProvider.of<T>(context).add(ReviewEvent());
                            });
                          } else {
                            BlocProvider.of<T>(context).add(ReviewEvent());
                          }
                        }
                      : null,
                  text: AppLocalizations.of(context)!.review.toUpperCase(),
                  baseColor: CustomColors.qrlLightBlueColor,
                  backgroundColor: CustomColors.qrlLightBlueColorBackground,
                );
              }),
        ),
      ),
    );
  }

  String getTitleText(BuildContext context);

  List<Widget> buildWidgets(BuildContext context);

  Future<void> onVerified(BuildContext context, AddTransactionState state);
}
