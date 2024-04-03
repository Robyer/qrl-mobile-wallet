part of 'export_transactions_bloc.dart';

enum ExportTransactionsStatus {
  initial,
  loadingWallets,
  exportable,
  exporting,
  exportComplete,
  error
}

class ExportTransactionsState extends Equatable {
  final ExportTransactionsStatus status;
  final List<Wallet> wallets;
  final Wallet? currentWallet;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? fileLocation;
  final String? errorMessage;

  const ExportTransactionsState({
    this.status = ExportTransactionsStatus.initial,
    this.wallets = const [],
    this.currentWallet,
    this.fromDate,
    this.toDate,
    this.fileLocation,
    this.errorMessage,
  });

  ExportTransactionsState copyWith({
    ExportTransactionsStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    DateTime? fromDate,
    DateTime? toDate,
    String? fileLocation,
    String? errorMessage,
  }) {
    return ExportTransactionsState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      fileLocation: fileLocation ?? this.fileLocation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        status,
        wallets,
        currentWallet ?? "",
        fromDate ?? "",
        toDate ?? "",
        fileLocation ?? "",
        errorMessage ?? "",
      ];
}
