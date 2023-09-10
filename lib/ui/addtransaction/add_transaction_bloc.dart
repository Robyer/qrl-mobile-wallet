import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:wakelock/wakelock.dart';

part 'add_transaction_event.dart';

part 'add_transaction_state.dart';

abstract class AddTransactionBloc<T extends AddTransactionState>
    extends Bloc<AddTransactionEvent, T> {
  final WalletService _walletService;
  final SettingsService _settingsService;

  AddTransactionBloc(T addTransactionState)
      : _walletService = getIt<WalletService>(),
        _settingsService = getIt<SettingsService>(),
        super(addTransactionState) {
    on<InitEvent>((event, emit) async {
      int fee = await _settingsService.getFeeSetting();
      emit(state.copyBase(
          fee: fee, status: AddTransactionStatus.loadingWallets));
      List<Wallet> wallets = await _walletService.getWallets();
      if (wallets.isEmpty) {
        emit(state.copyBase(status: AddTransactionStatus.noWallets));
      } else {
        int? currentWalletId = await _walletService.getCurrentWalletId();
        Wallet currentWallet = wallets.firstWhere(
            (wallet) => wallet.id == currentWalletId,
            orElse: () => wallets.first);
        emit(state.copyBase(
            status: AddTransactionStatus.loadingExtendedWalletData,
            wallets: wallets,
            currentWallet: currentWallet));
        await _loadCurrentWalletData(currentWallet, emit);
      }
    });

    on<WalletChangedEvent>((event, emit) async {
      Wallet currentWallet = event.wallet;
      emit(state.copyBase(
          status: AddTransactionStatus.tokenChanged,
          selectedToken: null,
          transactionType: TransactionType.transfer));
      emit(state.copyBase(
          status: AddTransactionStatus.loadingExtendedWalletData,
          currentWallet: currentWallet));
      await _loadCurrentWalletData(currentWallet, emit);
      await resetData(emit);
      await checkReviewable(emit);
    });

    on<FeeChangedEvent>(
      (event, emit) async {
        emit(state.copyBase(fee: event.value));
        await checkReviewable(emit);
      },
    );

    on<ReviewEvent>(
      (event, emit) async {
        try {
          Wakelock.enable();
          emit(state.copyBase(status: AddTransactionStatus.verifying));
          if (await verify(emit)) {
            emit(state.copyBase(status: AddTransactionStatus.verified));
          }
        } on Exception catch (e, stacktrace) {
          var errorMessage = e.toString();
          log(errorMessage, stackTrace: stacktrace);
          emit(state.copyBase(
              status: AddTransactionStatus.error, errorMessage: errorMessage));
        } finally {
          Wakelock.disable();
        }
      },
      transformer: droppable(),
    );

    on<SendEvent>(
      (event, emit) async {
        try {
          Wakelock.enable();
          emit(state.copyBase(status: AddTransactionStatus.sending));
          String transactionHash = await send(emit);
          emit(state.copyBase(
              status: AddTransactionStatus.send,
              transactionHash: transactionHash));
        } on Exception catch (e, stacktrace) {
          var errorMessage = e.toString();
          log(errorMessage, stackTrace: stacktrace);
          emit(state.copyBase(
              status: AddTransactionStatus.sendError,
              errorMessage: errorMessage));
        } finally {
          Wakelock.disable();
        }
      },
      transformer: droppable(),
    );

    on<BackEvent>(
      (event, emit) async {
        emit(state.copyBase(status: AddTransactionStatus.ready));
      },
    );

    on<TokenChangedEvent>(
      (event, emit) async {
        AddTransactionStatus status = state.status;
        if (event.tokenData != null) {
          emit(state.copyBase(
              transactionType: TransactionType.transferToken,
              selectedToken: event.tokenData,
              status: AddTransactionStatus.tokenChanged));
        } else {
          emit(state.copyBase(
              transactionType: TransactionType.transfer,
              selectedToken: null,
              status: AddTransactionStatus.tokenChanged));
        }
        await resetData(emit);
        emit(state.copyBase(status: status));
      },
    );
  }

  Future<void> _loadCurrentWalletData(
      Wallet currentWallet, Emitter<T> emit) async {
    ExtendedWalletData? extendedWalletData;
    try {
      extendedWalletData = await _walletService.getExtendedWalletData(
          currentWallet.address,
          loadTokenTransaction: true);
    } on Exception catch (e, stacktrace) {
      var errorMessage = e.toString();
      log(errorMessage, stackTrace: stacktrace);
      emit(state.copyBase(
          status: AddTransactionStatus.error, errorMessage: errorMessage));
    }
    emit(state.copyBase(
        status: AddTransactionStatus.ready,
        extendedWalletData: extendedWalletData));
  }

  Future<void> resetData(Emitter<T> emit) async {}

  Future<void> checkReviewable(Emitter<T> emit);

  Future<bool> verify(Emitter<T> emit);

  Future<String> send(Emitter<T> emit);
}
