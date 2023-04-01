part of 'change_wallet_name_bloc.dart';

enum ChangeWalletNameStatus { noChange, dirty, nameSaved }

class ChangeWalletNameState extends Equatable {
  final ChangeWalletNameStatus status;
  final Wallet wallet;
  final String? newName;

  const ChangeWalletNameState(
      {this.status = ChangeWalletNameStatus.noChange,
      required this.wallet,
      this.newName});

  ChangeWalletNameState copyWith({
    ChangeWalletNameStatus? status,
    Wallet? wallet,
    String? newName,
  }) {
    return ChangeWalletNameState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      newName: newName ?? this.newName,
    );
  }

  @override
  List<Object> get props => [status, wallet, newName ?? ""];
}
