part of 'add_transaction_bloc.dart';

enum AddTransactionStatus {
  initial,
  loadingWallets,
  noWallets,
  loadingExtendedWalletData,
  error,
  ready,
  verifying,
  verified,
  sending,
  sendError,
  send,
  tokenChanged,
}

abstract class AddTransactionState<T> extends Equatable {
  final TransactionType transactionType;
  final AddTransactionStatus status;
  final List<Wallet> wallets;
  final Wallet? currentWallet;
  final ExtendedWalletData? extendedWalletData;
  final String? errorMessage;
  final int fee;
  final bool reviewable;
  final String? transactionHash;
  final TokenData? selectedToken;

  const AddTransactionState({
    this.transactionType = TransactionType.transfer,
    this.status = AddTransactionStatus.initial,
    this.wallets = const [],
    this.currentWallet,
    this.extendedWalletData,
    this.errorMessage,
    this.fee = 1000000,
    this.reviewable = false,
    this.transactionHash,
    this.selectedToken,
  });

  T copyBase({
    TransactionType? transactionType,
    AddTransactionStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    String? errorMessage,
    int? fee,
    bool? reviewable,
    String? transactionHash,
    TokenData? selectedToken,
  });

  @override
  List<Object> get props => [
        transactionType,
        status,
        wallets,
        currentWallet ?? "",
        extendedWalletData ?? "",
        errorMessage ?? "",
        fee,
        reviewable,
        transactionHash ?? "",
        selectedToken ?? "",
      ];
}
