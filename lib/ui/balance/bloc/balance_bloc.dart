import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/market_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/market_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

part 'balance_event.dart';
part 'balance_state.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final WalletService _walletService;
  final MarketService _marketService;

  BalanceBloc()
      : _walletService = getIt<WalletService>(),
        _marketService = getIt<MarketService>(),
        super(const BalanceState()) {
    on<InitEvent>((event, emit) async {
      emit(state.copyWith(status: BalanceStatus.loadingWallets));
      List<Wallet> wallets = await _walletService.getWallets();
      if (wallets.isEmpty) {
        emit(state.copyWith(status: BalanceStatus.noWallets));
      } else {
        int? currentWalletId = await _walletService.getCurrentWalletId();
        Wallet currentWallet = wallets.firstWhere(
            (wallet) => wallet.id == currentWalletId,
            orElse: () => wallets.first);
        emit(state.copyWith(
            status: BalanceStatus.loadingExtendedWalletData,
            wallets: wallets,
            currentWallet: currentWallet));
        await _loadCurrentWalletData(currentWallet, emit);
      }
    });

    on<ExpandedChangedEvent>((event, emit) async {
      emit(state.copyWith(expanded: event.expanded));
    }, transformer: sequential());

    on<WalletChangedEvent>((event, emit) async {
      Wallet currentWallet = event.wallet;
      emit(state.copyWith(
          status: BalanceStatus.loadingExtendedWalletData,
          currentWallet: currentWallet));
      await _walletService.setCurrentWalletId(currentWallet.id);
      await _loadCurrentWalletData(currentWallet, emit);
    }, transformer: droppable());
  }

  Future<void> _loadCurrentWalletData(
      Wallet currentWallet, Emitter<BalanceState> emit) async {
    ExtendedWalletData? extendedWalletData;
    try {
      extendedWalletData =
          await _walletService.getExtendedWalletData(currentWallet.address);
    } on Exception catch (e, stacktrace) {
      var errorMessage = e.toString();
      log(errorMessage, stackTrace: stacktrace);
      emit(state.copyWith(
          status: BalanceStatus.error, errorMessage: errorMessage));
    }
    emit(state.copyWith(
        status: BalanceStatus.loadingMarketData,
        extendedWalletData: extendedWalletData));

    MarketData? marketData;
    try {
      marketData = await _marketService.getMarketData();
    } on Exception catch (e, stacktrace) {
      var errorMessage = e.toString();
      log(errorMessage, stackTrace: stacktrace);
    }
    emit(state.copyWith(status: BalanceStatus.ready, marketData: marketData));
  }
}
