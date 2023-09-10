part of 'assets_bloc.dart';

enum AssetsStatus { initial, ready }

class AssetsState extends Equatable {
  final AssetsStatus status;
  final Wallet wallet;
  final ExtendedWalletData? extendedWalletData;

  const AssetsState({
    this.status = AssetsStatus.initial,
    required this.wallet,
    this.extendedWalletData,
  });

  AssetsState copyWith({
    AssetsStatus? status,
    Wallet? wallet,
    ExtendedWalletData? extendedWalletData,
  }) {
    return AssetsState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
    );
  }

  @override
  List<Object> get props => [
        status,
        wallet,
        extendedWalletData ?? "",
      ];
}
