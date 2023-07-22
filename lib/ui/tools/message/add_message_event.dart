import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

abstract class AddMessageEvent extends AddTransactionEvent {}

class MessageChangedEvent extends AddMessageEvent {
  final String message;

  MessageChangedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
