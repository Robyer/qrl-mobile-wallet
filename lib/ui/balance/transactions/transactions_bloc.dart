import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';

part 'transactions_event.dart';

part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  static const int batchCount = 10;
  final TransactionService _transactionService;

  TransactionsBloc(Wallet wallet)
      : _transactionService = getIt<TransactionService>(),
        super(TransactionsState(wallet: wallet)) {
    on<InitEvent>((event, emit) async {
      emit(state.copyWith(status: TransactionsStatus.loadingTransactions));
      List<TransactionData> transactions = await _transactionService
          .findTransactions(state.wallet.address, batchCount);
      if (transactions.isEmpty) {
        emit(state.copyWith(status: TransactionsStatus.noTransactions));
      } else {
        if (transactions.length < batchCount) {
          emit(state.copyWith(
              status: TransactionsStatus.ready,
              transactions: transactions,
              hasReachedMax: true));
        } else {
          emit(state.copyWith(
              status: TransactionsStatus.ready, transactions: transactions));
        }
      }
    });
    on<FindTransactionsEvent>((event, emit) async {
      if (!state.hasReachedMax) {
        List<TransactionData> currentTransactions = state.transactions;
        Set<String> hashes = <String>{};
        int skip = currentTransactions
            .where(
                (element) => !element.unconfirmed && hashes.add(element.hash))
            .length;
        List<TransactionData> newTransactions = await _transactionService
            .findTransactions(state.wallet.address, batchCount, skip: skip);
        if (newTransactions.length < batchCount) {
          emit(state.copyWith(
              transactions: List.of(state.transactions)
                ..addAll(newTransactions),
              hasReachedMax: true));
        } else {
          emit(state.copyWith(
              transactions: List.of(state.transactions)
                ..addAll(newTransactions)));
        }
      }
    }, transformer: droppable());
  }
}
