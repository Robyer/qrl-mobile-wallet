part of 'change_fee_bloc.dart';

enum ChangeFeeStatus { noChange, dirty, feeSaved }

class ChangeFeeState extends Equatable {
  final ChangeFeeStatus status;
  final int currentFee;
  final int? newFee;

  const ChangeFeeState(
      {this.status = ChangeFeeStatus.noChange,
      required this.currentFee,
      this.newFee});

  ChangeFeeState copyWith({
    ChangeFeeStatus? status,
    int? currentFee,
    int? newFee,
  }) {
    return ChangeFeeState(
      status: status ?? this.status,
      currentFee: currentFee ?? this.currentFee,
      newFee: newFee ?? this.newFee,
    );
  }

  @override
  List<Object> get props => [status, currentFee, newFee ?? 0];
}
