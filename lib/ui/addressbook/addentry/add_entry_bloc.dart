import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';

part 'add_entry_event.dart';
part 'add_entry_state.dart';

class AddEntryBloc extends Bloc<AddEntryEvent, AddEntryState> {
  final AddressBookService _addressBookService;

  AddEntryBloc(String address)
      : _addressBookService = getIt<AddressBookService>(),
        super(AddEntryState(address: address)) {
    on<ChangedEvent>(
      (event, emit) async {
        String newName = event._value;
        if (state.name != newName) {
          emit(state.copyWith(status: AddEntryStatus.dirty, name: newName));
        } else {
          emit(state.copyWith(status: AddEntryStatus.noChange, name: newName));
        }
      },
      transformer: sequential(),
    );

    on<ConfirmEvent>((event, emit) async {
      if (state.status == AddEntryStatus.dirty) {
        await _addressBookService.addToAddressBook(state.name, state.address);
      }
      emit(state.copyWith(status: AddEntryStatus.entrySaved));
    });
  }
}
