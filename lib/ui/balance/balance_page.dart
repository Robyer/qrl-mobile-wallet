import 'dart:developer';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/market_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/grpc_service.dart';
import 'package:mobile_wallet/service/market_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:mobile_wallet/ui/balance/receive_amount_page.dart';
import 'package:mobile_wallet/ui/sendtransaction/send_transaction_page.dart';
import 'package:mobile_wallet/ui/balance/transaction_data_page.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/util/string_util.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  List<Wallet>? _wallets;
  Wallet? _currentWallet;
  ExtendedWalletData? _extendedWalletData;
  MarketData? _marketData;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _wallets != null
                    ? BottomSheetSelect<Wallet>(
                        selectedItem: _currentWallet!,
                        items: _wallets!,
                        valueChanged: (value) {
                          getIt<WalletService>().setCurrentWalletId(value.id);
                          _setCurrentWallets(value, _wallets!);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IntrinsicWidth(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            value.name,
                                            overflow: TextOverflow.visible,
                                            style: const TextStyle(
                                              color: CustomColors
                                                  .qrlLightBlueColor,
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
                      )
                    : Container(),
              ],
            ),
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
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [buildBalanceBox(context), buildTransactionList(context)],
          ),
        ));
  }

  Padding buildBalanceBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Opacity(
            opacity: 0.1,
            child: Image.asset(
              'assets/images/background-wallet.png',
              fit: BoxFit.fill,
            ),
          ),
          Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 24, left: 24, right: 24, bottom: 8),
                  child: Text(
                    "${StringUtil.formatAmount(_extendedWalletData?.balance ?? 0)} QRL",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CustomColors.qrlLightBlueColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                  child: Text(
                    _extendedWalletData != null && _marketData != null
                        ? "\$ ${_getConvertedBalance()}"
                        : "\$ 00.00",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, bottom: 8, top: 8),
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
                      const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                  child: Text(
                    "${_marketData?.change24Hr ?? "0.0"}%",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(children: [
                          Text(AppLocalizations.of(context)!.marketCap),
                          Text(
                            _marketData != null ? _getMarketCap() : "0.00 USD",
                          )
                        ]),
                      ),
                      Expanded(
                        child: Column(children: [
                          Text(AppLocalizations.of(context)!.price),
                          Text(
                              "\$ ${_marketData?.price.toStringAsFixed(2) ?? "0.00"} USD"),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              buildButtonBar(context)
            ],
          )
        ],
      ),
    );
  }

  Stack buildButtonBar(BuildContext context) {
    return Stack(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: QrlButton(
                    () {
                      if (_currentWallet != null &&
                          _extendedWalletData != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SendTransactionPage(
                                  _currentWallet!, _extendedWalletData!)),
                        );
                      }
                    },
                    text: AppLocalizations.of(context)!.send,
                    baseColor: CustomColors.qrlLightBlueColor,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: QrlButton(
                    () {
                      if (_currentWallet != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ReceiveAmountPage(_currentWallet!)),
                        );
                      }
                    },
                    text: AppLocalizations.of(context)!.receive,
                    baseColor: CustomColors.qrlLightBlueColor,
                    backgroundColor: Colors.transparent,
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
          onPressed: () {
            _refresh();
          },
          backgroundColor: CustomColors.qrlLightBlueColorBackground,
          child: const Icon(Icons.refresh),
        ),
      )
    ]);
  }

  Expanded buildTransactionList(BuildContext context) {
    return Expanded(
      child: (_extendedWalletData?.transactions.length ?? 0) > 0
          ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _extendedWalletData?.transactions.length ?? 0,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => _onTapTransaction(index),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: CustomColors.qrlYellowColor)),
                            child: Icon(
                              _extendedWalletData!.transactions[index].incoming
                                  ? Icons.arrow_back
                                  : Icons.arrow_forward,
                              color: CustomColors.qrlYellowColor,
                              size: 28,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8, bottom: 4),
                              child: Row(
                                children: [
                                  Text(
                                    _extendedWalletData!
                                            .transactions[index].incoming
                                        ? AppLocalizations.of(context)!.received
                                        : AppLocalizations.of(context)!.sent,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      _extendedWalletData!
                                              .transactions[index].unconfirmed
                                          ? AppLocalizations.of(context)!
                                              .unconfirmed
                                          : "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: CustomColors.qrlYellowMaterial
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                DateFormat("HH:mm, MMM d yyyy").format(
                                    _extendedWalletData!
                                        .transactions[index].dateTime),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${_extendedWalletData!.transactions[index].incoming ? "+" : "-"} ${StringUtil.formatAmount(_extendedWalletData!.transactions[index].amount)} QRL",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
          : Text(AppLocalizations.of(context)!.noTransactionsFound),
    );
  }

  _init() async {
    WalletService walletService = getIt<WalletService>();
    List<Wallet> wallets = await walletService.getWallets();
    if (wallets.isEmpty) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AddWalletPage()),
            (route) => false);
      }
    } else {
      int? currentWalletId = await walletService.getCurrentWalletId();
      Wallet currentWallet = wallets.firstWhere(
          (wallet) => wallet.id == currentWalletId,
          orElse: () => wallets.first);
      await _setCurrentWallets(currentWallet, wallets);
      MarketService marketService = getIt<MarketService>();
      MarketData? marketData = await marketService.getMarketData();
      if (mounted) {
        setState(() {
          _marketData = marketData;
        });
      }
    }
  }

  Future<void> _setCurrentWallets(
      Wallet currentWallet, List<Wallet> wallets) async {
    try {
      ExtendedWalletData extendedWalletData = await getIt<GrpcService>()
          .getExtendedWalletData(currentWallet.address);
      if (mounted) {
        setState(() {
          _wallets = wallets;
          _currentWallet = currentWallet;
          _extendedWalletData = extendedWalletData;
        });
      }
    } on Exception catch (e, stacktrace) {
      var errorMessage = e.toString();
      log(errorMessage, stackTrace: stacktrace);
      if (mounted) {
        SnackBars.showSnackBar(context,
            "${AppLocalizations.of(context)!.errorDuringBalanceRetrieval} $errorMessage",
            duration: const Duration(seconds: 6, milliseconds: 1500));
      }
    }
  }

  void _refresh() async {
    WalletService walletService = getIt<WalletService>();
    List<Wallet> wallets = await walletService.getWallets();
    int? currentWalletId = await walletService.getCurrentWalletId();
    Wallet currentWallet = wallets.firstWhere(
        (wallet) => wallet.id == currentWalletId,
        orElse: () => wallets.first);
    await _setCurrentWallets(currentWallet, wallets);
    MarketService marketService = getIt<MarketService>();
    MarketData? marketData = await marketService.getMarketData();
    if (mounted) {
      setState(() {
        _marketData = marketData;
      });
    }
  }

  _onTapTransaction(int index) {
    if (_extendedWalletData != null) {
      TransactionData transactionData =
          _extendedWalletData!.transactions[index];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TransactionDetailPage(transactionData)),
        );
      }
    }
  }

  String _getConvertedBalance() {
    Decimal balance = (Decimal.fromInt(_extendedWalletData!.balance) /
            Decimal.fromInt(1000000000))
        .toDecimal();
    Decimal result = balance * _marketData!.price;
    return result.toStringAsFixed(2);
  }

  String _getMarketCap() {
    return "\$ ${(_marketData!.marketCap / Decimal.fromInt(1000000)).toDecimal().toStringAsFixed(2)}M USD";
  }
}
