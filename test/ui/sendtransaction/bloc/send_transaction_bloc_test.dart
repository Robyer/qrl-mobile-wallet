import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/sendtransaction/bloc/send_transaction_bloc.dart';

import '../../../testutil/mock_address_book_service.dart';
import '../../../testutil/mock_settings_service.dart';
import '../../../testutil/mock_wallet_service.dart';

void main() {
  group('SendTransactionBloc', () {
    late SendTransactionBloc sendTransactionBloc;
    Wallet wallet = Wallet(1, "name", "address", 1000);
    ExtendedWalletData extendedWalletData = ExtendedWalletData(5000000, 1);
    setUpAll(() async {
      SettingsService settingsService = MockSettingsService();
      WalletService walletService = MockWalletService();
      AddressBookService addressBookService = MockAddressBookService();
      getIt.registerLazySingleton<WalletService>(() => walletService);
      getIt.registerLazySingleton<SettingsService>(() => settingsService);
      getIt.registerLazySingleton<AddressBookService>(() => addressBookService);
    });

    setUp(() {
      sendTransactionBloc = SendTransactionBloc(wallet, extendedWalletData);
    });

    test("test initial state", () {
      expect(
          sendTransactionBloc.state,
          SendTransactionState(wallet, extendedWalletData,
              transactionLines: [TransactionLine()]));
    });

    blocTest(
      'emits [initial and fee] when InitEvent',
      build: () => sendTransactionBloc,
      act: (bloc) => sendTransactionBloc.add(InitEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.fee, "fee", 1000000),
        ];
      },
    );

    blocTest(
      'emits [initial and address] when AddressChangedEvent',
      build: () => sendTransactionBloc,
      act: (bloc) =>
          sendTransactionBloc.add(const AddressChangedEvent("new-address", 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.transactionLines[0].address, "address",
                  "new-address"),
        ];
      },
    );

    blocTest(
      'emits [reviewable and address] when AddressChangedEvent with amount',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.initial,
          transactionLines: [
            TransactionLine(address: "initial", amount: 1000000)
          ]),
      act: (bloc) =>
          sendTransactionBloc.add(const AddressChangedEvent("new-address", 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.reviewable)
              .having((state) => state.transactionLines[0].address, "address",
                  "new-address"),
        ];
      },
    );

    blocTest(
      'emits [saveToAddressBookUpdated, previous state] when SaveToAddressBookChangedEvent',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.reviewable,
          transactionLines: [
            TransactionLine(address: "initial", amount: 1000000)
          ]),
      act: (bloc) =>
          sendTransactionBloc.add(const SaveToAddressBookChangedEvent(true, 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.saveToAddressBookUpdated)
              .having((state) => state.transactionLines[0].saveToAddressBook,
                  "saveToAddressBook", true),
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.reviewable)
              .having((state) => state.transactionLines[0].saveToAddressBook,
                  "saveToAddressBook", true),
        ];
      },
    );

    blocTest(
      'emits [feeUpdated,notEnoughFunds and initial] when FeeChangedEvent',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.initial,
          transactionLines: [TransactionLine(amount: 4000000)]),
      act: (bloc) => sendTransactionBloc.add(const FeeChangedEvent(2500000)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.feeUpdated)
              .having((state) => state.fee, "fee", 2500000)
              .having((state) => state.transactionLines[0].amount, "amount",
                  4000000),
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.notEnoughFunds)
              .having((state) => state.fee, "fee", 2500000)
              .having((state) => state.transactionLines[0].amount, "amount",
                  4000000),
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.fee, "fee", 2500000)
              .having((state) => state.transactionLines[0].amount, "amount",
                  4000000),
        ];
      },
    );

    blocTest(
      'emits [initial and amount] when AmountChangedEvent',
      build: () => sendTransactionBloc,
      act: (bloc) =>
          sendTransactionBloc.add(const AmountChangedEvent("0.000000001", 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.transactionLines[0].amount, "amount", 1),
        ];
      },
    );

    blocTest(
      'emits [reviewable and amount] when AmountChangedEvent with address',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.initial,
          transactionLines: [TransactionLine(address: "test-address")]),
      act: (bloc) =>
          sendTransactionBloc.add(const AmountChangedEvent("0.000000001", 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.reviewable)
              .having((state) => state.transactionLines[0].address, "address",
                  "test-address")
              .having((state) => state.transactionLines[0].amount, "amount", 1),
        ];
      },
    );

    blocTest(
      'emits [transactionLineCountUpdated and initial with transaction lines 2] when AddTransactionLineEvent',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.reviewable,
          transactionLines: [
            TransactionLine(address: "test-address", amount: 10000)
          ]),
      act: (bloc) => sendTransactionBloc.add(AddTransactionLineEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.transactionLineCountUpdated)
              .having((state) => state.transactionLines.length,
                  "transaction lines", 2),
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.transactionLines.length,
                  "transaction lines", 2)
        ];
      },
    );

    blocTest(
      'emits [transactionLineCountUpdated and reviewable with transaction lines 1] when RemoveTransactionLineEvent',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.reviewable,
          transactionLines: [
            TransactionLine(address: "test-address", amount: 10000),
            TransactionLine(),
          ]),
      act: (bloc) =>
          sendTransactionBloc.add(const RemoveTransactionLineEvent(1)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.transactionLineCountUpdated)
              .having((state) => state.transactionLines.length,
                  "transaction lines", 1),
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.reviewable)
              .having((state) => state.transactionLines.length,
                  "transaction lines", 1)
        ];
      },
    );

    blocTest(
      'emits [hasMessageUpdated and initial] when HasMessageChangedEvent',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.initial),
      act: (bloc) =>
          sendTransactionBloc.add(const HasMessageChangedEvent(true)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.hasMessageUpdated)
              .having((state) => state.hasMessage, "hasMessage", true),
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.hasMessage, "hasMessage", true),
        ];
      },
    );

    blocTest(
      'emits [hasMessageUpdated and initial + clearing message] when HasMessageChangedEvent',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.initial,
          hasMessage: true,
          message: "test-message"),
      act: (bloc) =>
          sendTransactionBloc.add(const HasMessageChangedEvent(false)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.hasMessageUpdated)
              .having((state) => state.hasMessage, "hasMessage", false)
              .having((state) => state.message, "message", ""),
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.hasMessage, "hasMessage", false)
              .having((state) => state.message, "message", ""),
        ];
      },
    );

    blocTest(
      'emits [initial + message] when MessageChangedEvent',
      build: () => sendTransactionBloc,
      seed: () => SendTransactionState(wallet, extendedWalletData,
          status: SendTransactionStatus.initial,
          hasMessage: true,
          message: "test-message"),
      act: (bloc) =>
          sendTransactionBloc.add(const MessageChangedEvent("changed-message")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<SendTransactionState>()
              .having((state) => state.status, "status",
                  SendTransactionStatus.initial)
              .having((state) => state.hasMessage, "hasMessage", true)
              .having((state) => state.message, "message", "changed-message"),
        ];
      },
    );
  });
}
