part of 'change_wallet_name_bloc.dart';

abstract class ChangeWalletNameEvent extends Equatable {
  const ChangeWalletNameEvent();

  @override
  List<Object?> get props => [];
}

class ChangedEvent extends ChangeWalletNameEvent {
  final String _value;

  const ChangedEvent(this._value);

  @override
  List<Object?> get props => [_value];
}

class ConfirmEvent extends ChangeWalletNameEvent {}
