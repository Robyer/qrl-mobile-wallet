part of 'send_transaction_bloc.dart';

abstract class SendTransactionEvent extends Equatable {
  const SendTransactionEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends SendTransactionEvent {}

class AddressChangedEvent extends SendTransactionEvent {
  final String address;
  final int transactionLine;

  const AddressChangedEvent(this.address, this.transactionLine);

  @override
  List<Object?> get props => [address, transactionLine];
}

class SaveToAddressBookChangedEvent extends SendTransactionEvent {
  final bool value;
  final int transactionLine;

  const SaveToAddressBookChangedEvent(this.value, this.transactionLine);

  @override
  List<Object?> get props => [value, transactionLine];
}

class AmountChangedEvent extends SendTransactionEvent {
  final String amountString;
  final int transactionLine;

  const AmountChangedEvent(this.amountString, this.transactionLine);

  @override
  List<Object?> get props => [amountString, transactionLine];
}

class FeeChangedEvent extends SendTransactionEvent {
  final int value;

  const FeeChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class AddTransactionLineEvent extends SendTransactionEvent {}

class RemoveTransactionLineEvent extends SendTransactionEvent {
  final int transactionLine;

  const RemoveTransactionLineEvent(this.transactionLine);

  @override
  List<Object?> get props => [transactionLine];
}

class ReviewEvent extends SendTransactionEvent {}

class SendEvent extends SendTransactionEvent {}

class HasMessageChangedEvent extends SendTransactionEvent {
  final bool hasMessage;

  const HasMessageChangedEvent(this.hasMessage);

  @override
  List<Object?> get props => [hasMessage];
}

class MessageChangedEvent extends SendTransactionEvent {
  final String message;

  const MessageChangedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
