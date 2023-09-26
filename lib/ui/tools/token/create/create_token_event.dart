import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

abstract class CreateTokenEvent extends AddTransactionEvent {
  const CreateTokenEvent();
}

class OwnerAddressChangedEvent extends CreateTokenEvent {
  final String ownerAddress;

  const OwnerAddressChangedEvent(this.ownerAddress);

  @override
  List<Object?> get props => [ownerAddress];
}

class SaveOwnerAddressToAddressBookChangedEvent extends CreateTokenEvent {
  final bool saveOwnerToAddressBook;

  const SaveOwnerAddressToAddressBookChangedEvent(this.saveOwnerToAddressBook);

  @override
  List<Object?> get props => [saveOwnerToAddressBook];
}

class TokenNameChangedEvent extends CreateTokenEvent {
  final String tokenName;

  const TokenNameChangedEvent(this.tokenName);

  @override
  List<Object?> get props => [tokenName];
}

class TokenSymbolChangedEvent extends CreateTokenEvent {
  final String tokenSymbol;

  const TokenSymbolChangedEvent(this.tokenSymbol);

  @override
  List<Object?> get props => [tokenSymbol];
}

class TokenDecimalsChangedEvent extends CreateTokenEvent {
  final String tokenDecimals;

  const TokenDecimalsChangedEvent(this.tokenDecimals);

  @override
  List<Object?> get props => [tokenDecimals];
}

class InitialAddressChangedEvent extends CreateTokenEvent {
  final String address;
  final int initialHolder;

  const InitialAddressChangedEvent(this.address, this.initialHolder);

  @override
  List<Object?> get props => [address, initialHolder];
}

class SaveInitialHolderAddressToAddressBookChangedEvent
    extends CreateTokenEvent {
  final bool value;
  final int initialHolder;

  const SaveInitialHolderAddressToAddressBookChangedEvent(
      this.value, this.initialHolder);

  @override
  List<Object?> get props => [value, initialHolder];
}

class InitialBalanceChangedEvent extends CreateTokenEvent {
  final String initialBalanceString;
  final int initialHolder;

  const InitialBalanceChangedEvent(
      this.initialBalanceString, this.initialHolder);

  @override
  List<Object?> get props => [initialBalanceString, initialHolder];
}

class AddInitialHolderEvent extends CreateTokenEvent {}

class RemoveInitialHolderEvent extends CreateTokenEvent {
  final int initialHolder;

  const RemoveInitialHolderEvent(this.initialHolder);

  @override
  List<Object?> get props => [initialHolder];
}
