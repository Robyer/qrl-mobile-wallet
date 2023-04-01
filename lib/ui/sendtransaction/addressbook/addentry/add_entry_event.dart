part of 'add_entry_bloc.dart';

abstract class AddEntryEvent extends Equatable {
  const AddEntryEvent();

  @override
  List<Object?> get props => [];
}

class ChangedEvent extends AddEntryEvent {
  final String _value;

  const ChangedEvent(this._value);

  @override
  List<Object?> get props => [_value];
}

class ConfirmEvent extends AddEntryEvent {}
