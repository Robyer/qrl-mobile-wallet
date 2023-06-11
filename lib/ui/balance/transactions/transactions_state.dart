part of 'transactions_bloc.dart';

enum TransactionsStatus { initial, loadingTransactions, noTransactions, ready }

class TransactionsState extends Equatable {
  final TransactionsStatus status;
  final Wallet wallet;
  final List<TransactionData> transactions;
  final bool hasReachedMax;

  const TransactionsState({
    this.status = TransactionsStatus.initial,
    required this.wallet,
    this.transactions = const [],
    this.hasReachedMax = false,
  });

  TransactionsState copyWith({
    TransactionsStatus? status,
    Wallet? wallet,
    List<TransactionData>? transactions,
    bool? hasReachedMax,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [status, wallet, transactions, hasReachedMax];
}
