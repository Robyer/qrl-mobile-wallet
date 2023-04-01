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

  Scaffold _buildScaffold(BuildContext context, SendTransactionState state) {
    return Scaffold(
        appBar: QrlAppBar(),
        body: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.sendTitle,
                      style: const TextStyle(
                        color: CustomColors.qrlLightBlueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )),
                ),
              ),
              Center(
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Text(
                        AppLocalizations.of(context)!.confirmTransaction,
                      ))),
              Expanded(
                child: ListView.builder(
                  itemCount: state.transactionLines.length,
                  itemBuilder: (context, index) {
                    final TransactionLine transactionLine =
                        state.transactionLines[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!.amount,
                            style: const TextStyle(
                              color: CustomColors.qrlYellowColor,
                            ),
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 36),
                          child: Center(
                              child: Text(
                            "${StringUtil.formatAmount(transactionLine.amount!)} QRL",
                          )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Center(
                              child: Text(
                            AppLocalizations.of(context)!
                                .sendingToWalletAddress,
                            style: const TextStyle(
                              color: CustomColors.qrlYellowColor,
                            ),
                          )),
                        ),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 48),
                          child: SelectableText(
                            transactionLine.address!,
                            textAlign: TextAlign.center,
                          ),
                        )),
                      ],
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: SizedBox(
                    width: 256,
                    child: QrlButton(
                      () {
                        _onPressConfirmTransaction(context);
                      },
                      text: AppLocalizations.of(context)!.confirm,
                      baseColor: CustomColors.qrlLightBlueColor,
                    ),
                  ),
                ),
              ),
            ]));
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
