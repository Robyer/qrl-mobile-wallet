part of 'backup_wallet_bloc.dart';

enum BackupWalletStatus { initial, loadingHexSeed, loadingMnemonic, ready }

class BackupWalletState extends Equatable {
  final BackupWalletStatus status;
  final Wallet wallet;
  final String? hexSeed;
  final String? mnemonic;

  const BackupWalletState(
      {this.status = BackupWalletStatus.initial,
      required this.wallet,
      this.hexSeed,
      this.mnemonic});

  BackupWalletState copyWith({
    BackupWalletStatus? status,
    Wallet? wallet,
    String? hexSeed,
    String? mnemonic,
  }) {
    return BackupWalletState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      hexSeed: hexSeed ?? this.hexSeed,
      mnemonic: mnemonic ?? this.mnemonic,
    );
  }

  @override
  List<Object> get props => [status, wallet];
}
