part of 'export_transactions_bloc.dart';

abstract class ExportTransactionsEvent extends Equatable {
  const ExportTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends ExportTransactionsEvent {}
