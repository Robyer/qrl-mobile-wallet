part of 'wallets_bloc.dart';

abstract class WalletsEvent extends Equatable {
  const WalletsEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends WalletsEvent {}

class DeleteWalletEvent extends WalletsEvent {
  final Wallet _wallet;

  const DeleteWalletEvent(this._wallet);

  @override
  List<Object?> get props => [_wallet];
}

class BackupWalletEvent extends WalletsEvent {
  final Wallet _wallet;

  const BackupWalletEvent(this._wallet);

  @override
  List<Object?> get props => [_wallet];
}

class WalletNameUpdatedEvent extends WalletsEvent {
  final Wallet _wallet;

  const WalletNameUpdatedEvent(this._wallet);

  @override
  List<Object?> get props => [_wallet];
}
