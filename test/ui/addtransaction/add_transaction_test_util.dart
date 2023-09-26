import 'package:bloc/src/bloc.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

class AddTransactionTestBloc
    extends AddTransactionBloc<AddTransactionTestState> {
  AddTransactionTestBloc() : super(const AddTransactionTestState());

  @override
  Future<void> checkReviewable(Emitter emit) {
    return Future(() => {});
  }

  @override
  Future<String> send(Emitter emit) {
    return Future(() => "hash");
  }

  @override
  Future<bool> verify(Emitter emit) {
    return Future(() => false);
  }
}

class AddTransactionTestState
    extends AddTransactionState<AddTransactionTestState> {
  const AddTransactionTestState({
    status = AddTransactionStatus.initial,
    wallets = const <Wallet>[],
    currentWallet,
    extendedWalletData,
    errorMessage,
    fee = 1000000,
    reviewable = false,
    transactionHash,
    selectedToken,
  }) : super(
          transactionType: TransactionType.message,
          status: status,
          wallets: wallets,
          currentWallet: currentWallet,
          extendedWalletData: extendedWalletData,
          errorMessage: errorMessage,
          fee: fee,
          reviewable: reviewable,
          transactionHash: transactionHash,
          selectedToken: selectedToken,
        );

  @override
  AddTransactionTestState copyBase({
    TransactionType? transactionType,
    AddTransactionStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    String? errorMessage,
    int? fee,
    bool? reviewable,
    String? transactionHash,
    TokenData? selectedToken,
  }) {
    return copyWith(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
      reviewable: reviewable ?? this.reviewable,
      transactionHash: transactionHash ?? this.transactionHash,
      selectedToken: selectedToken ?? this.selectedToken,
    );
  }

  AddTransactionTestState copyWith({
    AddTransactionStatus? status,
    List<Wallet>? wallets,
    Wallet? currentWallet,
    ExtendedWalletData? extendedWalletData,
    String? errorMessage,
    int? fee,
    bool? reviewable,
    String? transactionHash,
    TokenData? selectedToken,
  }) {
    return AddTransactionTestState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
      reviewable: reviewable ?? this.reviewable,
      transactionHash: transactionHash ?? this.transactionHash,
      selectedToken: selectedToken ?? this.selectedToken,
    );
  }

  @override
  List<Object> get props => [
        ...super.props,
      ];
}
