part of 'balance_bloc.dart';

abstract class BalanceEvent extends Equatable {
  const BalanceEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends BalanceEvent {}

class ExpandedChangedEvent extends BalanceEvent {
  final bool expanded;

  const ExpandedChangedEvent(this.expanded);

  @override
  List<Object?> get props => [expanded];
}

class WalletChangedEvent extends BalanceEvent {
  final Wallet wallet;

  const WalletChangedEvent(this.wallet);

  @override
  List<Object?> get props => [wallet];
}
