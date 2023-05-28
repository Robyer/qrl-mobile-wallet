import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/address_book_entry.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';

part 'change_address_name_event.dart';
part 'change_address_name_state.dart';

class ChangeAddressNameBloc
    extends Bloc<ChangeAddressNameEvent, ChangeAddressNameState> {
  final AddressBookService _addressBookService;

  ChangeAddressNameBloc(AddressBookEntry addressBookEntry)
      : _addressBookService = getIt<AddressBookService>(),
        super(ChangeAddressNameState(addressBookEntry: addressBookEntry)) {
    on<ChangedEvent>(
      (event, emit) async {
        String newName = event._value;
        if (state.addressBookEntry.name != newName) {
          emit(state.copyWith(
              status: ChangeAddressNameStatus.dirty, newName: newName));
        } else {
          emit(state.copyWith(
              status: ChangeAddressNameStatus.noChange, newName: newName));
        }
      },
      transformer: sequential(),
    );

    on<ConfirmEvent>((event, emit) async {
      if (state.status == ChangeAddressNameStatus.dirty) {
        AddressBookEntry addressBookEntry = state.addressBookEntry;
        addressBookEntry.name = state.newName ?? "";
        await _addressBookService.saveEntry(addressBookEntry);
        emit(state.copyWith(status: ChangeAddressNameStatus.nameSaved));
      }
    });
  }
}
