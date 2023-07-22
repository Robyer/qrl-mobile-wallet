import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

enum AddTransferStatus {
  initial,
  transactionLineCountUpdated,
  saveToAddressBookUpdated,
  notEnoughFunds,
  addressInvalid,
}

class AddTransferState extends AddTransactionState<AddTransferState> {
  final AddTransferStatus transferStatus;
  final List<TransactionLine> transactionLines;
  final String? message;
  final bool hasMessage;

  const AddTransferState({
    status = AddTransactionStatus.initial,
    wallets = const <Wallet>[],
    currentWallet,
    extendedWalletData,
    errorMessage,
    fee = 1000000,
    reviewable = false,
    transactionHash,
    this.transferStatus = AddTransferStatus.initial,
    this.transactionLines = const [],
    this.message,
    this.hasMessage = false,
  }) : super(
          TransactionType.transfer,
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
  AddTransferState copyBase({
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

  AddTransferState copyWith({
    AddTransactionStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    String? errorMessage,
    int? fee,
    bool? reviewable,
    String? transactionHash,
    AddTransferStatus? transferStatus,
    List<TransactionLine>? transactionLines,
    String? message,
    bool? hasMessage,
  }) {
    return AddTransferState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
      reviewable: reviewable ?? this.reviewable,
      transactionHash: transactionHash ?? this.transactionHash,
      transferStatus: transferStatus ?? this.transferStatus,
      transactionLines: transactionLines ?? this.transactionLines,
      message: message ?? this.message,
      hasMessage: hasMessage ?? this.hasMessage,
    );
  }

  @override
  List<Object> get props => [
        ...super.props,
        transferStatus,
        transactionLines,
        message ?? "",
        hasMessage,
      ];
}

class TransactionLine {
  String? address;
  int? amount;
  bool saveToAddressBook = false;

  TransactionLine({this.address, this.amount, this.saveToAddressBook = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionLine &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          amount == other.amount &&
          saveToAddressBook == other.saveToAddressBook;

  @override
  int get hashCode =>
      address.hashCode ^ amount.hashCode ^ saveToAddressBook.hashCode;
}
