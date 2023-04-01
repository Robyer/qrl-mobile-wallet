import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/sendtransaction/addressbook/addentry/add_entry_bloc.dart';

import '../../../testutil/mock_address_book_service.dart';

void main() {
  group('AddEntryBloc', () {
    late AddEntryBloc addEntryBloc;

    setUpAll(() async {
      AddressBookService addressBookService = MockAddressBookService();
      getIt.registerLazySingleton<AddressBookService>(() => addressBookService);
    });

    setUp(() {
      addEntryBloc = AddEntryBloc("address");
    });

    test("test initial state", () {
      expect(addEntryBloc.state, const AddEntryState(address: "address"));
    });

    blocTest(
      'emits [dirty] when ChangedEvent with change',
      build: () => addEntryBloc,
      act: (bloc) => addEntryBloc.add(const ChangedEvent("test-name")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const AddEntryState(
              status: AddEntryStatus.dirty,
              address: "address",
              name: "test-name"),
        ];
      },
    );

    blocTest(
      'emits [noChange] when ChangedEvent with no change',
      build: () => addEntryBloc,
      act: (bloc) => addEntryBloc.add(const ChangedEvent("")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const AddEntryState(
              status: AddEntryStatus.noChange, address: "address", name: ""),
        ];
      },
    );

    blocTest(
      'emits [entrySaved with change] when ConfirmEvent',
      build: () => addEntryBloc,
      seed: () => const AddEntryState(
          status: AddEntryStatus.dirty, address: "address", name: "test-name"),
      act: (bloc) => addEntryBloc.add(ConfirmEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          const AddEntryState(
              status: AddEntryStatus.entrySaved,
              address: "address",
              name: "test-name"),
        ];
      },
    );
  });
}
