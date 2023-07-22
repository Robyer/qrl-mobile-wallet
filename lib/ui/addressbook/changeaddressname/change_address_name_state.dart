part of 'change_address_name_bloc.dart';

enum ChangeAddressNameStatus { noChange, dirty, nameSaved }

class ChangeAddressNameState extends Equatable {
  final ChangeAddressNameStatus status;
  final AddressBookEntry addressBookEntry;
  final String? newName;

  const ChangeAddressNameState(
      {this.status = ChangeAddressNameStatus.noChange,
      required this.addressBookEntry,
      this.newName});

  ChangeAddressNameState copyWith({
    ChangeAddressNameStatus? status,
    AddressBookEntry? addressBookEntry,
    String? newName,
  }) {
    return ChangeAddressNameState(
      status: status ?? this.status,
      addressBookEntry: addressBookEntry ?? this.addressBookEntry,
      newName: newName ?? this.newName,
    );
  }

  @override
  List<Object> get props => [status, addressBookEntry, newName ?? ""];
}
