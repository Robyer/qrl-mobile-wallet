part of 'change_fee_bloc.dart';

abstract class ChangeFeeEvent extends Equatable {
  const ChangeFeeEvent();

  @override
  List<Object?> get props => [];
}

class ChangedEvent extends ChangeFeeEvent {
  final int _newFee;

  const ChangedEvent(this._newFee);

  @override
  List<Object?> get props => [_newFee];
}

class ConfirmEvent extends ChangeFeeEvent {}
