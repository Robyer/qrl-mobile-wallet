import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/address_book_entry.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/addressbook/changeaddressname/change_address_name_bloc.dart';

import '../../../testutil/mock_address_book_service.dart';

void main() {
  group('ChangeAddressNameBloc', () {
    late ChangeAddressNameBloc changeAddressNameBloc;
    final AddressBookEntry addressBookEntry =
        AddressBookEntry("name", "address");

    setUpAll(() async {
      AddressBookService addressBookService = MockAddressBookService();
      getIt.registerLazySingleton<AddressBookService>(() => addressBookService);
    });

    setUp(() {
      changeAddressNameBloc = ChangeAddressNameBloc(addressBookEntry);
    });

    test("test initial state", () {
      expect(changeAddressNameBloc.state,
          ChangeAddressNameState(addressBookEntry: addressBookEntry));
    });

    blocTest(
      'emits [dirty] when ChangedEvent with change',
      build: () => changeAddressNameBloc,
      act: (bloc) => changeAddressNameBloc.add(const ChangedEvent("changed")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          ChangeAddressNameState(
              status: ChangeAddressNameStatus.dirty,
              addressBookEntry: addressBookEntry,
              newName: "changed"),
        ];
      },
    );

    blocTest(
      'emits [noChange] when ChangedEvent with no change',
      build: () => changeAddressNameBloc,
      act: (bloc) => changeAddressNameBloc.add(const ChangedEvent("name")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          ChangeAddressNameState(
              status: ChangeAddressNameStatus.noChange,
              addressBookEntry: addressBookEntry,
              newName: "name"),
        ];
      },
    );

    blocTest(
      'emits [addressbookentry with change] when ConfirmEvent',
      build: () => changeAddressNameBloc,
      seed: () => ChangeAddressNameState(
          status: ChangeAddressNameStatus.dirty,
          addressBookEntry: addressBookEntry,
          newName: "changed"),
      act: (bloc) => changeAddressNameBloc.add(ConfirmEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          ChangeAddressNameState(
              status: ChangeAddressNameStatus.nameSaved,
              addressBookEntry: addressBookEntry,
              newName: "changed"),
        ];
      },
    );
  });
}
