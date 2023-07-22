import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/service/authentication_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/util/component_util.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';
import 'package:mobile_wallet/util/string_util.dart';

import '../component/qrl_app_bar.dart';

abstract class ReviewTransactionPage<T extends AddTransactionBloc<U>,
    U extends AddTransactionState> extends StatelessWidget {
  const ReviewTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<T, U>(
        listenWhen: (previous, current) => true,
        listener: (context, state) {
          switch (state.status) {
            case AddTransactionStatus.sending:
              Dialogs.showLoadingDialog(
                  context, AppLocalizations.of(context)!.verifyingTransaction);
              break;
            case AddTransactionStatus.sendError:
              Dialogs.hideLoadingDialog(context);
              SnackBars.showSnackBar(context,
                  "${AppLocalizations.of(context)!.errorSendTransaction} ${state.errorMessage}");
              break;
            case AddTransactionStatus.send:
              Dialogs.hideLoadingDialog(context);
              break;
          }
        },
        buildWhen: (previous, current) =>
            current.reviewable == true &&
            (previous.status != AddTransactionStatus.send &&
                current.status == AddTransactionStatus.send),
        builder: (context, state) => _buildScaffold(context, state));
  }

  Widget _buildScaffold(BuildContext context, U state) {
    return WillPopScope(
      onWillPop: () async {
        if (state.status == AddTransactionStatus.send) {
          Util.dismissKeyboard(context);
          Navigator.of(context).popUntil((route) => route.isFirst);
          return false;
        } else {
          Util.dismissKeyboard(context);
          BlocProvider.of<T>(context).add(BackEvent());
          return true;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: CustomColors.qrlDarkBlueLinearGradient,
          image: DecorationImage(
            image: const AssetImage('assets/images/orange-dots-4.png'),
            alignment: Alignment.bottomCenter,
            colorFilter: ColorFilter.mode(
              CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Scaffold(
            appBar:
                QrlTitleAppBar(titleText: AppLocalizations.of(context)!.review),
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: NotificationListener(
                        onNotification:
                            (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowIndicator();
                          return true;
                        },
                        child: ListView(
                          children: [
                            _buildTransactionHash(context),
                            ComponentUtil.buildLabelValueCard(
                                AppLocalizations.of(context)!.fromAddress,
                                "Q${state.currentWallet!.address}"),
                            ComponentUtil.buildLabelValueCard(
                                AppLocalizations.of(context)!.fee,
                                "${StringUtil.formatAmount(state.fee)} QRL"),
                            ComponentUtil.buildLabelValueCard(
                                AppLocalizations.of(context)!.otsKeyIndex,
                                "${state.extendedWalletData!.otsIndex}"),
                            ...buildWidgets(context, state),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: 256,
                          child: QrlButton(
                            () {
                              if (state.status == AddTransactionStatus.send) {
                                Util.dismissKeyboard(context);
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              } else {
                                _onPressConfirmTransaction(context);
                              }
                            },
                            text: state.status == AddTransactionStatus.send
                                ? AppLocalizations.of(context)!.done
                                : AppLocalizations.of(context)!.confirm,
                            baseColor: CustomColors.qrlLightBlueColor,
                            backgroundColor:
                                CustomColors.qrlLightBlueColorBackground,
                          ),
                        ),
                      ),
                    ),
                  ]),
            )),
      ),
    );
  }

  Widget _buildTransactionHash(BuildContext context) {
    return BlocBuilder<T, U>(
      buildWhen: (previous, current) =>
          current.transactionHash != null &&
          previous.transactionHash != current.transactionHash,
      builder: (context, state) {
        if (state.transactionHash != null) {
          return Card(
            elevation: 1,
            color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(AppLocalizations.of(context)!.transactionHash,
                          style: const TextStyle(
                            color: CustomColors.qrlYellowColor,
                          )),
                      SizedBox(
                        height: 32,
                        child: IconButton(
                          icon: const Icon(
                            Icons.copy_all,
                          ),
                          tooltip: AppLocalizations.of(context)!.copy,
                          color: CustomColors.qrlYellowColor,
                          onPressed: () =>
                              _copy(state.transactionHash!, context),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: SelectableText(
                      state.transactionHash!,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  void _onPressConfirmTransaction(BuildContext context) async {
    if (await getIt<AuthenticationService>().authenticate()) {
      BlocProvider.of<T>(context).add(SendEvent());
    } else {
      SnackBars.showSnackBar(
          context, AppLocalizations.of(context)!.authenticationFailed);
    }
  }

  _copy(String copyValue, BuildContext context) async {
    Clipboard.setData(ClipboardData(text: copyValue)).then((value) {
      SnackBars.showSnackBar(
          context, AppLocalizations.of(context)!.copiedToClipboard);
    });
  }

  List<Widget> buildWidgets(BuildContext context, U state);
}
