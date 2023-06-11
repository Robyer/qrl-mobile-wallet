part of 'balance_bloc.dart';

enum BalanceStatus {
  initial,
  loadingWallets,
  noWallets,
  loadingExtendedWalletData,
  loadingMarketData,
  error,
  ready,
}

class BalanceState extends Equatable {
  final BalanceStatus status;
  final List<Wallet> wallets;
  final Wallet? currentWallet;
  final ExtendedWalletData? extendedWalletData;
  final MarketData? marketData;
  final String? errorMessage;
  final bool expanded;

  const BalanceState({
    this.status = BalanceStatus.initial,
    this.wallets = const [],
    this.currentWallet,
    this.extendedWalletData,
    this.marketData,
    this.errorMessage,
    this.expanded = false,
  });

  BalanceState copyWith({
    BalanceStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    MarketData? marketData,
    String? errorMessage,
    bool? expanded,
  }) {
    return BalanceState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      marketData: marketData ?? this.marketData,
      errorMessage: errorMessage ?? this.errorMessage,
      expanded: expanded ?? this.expanded,
    );
  }

  @override
  List<Object> get props => [
        status,
        wallets,
        currentWallet ?? "",
        extendedWalletData ?? "",
        marketData ?? "",
        errorMessage ?? "",
        expanded,
      ];
}
