part of 'add_entry_bloc.dart';

enum AddEntryStatus { noChange, dirty, entrySaved }

class AddEntryState extends Equatable {
  final AddEntryStatus status;
  final String address;
  final String name;

  const AddEntryState(
      {this.status = AddEntryStatus.noChange,
      required this.address,
      this.name = ""});

  AddEntryState copyWith({
    AddEntryStatus? status,
    String? address,
    String? name,
  }) {
    return AddEntryState(
      status: status ?? this.status,
      address: address ?? this.address,
      name: name ?? this.name,
    );
  }

  @override
  List<Object> get props => [
        status,
        address,
        name,
      ];
}
