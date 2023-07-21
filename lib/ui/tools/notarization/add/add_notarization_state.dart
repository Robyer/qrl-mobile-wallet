import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

class AddNotarizationState extends AddTransactionState<AddNotarizationState> {
  final String message;
  final String? fileHash;
  final String? fileName;
  final bool hasMessage;
  final String hashFunction;

  const AddNotarizationState({
    status = AddTransactionStatus.initial,
    wallets = const <Wallet>[],
    currentWallet,
    extendedWalletData,
    errorMessage,
    fee = 1000000,
    reviewable = false,
    transactionHash,
    this.message = "",
    this.fileHash,
    this.fileName,
    this.hasMessage = false,
    this.hashFunction = "2",
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
  AddNotarizationState copyBase({
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

  AddNotarizationState copyWith({
    AddTransactionStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    String? errorMessage,
    int? fee,
    bool? reviewable,
    String? transactionHash,
    String? message,
    String? fileHash,
    String? fileName,
    bool? hasMessage,
    String? hashFunction,
  }) {
    return AddNotarizationState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
      reviewable: reviewable ?? this.reviewable,
      transactionHash: transactionHash ?? this.transactionHash,
      message: message ?? this.message,
      fileHash: fileHash ?? this.fileHash,
      fileName: fileName ?? this.fileName,
      hasMessage: hasMessage ?? this.hasMessage,
      hashFunction: hashFunction ?? this.hashFunction,
    );
  }

  @override
  List<Object> get props => [
        ...super.props,
        message,
        fileHash ?? "",
        fileName ?? "",
        hasMessage,
        hashFunction,
      ];
}
