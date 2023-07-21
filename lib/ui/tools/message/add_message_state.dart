import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

class AddMessageState extends AddTransactionState<AddMessageState> {
  final String message;

  const AddMessageState({
    status = AddTransactionStatus.initial,
    wallets = const <Wallet>[],
    currentWallet,
    extendedWalletData,
    errorMessage,
    fee = 1000000,
    reviewable = false,
    transactionHash,
    this.message = "",
  }) : super(
          TransactionType.message,
          status: status,
          wallets: wallets,
          currentWallet: currentWallet,
          extendedWalletData: extendedWalletData,
          errorMessage: errorMessage,
          fee: fee,
          reviewable: reviewable,
          transactionHash: transactionHash,
        );

  @override
  AddMessageState copyBase({
    TransactionType? transactionType,
    AddTransactionStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    String? errorMessage,
    int? fee,
    bool? reviewable,
    String? transactionHash,
  }) {
    return copyWith(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
      reviewable: reviewable ?? this.reviewable,
      transactionHash: transactionHash ?? this.transactionHash,
    );
  }

  AddMessageState copyWith({
    AddTransactionStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    String? errorMessage,
    int? fee,
    bool? reviewable,
    String? transactionHash,
    String? message,
  }) {
    return AddMessageState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
      reviewable: reviewable ?? this.reviewable,
      transactionHash: transactionHash ?? this.transactionHash,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [
        ...super.props,
        message,
      ];
}
