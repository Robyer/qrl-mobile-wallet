part of 'add_wallet_bloc.dart';

abstract class AddWalletEvent extends Equatable {
  const AddWalletEvent();

  @override
  List<Object?> get props => [];
}

class NameChangedEvent extends AddWalletEvent {
  final String value;

  const NameChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class TreeHeightChangedEvent extends AddWalletEvent {
  final int value;

  const TreeHeightChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class HashFunctionChangedEvent extends AddWalletEvent {
  final int value;

  const HashFunctionChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class HexSeedChangedEvent extends AddWalletEvent {
  final String value;

  const HexSeedChangedEvent(this.value);

  @override
  List<Object?> get props => [value.length];
}

class MnemonicChangedEvent extends AddWalletEvent {
  final String value;

  const MnemonicChangedEvent(this.value);

  @override
  List<Object?> get props => [value.length];
}

class ConfirmEvent extends AddWalletEvent {}

class WalletModeChangedEvent extends AddWalletEvent {
  final AddWalletMode value;

  const WalletModeChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}
