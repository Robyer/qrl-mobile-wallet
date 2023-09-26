import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

enum CreateTokenStatus {
  initial,
  initialHolderCountUpdated,
  saveToAddressBookUpdated,
  addressInvalid,
  initialBalanceToLarge
}

class CreateTokenState extends AddTransactionState<CreateTokenState> {
  final CreateTokenStatus createTokenStatus;
  final String ownerAddress;
  final bool saveOwnerAddressToAddressBook;
  final String tokenName;
  final String tokenSymbol;
  final int tokenDecimals;
  final List<InitialHolder> initialHolders;

  const CreateTokenState({
    status = AddTransactionStatus.initial,
    wallets = const <Wallet>[],
    currentWallet,
    extendedWalletData,
    errorMessage,
    fee = 1000000,
    reviewable = false,
    transactionHash,
    this.createTokenStatus = CreateTokenStatus.initial,
    this.ownerAddress = "",
    this.saveOwnerAddressToAddressBook = false,
    this.tokenName = "",
    this.tokenSymbol = "",
    this.tokenDecimals = 10,
    this.initialHolders = const [],
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
        );

  @override
  CreateTokenState copyBase({
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
    );
  }

  CreateTokenState copyWith(
      {AddTransactionStatus? status,
      List<Wallet>? wallets,
      Wallet? currentWallet,
      ExtendedWalletData? extendedWalletData,
      String? errorMessage,
      int? fee,
      bool? reviewable,
      String? transactionHash,
      CreateTokenStatus? createTokenStatus,
      String? ownerAddress,
      bool? saveOwnerAddressToAddressBook,
      String? tokenName,
      String? tokenSymbol,
      int? tokenDecimals,
      List<InitialHolder>? initialHolders}) {
    return CreateTokenState(
      status: status ?? this.status,
      wallets: wallets ?? this.wallets,
      currentWallet: currentWallet ?? this.currentWallet,
      extendedWalletData: extendedWalletData ?? this.extendedWalletData,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
      reviewable: reviewable ?? this.reviewable,
      transactionHash: transactionHash ?? this.transactionHash,
      createTokenStatus: createTokenStatus ?? this.createTokenStatus,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      saveOwnerAddressToAddressBook:
          saveOwnerAddressToAddressBook ?? this.saveOwnerAddressToAddressBook,
      tokenName: tokenName ?? this.tokenName,
      tokenSymbol: tokenSymbol ?? this.tokenSymbol,
      tokenDecimals: tokenDecimals ?? this.tokenDecimals,
      initialHolders: initialHolders ?? this.initialHolders,
    );
  }

  @override
  List<Object> get props => [
        ...super.props,
        createTokenStatus,
        ownerAddress,
        saveOwnerAddressToAddressBook,
        tokenName,
        tokenSymbol,
        tokenDecimals,
        initialHolders,
      ];
}

class InitialHolder {
  String? address;
  int? initialBalance;
  bool saveToAddressBook = false;

  InitialHolder(
      {this.address, this.initialBalance, this.saveToAddressBook = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InitialHolder &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          initialBalance == other.initialBalance &&
          saveToAddressBook == other.saveToAddressBook;

  @override
  int get hashCode =>
      address.hashCode ^ initialBalance.hashCode ^ saveToAddressBook.hashCode;
}
