import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_bloc.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_event.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_state.dart';

import '../../../testutil/mock_address_book_service.dart';
import '../../../testutil/mock_settings_service.dart';
import '../../../testutil/mock_transaction_service.dart';
import '../../../testutil/mock_wallet_service.dart';

void main() {
  group('AddTransferBloc', () {
    late AddTransferBloc addTransferBloc;
    setUpAll(() async {
      SettingsService settingsService = MockSettingsService();
      TransactionService transactionsService = MockTransactionService();
      AddressBookService addressBookService = MockAddressBookService();
      WalletService walletService = MockWalletService();
      getIt
          .registerLazySingleton<TransactionService>(() => transactionsService);
      getIt.registerLazySingleton<SettingsService>(() => settingsService);
      getIt.registerLazySingleton<AddressBookService>(() => addressBookService);
      getIt.registerLazySingleton<WalletService>(() => walletService);
    });

    setUp(() {
      addTransferBloc = AddTransferBloc();
    });

    test("test initial state", () {
      expect(addTransferBloc.state,
          AddTransferState(transactionLines: [TransactionLine()]));
    });

    blocTest(
      'emits [initial and address] when AddressChangedEvent',
      build: () => addTransferBloc,
      act: (bloc) =>
          addTransferBloc.add(const AddressChangedEvent("new-address", 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransferState>()
              .having((state) => state.transferStatus, "status",
                  AddTransferStatus.initial)
              .having((state) => state.transactionLines[0].address, "address",
                  "new-address"),
        ];
      },
    );

    blocTest(
      'emits [saveToAddressBookUpdated and initial] when SaveToAddressBookChangedEvent',
      build: () => addTransferBloc,
      act: (bloc) =>
          addTransferBloc.add(const SaveToAddressBookChangedEvent(true, 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransferState>()
              .having((state) => state.transferStatus, "status",
                  AddTransferStatus.saveToAddressBookUpdated)
              .having((state) => state.transactionLines[0].saveToAddressBook,
                  "save to address book", true),
          isA<AddTransferState>().having((state) => state.transferStatus,
              "status", AddTransferStatus.initial),
        ];
      },
    );

    blocTest(
      'emits [transactionLineCountUpdated, initial] when AddTransactionLineEvent',
      build: () => addTransferBloc,
      act: (bloc) => addTransferBloc.add(AddTransactionLineEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransferState>()
              .having((state) => state.transferStatus, "status",
                  AddTransferStatus.transactionLineCountUpdated)
              .having((state) => state.transactionLines.length,
                  "transaction line count", 2),
          isA<AddTransferState>().having((state) => state.transferStatus,
              "status", AddTransferStatus.initial),
        ];
      },
    );

    blocTest(
      'emits [transactionLineCountUpdated, initial] when RemoveTransactionLineEvent',
      build: () => addTransferBloc,
      act: (bloc) => addTransferBloc.add(const RemoveTransactionLineEvent(1)),
      seed: () => AddTransferState(transactionLines: [
        TransactionLine(),
        TransactionLine(),
      ]),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransferState>()
              .having((state) => state.transferStatus, "status",
                  AddTransferStatus.transactionLineCountUpdated)
              .having((state) => state.transactionLines.length,
                  "transaction line count", 1),
          isA<AddTransferState>().having((state) => state.transferStatus,
              "status", AddTransferStatus.initial),
        ];
      },
    );

    blocTest(
      'emits [new message] when MessageChanged',
      build: () => addTransferBloc,
      act: (bloc) =>
          addTransferBloc.add(const MessageChangedEvent("new-message")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransferState>()
              .having((state) => state.message, "message", "new-message"),
        ];
      },
    );

    blocTest(
      'emits [new hasMessage] when HasMessageChangedEvent',
      build: () => addTransferBloc,
      act: (bloc) => addTransferBloc.add(const HasMessageChangedEvent(true)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddTransferState>()
              .having((state) => state.hasMessage, "has message", true),
        ];
      },
    );
  });
}
