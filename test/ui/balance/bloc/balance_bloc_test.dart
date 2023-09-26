import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/market_data.dart';
import 'package:mobile_wallet/service/market_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/balance/bloc/balance_bloc.dart';

import '../../../testutil/mock_market_service.dart';
import '../../../testutil/mock_wallet_service.dart';

void main() {
  group('BalanceBloc', () {
    late BalanceBloc balanceBloc;

    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      WalletService walletService = MockWalletService();
      MarketService marketService = MockMarketService();
      getIt.registerLazySingleton<WalletService>(() => walletService);
      getIt.registerLazySingleton<MarketService>(() => marketService);
    });

    setUp(() {
      balanceBloc = BalanceBloc();
    });

    test("test initial state", () {
      expect(balanceBloc.state, const BalanceState());
    });

    blocTest(
      'emits [loadingWallets, loadingExtendedWalletData, loadingMarketData, ready] when InitEvent',
      build: () => balanceBloc,
      act: (bloc) => balanceBloc.add(InitEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<BalanceState>().having(
              (state) => state.status, "status", BalanceStatus.loadingWallets),
          isA<BalanceState>()
              .having((state) => state.status, "status",
                  BalanceStatus.loadingExtendedWalletData)
              .having((state) => state.wallets.length, "wallets size", 4)
              .having(
                  (state) => state.currentWallet!.id, "current wallet id", 2),
          isA<BalanceState>()
              .having((state) => state.status, "status",
                  BalanceStatus.loadingMarketData)
              .having((state) => state.extendedWalletData!.balance, "balance",
                  1337),
          isA<BalanceState>()
              .having((state) => state.status, "status", BalanceStatus.ready)
              .having((state) => state.marketData!.price, "price", Decimal.ten),
        ];
      },
    );

    blocTest(
      'emits [new expanded value] when ExpandedChangedEvent',
      build: () => balanceBloc,
      act: (bloc) => balanceBloc.add(const ExpandedChangedEvent(true)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<BalanceState>()
              .having((state) => state.expanded, "expanded", true),
        ];
      },
    );

    blocTest(
      'emits [loadingExtendedWalletData, loadingMarketData, ready] when WalletChangedEvent',
      build: () => balanceBloc,
      seed: () => BalanceState(
          status: BalanceStatus.ready,
          wallets: MockWalletService.wallets,
          currentWallet: MockWalletService.wallets[1],
          extendedWalletData: ExtendedWalletData(1337, 25, []),
          marketData: MarketData(
              Decimal.ten, Decimal.fromInt(1000000000), Decimal.one)),
      act: (bloc) =>
          balanceBloc.add(WalletChangedEvent(MockWalletService.wallets[3])),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<BalanceState>()
              .having((state) => state.status, "status",
                  BalanceStatus.loadingExtendedWalletData)
              .having((state) => state.wallets.length, "wallets size", 4)
              .having(
                  (state) => state.currentWallet!.id, "current wallet id", 4),
          isA<BalanceState>()
              .having((state) => state.status, "status",
                  BalanceStatus.loadingMarketData)
              .having((state) => state.extendedWalletData!.balance, "balance",
                  1337),
          isA<BalanceState>()
              .having((state) => state.status, "status", BalanceStatus.ready)
              .having((state) => state.marketData!.price, "price", Decimal.ten),
        ];
      },
    );
  });
}
