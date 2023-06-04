import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/service/authentication_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/main/main_page.dart';
import 'package:mobile_wallet/ui/sendtransaction/bloc/send_transaction_bloc.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/util/string_util.dart';

class ConfirmTransactionPage extends StatelessWidget {
  const ConfirmTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendTransactionBloc, SendTransactionState>(
        listenWhen: (previous, current) =>
            current.status == SendTransactionStatus.sending ||
            current.status == SendTransactionStatus.sendError ||
            current.status == SendTransactionStatus.send,
        listener: (context, state) {
          switch (state.status) {
            case SendTransactionStatus.sending:
              Dialogs.showLoadingDialog(
                  context, AppLocalizations.of(context)!.verifyingTransaction);
              break;
            case SendTransactionStatus.sendError:
              Dialogs.hideLoadingDialog(context);
              SnackBars.showSnackBar(context,
                  "${AppLocalizations.of(context)!.errorSendTransaction} ${state.errorMessage}");
              break;
            case SendTransactionStatus.send:
              Future.delayed(const Duration(milliseconds: 1000), () {
                Dialogs.hideLoadingDialog(context);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (route) => false);
              });
              break;
          }
        },
        buildWhen: (previous, current) =>
            current.status == SendTransactionStatus.reviewable,
        builder: (context, state) => _buildScaffold(context, state));
  }

  Container _buildScaffold(BuildContext context, SendTransactionState state) {
    return Container(
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
          appBar: QrlTitleAppBar(
              titleText: AppLocalizations.of(context)!.sendTitle),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.message != null && state.message!.isNotEmpty)
                    Card(
                      elevation: 1,
                      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(AppLocalizations.of(context)!.message,
                                  style: const TextStyle(
                                    color: CustomColors.qrlYellowColor,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SelectableText(
                                state.message!,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: NotificationListener(
                      onNotification:
                          (OverscrollIndicatorNotification overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView.builder(
                        itemCount: state.transactionLines.length,
                        itemBuilder: (context, index) {
                          final TransactionLine transactionLine =
                              state.transactionLines[index];
                          return Card(
                            elevation: 1,
                            color:
                                CustomColors.qrlLightBlueColor.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 8, bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      AppLocalizations.of(context)!.amount,
                                      style: const TextStyle(
                                        color: CustomColors.qrlYellowColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      "${StringUtil.formatAmount(transactionLine.amount!)} QRL",
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .sendingToWalletAddress,
                                      style: const TextStyle(
                                        color: CustomColors.qrlYellowColor,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: SelectableText(
                                      transactionLine.address!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                            _onPressConfirmTransaction(context);
                          },
                          text: AppLocalizations.of(context)!.confirm,
                          baseColor: CustomColors.qrlLightBlueColor,
                          backgroundColor:
                              CustomColors.qrlLightBlueColorBackground,
                        ),
                      ),
                    ),
                  ),
                ]),
          )),
    );
  }

  void _onPressConfirmTransaction(BuildContext context) async {
    if (await getIt<AuthenticationService>().authenticate()) {
      BlocProvider.of<SendTransactionBloc>(context).add(SendEvent());
    } else {
      SnackBars.showSnackBar(
          context, AppLocalizations.of(context)!.authenticationFailed);
    }
  }
}
