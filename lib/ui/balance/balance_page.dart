import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:mobile_wallet/ui/balance/assets/assets_page.dart';
import 'package:mobile_wallet/ui/balance/community_list.dart';
import 'package:mobile_wallet/ui/balance/receive_amount_page.dart';
import 'package:mobile_wallet/ui/balance/transactions/transactions_page.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_page.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/util/string_util.dart';

import 'bloc/balance_bloc.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BalanceBloc>(
        create: (_) => BalanceBloc()..add(InitEvent()),
        child: const _BalanceView());
  }
}

class _BalanceView extends StatelessWidget {
  const _BalanceView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BalanceBloc, BalanceState>(
      listenWhen: (previous, current) =>
          current.status == BalanceStatus.noWallets ||
          current.status == BalanceStatus.error,
      listener: (context, state) {
        if (state.status == BalanceStatus.noWallets) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AddWalletPage()),
              (route) => false);
        } else if (state.status == BalanceStatus.error) {
          SnackBars.showSnackBar(context,
              "${AppLocalizations.of(context)!.errorDuringBalanceRetrieval} ${state.errorMessage}",
              duration: const Duration(seconds: 6, milliseconds: 1500));
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: CustomColors.qrlDarkBlueLinearGradient,
            ),
            child: Scaffold(
              appBar: _buildAppBar(),
              body: _buildBalanceBox(context),
            ),
          ),
          _buildNotificationListener(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: _buildWalletsBlocBuilder(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Image.asset(
            'assets/images/qrl-logo.png',
            fit: BoxFit.contain,
            height: 60,
          ),
        ),
      ],
    );
  }

  BlocBuilder<BalanceBloc, BalanceState> _buildWalletsBlocBuilder() {
    return BlocBuilder<BalanceBloc, BalanceState>(
        buildWhen: (previous, current) =>
            previous.status == BalanceStatus.loadingWallets ||
            current.status == BalanceStatus.loadingWallets,
        builder: (context, state) {
          if (state.status != BalanceStatus.loadingWallets &&
              state.currentWallet != null &&
              state.wallets.isNotEmpty) {
            return BottomSheetSelect<Wallet>(
              selectedItem: state.currentWallet!,
              items: state.wallets,
              valueChanged: (value) {
                BlocProvider.of<BalanceBloc>(context)
                    .add(WalletChangedEvent(value));
              },
              labelWidgetConverter: (value) {
                return Row(
                  children: [
                    Text(value.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                        )),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                );
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
          return Container();
        });
  }

  Padding _buildBalanceBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Opacity(
            opacity: 0.1,
            child: Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Image.asset(
                'assets/images/background-wallet.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 12, left: 24, right: 24, bottom: 8),
                  child: _buildBalanceBlocBuilder(),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                  child: _buildConvertedBalanceBlocBuilder(),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => _onClickAssets(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.only(left: 12, right: 4),
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                          color: CustomColors.qrlLightBlueColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.menu_book_outlined,
                            color: CustomColors.qrlLightBlueColor),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(AppLocalizations.of(context)!.assets),
                        ),
                        const Icon(Icons.keyboard_arrow_right_outlined,
                            color: CustomColors.qrlLightBlueColor),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                  child: Text(
                    AppLocalizations.of(context)!.priceChange,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CustomColors.qrlYellowColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                  child: BlocBuilder<BalanceBloc, BalanceState>(
                      buildWhen: (previous, current) =>
                          (previous.marketData?.change24Hr ?? 0) !=
                          (current.marketData?.change24Hr ?? 0),
                      builder: (context, state) {
                        return Text(
                          "${state.marketData?.change24Hr ?? "0.0"}%",
                          textAlign: TextAlign.center,
                        );
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(children: [
                          Text(AppLocalizations.of(context)!.marketCap),
                          BlocBuilder<BalanceBloc, BalanceState>(
                              buildWhen: (previous, current) =>
                                  (previous.marketData?.marketCap ?? 0) !=
                                  (current.marketData?.marketCap ?? 0),
                              builder: (context, state) {
                                return Text(
                                  state.marketData != null
                                      ? "\$ ${(state.marketData!.marketCap / Decimal.fromInt(1000000)).toDecimal().toStringAsFixed(2)}M USD"
                                      : "0.00 USD",
                                );
                              }),
                        ]),
                      ),
                      Expanded(
                        child: Column(children: [
                          Text(AppLocalizations.of(context)!.price),
                          BlocBuilder<BalanceBloc, BalanceState>(
                              buildWhen: (previous, current) =>
                                  (previous.marketData?.price ?? 0) !=
                                  (current.marketData?.price ?? 0),
                              builder: (context, state) {
                                return Text(
                                    "\$ ${state.marketData?.price.toStringAsFixed(2) ?? "0.00"} USD");
                              }),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              _buildButtonBar(context)
            ],
          )
        ],
      ),
    );
  }

  BlocBuilder<BalanceBloc, BalanceState> _buildBalanceBlocBuilder(
      {bool small = false}) {
    return BlocBuilder<BalanceBloc, BalanceState>(
        buildWhen: (previous, current) =>
            (previous.extendedWalletData?.balance ?? 0) !=
            (current.extendedWalletData?.balance ?? 0),
        builder: (context, state) {
          TextStyle textStyle;
          if (small) {
            textStyle = const TextStyle(
              fontSize: 16,
            );
          } else {
            textStyle = const TextStyle(
              color: CustomColors.qrlLightBlueColor,
              fontSize: 16,
            );
          }
          return Text(
            "${StringUtil.formatAmount(state.extendedWalletData?.balance ?? 0)} QRL",
            textAlign: TextAlign.center,
            style: textStyle,
          );
        });
  }

  BlocBuilder<BalanceBloc, BalanceState> _buildConvertedBalanceBlocBuilder() {
    return BlocBuilder<BalanceBloc, BalanceState>(
        buildWhen: (previous, current) =>
            ((previous.extendedWalletData?.balance ?? 0) !=
                    (current.extendedWalletData?.balance ?? 0) &&
                current.marketData != null) ||
            (previous.marketData != current.marketData &&
                current.extendedWalletData != null),
        builder: (context, state) {
          if (state.extendedWalletData != null && state.marketData != null) {
            Decimal balance =
                (Decimal.fromInt(state.extendedWalletData!.balance) /
                        Decimal.fromInt(1000000000))
                    .toDecimal();
            Decimal result = balance * state.marketData!.price;
            return Text(
              "\$ ${result.toStringAsFixed(2)}",
              textAlign: TextAlign.center,
            );
          }
          return const Text(
            "\$ 00.00",
            textAlign: TextAlign.center,
          );
        });
  }

  Stack _buildButtonBar(BuildContext context) {
    return Stack(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: QrlButton(
                    () => _onClickSend(context),
                    text: AppLocalizations.of(context)!.send,
                    baseColor: CustomColors.qrlLightBlueColor,
                    backgroundColor: CustomColors.qrlLightBlueColorBackground,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: QrlButton(
                    () => _onClickReceive(context),
                    text: AppLocalizations.of(context)!.receive,
                    baseColor: CustomColors.qrlLightBlueColor,
                    backgroundColor: CustomColors.qrlLightBlueColorBackground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          shape: const StadiumBorder(
              side: BorderSide(
                  color: CustomColors.qrlLightBlueMaterial, width: 1)),
          onPressed: () => _onClickTransactions(context),
          backgroundColor: CustomColors.qrlLightBlueColorBackground,
          child: const Icon(Icons.import_export),
        ),
      )
    ]);
  }

  void _onClickSend(BuildContext context) {
    BalanceState state = BlocProvider.of<BalanceBloc>(context).state;
    if (state.currentWallet != null && state.extendedWalletData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddTransferPage(),
        ),
      );
    }
  }

  void _onClickReceive(BuildContext context) {
    BalanceState state = BlocProvider.of<BalanceBloc>(context).state;
    if (state.currentWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ReceiveAmountPage(state.currentWallet!)),
      );
    }
  }

  void _onClickTransactions(BuildContext context) {
    BalanceState state = BlocProvider.of<BalanceBloc>(context).state;
    if (state.currentWallet != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TransactionsPage(state.currentWallet!)),
      );
    }
  }

  void _onClickAssets(BuildContext context) {
    BalanceState state = BlocProvider.of<BalanceBloc>(context).state;
    if (state.currentWallet != null && state.extendedWalletData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssetsPage(state.currentWallet!),
        ),
      );
    }
  }

  NotificationListener<DraggableScrollableNotification>
      _buildNotificationListener(BuildContext context) {
    double height = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top + kToolbarHeight);
    double childHeight = 1 - (325 / height);
    if (childHeight > 0.65) {
      childHeight = 0.65;
    }
    if (childHeight < 0.1) {
      childHeight = 0.1;
    }
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (DraggableScrollableNotification notification) {
        BalanceBloc balanceBloc = BlocProvider.of<BalanceBloc>(context);
        if (!balanceBloc.state.expanded && notification.extent >= 0.70) {
          balanceBloc.add(const ExpandedChangedEvent(true));
        } else if (balanceBloc.state.expanded && notification.extent < 0.70) {
          balanceBloc.add(const ExpandedChangedEvent(false));
        }
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: childHeight,
        minChildSize: childHeight,
        maxChildSize: 1,
        expand: true,
        snap: true,
        snapSizes: [childHeight, 1],
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: const BoxDecoration(
                    color: CustomColors.qrlDarkBlueMaterial,
                  ),
                  child: Column(
                    children: [
                      _buildBalanceBoxSmall(),
                      CommunityList(scrollController)
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  BlocBuilder<BalanceBloc, BalanceState> _buildBalanceBoxSmall() {
    return BlocBuilder<BalanceBloc, BalanceState>(
        buildWhen: (previous, current) => previous.expanded != current.expanded,
        builder: (context, state) {
          if (state.expanded) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff163246),
                    CustomColors.qrlDarkBlueMaterial,
                  ],
                  stops: [0.4, 0.9],
                ),
              ),
              child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceBlocBuilder(small: true),
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Image.asset(
                              'assets/images/qrl-logo.png',
                              fit: BoxFit.contain,
                              height: 56,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            QrlButton(
                              () => _onClickSend(context),
                              text: AppLocalizations.of(context)!.send,
                              baseColor: CustomColors.qrlLightBlueColor,
                              backgroundColor:
                                  CustomColors.qrlLightBlueColorBackground,
                            ),
                            QrlButton(
                              () => _onClickReceive(context),
                              text: AppLocalizations.of(context)!.receive,
                              baseColor: CustomColors.qrlLightBlueColor,
                              backgroundColor:
                                  CustomColors.qrlLightBlueColorBackground,
                            ),
                            QrlButton(
                              () => _onClickTransactions(context),
                              text: AppLocalizations.of(context)!
                                  .transactions
                                  .toUpperCase(),
                              baseColor: CustomColors.qrlLightBlueColor,
                              backgroundColor:
                                  CustomColors.qrlLightBlueColorBackground,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            );
          }
          return Container();
        });
  }
}
