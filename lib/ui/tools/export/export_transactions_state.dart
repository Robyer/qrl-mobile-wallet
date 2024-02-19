part of 'export_transactions_bloc.dart';

enum ExportTransactionsStatus { initial, ready }

class ExportTransactionsState extends Equatable {
  final ExportTransactionsStatus status;

  const ExportTransactionsState({
    this.status = ExportTransactionsStatus.initial,
  });

  ExportTransactionsState copyWith({
    ExportTransactionsStatus? status,
  }) {
    return ExportTransactionsState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [
        status,
      ];
}
