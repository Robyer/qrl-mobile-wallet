part of 'add_wallet_bloc.dart';

enum AddWalletStatus { initial, valid, creating, created, error }

class AddWalletState extends Equatable {
  final AddWalletStatus status;
  final AddWalletMode addWalletMode;
  final String? name;
  final int treeHeight;
  final int hashFunction;
  final String? hexSeed;
  final String? mnemonic;
  final Wallet? createdWallet;
  final String? errorMessage;

  const AddWalletState(this.addWalletMode,
      {this.status = AddWalletStatus.initial,
      this.name,
      this.treeHeight = 10,
      this.hashFunction = 1,
      this.hexSeed,
      this.mnemonic,
      this.createdWallet,
      this.errorMessage});

  AddWalletState copyWith({
    AddWalletMode? addWalletMode,
    AddWalletStatus? status,
    String? name,
    int? treeHeight,
    int? hashFunction,
    String? hexSeed,
    String? mnemonic,
    Wallet? createdWallet,
    String? errorMessage,
  }) {
    return AddWalletState(
      addWalletMode ?? this.addWalletMode,
      status: status ?? this.status,
      name: name ?? this.name,
      treeHeight: treeHeight ?? this.treeHeight,
      hashFunction: hashFunction ?? this.hashFunction,
      hexSeed: hexSeed ?? this.hexSeed,
      mnemonic: mnemonic ?? this.mnemonic,
      createdWallet: createdWallet ?? this.createdWallet,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        addWalletMode,
        status,
        name ?? "",
        treeHeight,
        hashFunction,
        hexSeed != null ? hexSeed!.length : "",
        mnemonic != null ? mnemonic!.length : ""
      ];
}
