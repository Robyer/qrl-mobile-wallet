import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

abstract class AddTransferEvent extends AddTransactionEvent {
  const AddTransferEvent();
}

class AddressChangedEvent extends AddTransferEvent {
  final String address;
  final int transactionLine;

  const AddressChangedEvent(this.address, this.transactionLine);

  @override
  List<Object?> get props => [address, transactionLine];
}

class SaveToAddressBookChangedEvent extends AddTransferEvent {
  final bool value;
  final int transactionLine;

  const SaveToAddressBookChangedEvent(this.value, this.transactionLine);

  @override
  List<Object?> get props => [value, transactionLine];
}

class AmountChangedEvent extends AddTransferEvent {
  final String amountString;
  final int transactionLine;

  const AmountChangedEvent(this.amountString, this.transactionLine);

  @override
  List<Object?> get props => [amountString, transactionLine];
}

class AddTransactionLineEvent extends AddTransferEvent {}

class RemoveTransactionLineEvent extends AddTransferEvent {
  final int transactionLine;

  const RemoveTransactionLineEvent(this.transactionLine);

  @override
  List<Object?> get props => [transactionLine];
}

class HasMessageChangedEvent extends AddTransferEvent {
  final bool hasMessage;

  const HasMessageChangedEvent(this.hasMessage);

  @override
  List<Object?> get props => [hasMessage];
}

class MessageChangedEvent extends AddTransferEvent {
  final String message;

  const MessageChangedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
