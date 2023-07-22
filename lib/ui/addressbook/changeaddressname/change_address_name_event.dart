part of 'change_address_name_bloc.dart';

abstract class ChangeAddressNameEvent extends Equatable {
  const ChangeAddressNameEvent();

  @override
  List<Object?> get props => [];
}

class ChangedEvent extends ChangeAddressNameEvent {
  final String _value;

  const ChangedEvent(this._value);

  @override
  List<Object?> get props => [_value];
}

class ConfirmEvent extends ChangeAddressNameEvent {}
