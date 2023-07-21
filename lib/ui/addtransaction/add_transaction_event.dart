part of 'add_transaction_bloc.dart';

abstract class AddTransactionEvent extends Equatable {
  const AddTransactionEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends AddTransactionEvent {}

class WalletChangedEvent extends AddTransactionEvent {
  final Wallet wallet;

  const WalletChangedEvent(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class FeeChangedEvent extends AddTransactionEvent {
  final int value;

  const FeeChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class ReviewEvent extends AddTransactionEvent {}

class SendEvent extends AddTransactionEvent {}

class BackEvent extends AddTransactionEvent {}