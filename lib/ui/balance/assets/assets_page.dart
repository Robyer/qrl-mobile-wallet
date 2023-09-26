import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/balance/assets/assets_bloc.dart';
import 'package:mobile_wallet/ui/balance/transactions/transaction_data_page.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/util/string_util.dart';

class AssetsPage extends StatelessWidget {
  final Wallet _wallet;

  const AssetsPage(this._wallet, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AssetsBloc>(
        create: (_) => AssetsBloc(_wallet)..add(InitEvent()),
        child: _AssetsView(_wallet));
  }
}

class _AssetsView extends StatelessWidget {
  final Wallet _wallet;

  const _AssetsView(
    this._wallet,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-1.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: QrlTitleAppBar(
            titleText: AppLocalizations.of(context)!.assets,
          ),
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 4),
              child: Text(_wallet.name,
                  style: const TextStyle(
                    fontSize: 18,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              child: BlocBuilder<AssetsBloc, AssetsState>(
                buildWhen: (previous, current) =>
                    previous.extendedWalletData == null &&
                    current.extendedWalletData != null,
                builder: (context, state) {
                  return Text(
                      "${StringUtil.formatAmount(state.extendedWalletData?.balance ?? 0)} QRL",
                      style: const TextStyle(
                        fontSize: 16,
                        color: CustomColors.qrlLightBlueColor,
                      ));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: TabBar(tabs: [
                Tab(
                  text: AppLocalizations.of(context)!.tokens,
                ),
                Tab(
                  text: AppLocalizations.of(context)!.nfts,
                )
              ]),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTokenWidget(context),
                  _buildNftsWidget(context),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget _buildTokenWidget(BuildContext context) {
    return BlocBuilder<AssetsBloc, AssetsState>(
      buildWhen: (previous, current) =>
          previous.status != AssetsStatus.ready &&
          current.status == AssetsStatus.ready,
      builder: (context, state) {
        if (state.status != AssetsStatus.ready) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: CustomColors.qrlYellowColor,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(AppLocalizations.of(context)!.loadingTokens),
                ],
              ),
            ),
          );
        }
        List<TokenData> tokens = state.extendedWalletData?.tokens ?? [];
        if (tokens.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
            child: Text(AppLocalizations.of(context)!.noTokensFound),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: tokens.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                TokenData tokenData = tokens[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                  ),
                  child: Card(
                    elevation: 1,
                    color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TransactionDetailPage(
                                tokenData.tokenTransactionData!)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${tokenData.tokenTransactionData?.tokenName} (${tokenData.tokenTransactionData?.tokenSymbol})",
                                style: const TextStyle(
                                    color: CustomColors.qrlYellowColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                StringUtil.formatAmount(
                                  tokenData.balance,
                                  decimals: tokenData.tokenTransactionData
                                          ?.tokenDecimals ??
                                      0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  Widget _buildNftsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
      child: Text(AppLocalizations.of(context)!.noNftsFound),
    );
  }
}
