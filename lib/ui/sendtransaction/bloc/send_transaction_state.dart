part of 'send_transaction_bloc.dart';

enum SendTransactionStatus {
  initializing,
  initial,
  feeUpdated,
  amountUpdated,
  saveToAddressBookUpdated,
  notEnoughFunds,
  reviewable,
  transactionLineCountUpdated,
  verifying,
  addressInvalid,
  error,
  verified,
  sending,
  sendError,
  send,
}

class SendTransactionState extends Equatable {
  final Wallet wallet;
  final ExtendedWalletData extendedWalletData;
  final SendTransactionStatus status;
  final List<TransactionLine> transactionLines;
  final int fee;
  final String? errorMessage;

  const SendTransactionState(this.wallet, this.extendedWalletData,
      {this.status = SendTransactionStatus.initializing,
      this.transactionLines = const [],
      this.fee = 1000000,
      this.errorMessage});

  SendTransactionState copyWith({
    SendTransactionStatus? status,
    List<TransactionLine>? transactionLines,
    int? fee,
    String? errorMessage,
  }) {
    return SendTransactionState(
      wallet,
      extendedWalletData,
      status: status ?? this.status,
      transactionLines: transactionLines ?? this.transactionLines,
      fee: fee ?? this.fee,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        status,
        transactionLines,
        fee,
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
