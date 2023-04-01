part of 'wallets_bloc.dart';

enum WalletsStatus {
  initial,
  loadingWallets,
  noWallets,
  ready,
  deletingWallet,
  walletDeleted,
  authenticating,
  authenticationFailed,
  authenticated
}

class WalletsState extends Equatable {
  final WalletsStatus status;
  final List<Wallet>? wallets;
  final Wallet? selectedWallet;

  const WalletsState(
      {this.status = WalletsStatus.initial, this.wallets, this.selectedWallet});

  WalletsState copyWith({
    WalletsStatus? status,
    List<Wallet>? wallets,
    Wallet? selectedWallet,
  }) {
    return WalletsState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      selectedWallet: selectedWallet ?? this.selectedWallet,
    );
  }

  @override
  List<Object> get props => [status];
}
