part of 'export_transactions_bloc.dart';

abstract class ExportTransactionsEvent extends Equatable {
  const ExportTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends ExportTransactionsEvent {}

class WalletChangedEvent extends ExportTransactionsEvent {
  final Wallet wallet;

  const WalletChangedEvent(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class FromDateChangedEvent extends ExportTransactionsEvent {
  final DateTime value;

  const FromDateChangedEvent(this.value);

  @override
  List<Object?> get props => [value ?? ""];
}

class ToDateChangedEvent extends ExportTransactionsEvent {
  final DateTime value;

  const ToDateChangedEvent(this.value);

  @override
  List<Object?> get props => [value ?? ""];
}

class ExportEvent extends ExportTransactionsEvent {}
