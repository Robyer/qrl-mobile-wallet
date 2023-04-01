part of 'backup_wallet_bloc.dart';

abstract class BackupWalletEvent extends Equatable {
  const BackupWalletEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends BackupWalletEvent {}
