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
  hasMessageUpdated,
}

class SendTransactionState extends Equatable {
  final Wallet wallet;
  final ExtendedWalletData extendedWalletData;
  final SendTransactionStatus status;
  final List<TransactionLine> transactionLines;
  final int fee;
  final String? message;
  final bool hasMessage;
  final String? errorMessage;

  const SendTransactionState(this.wallet, this.extendedWalletData,
      {this.status = SendTransactionStatus.initializing,
      this.transactionLines = const [],
      this.fee = 1000000,
      this.message,
      this.hasMessage = false,
      this.errorMessage});

  SendTransactionState copyWith({
    SendTransactionStatus? status,
    List<TransactionLine>? transactionLines,
    int? fee,
    String? message,
    bool? hasMessage,
    String? errorMessage,
  }) {
    return SendTransactionState(
      wallet,
      extendedWalletData,
      status: status ?? this.status,
      transactionLines: transactionLines ?? this.transactionLines,
      fee: fee ?? this.fee,
      message: message ?? this.message,
      hasMessage: hasMessage ?? this.hasMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        status,
        transactionLines,
        fee,
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
