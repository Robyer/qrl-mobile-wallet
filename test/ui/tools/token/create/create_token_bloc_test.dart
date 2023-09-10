import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_bloc.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_event.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_state.dart';

import '../../../../testutil/mock_address_book_service.dart';
import '../../../../testutil/mock_settings_service.dart';
import '../../../../testutil/mock_transaction_service.dart';
import '../../../../testutil/mock_wallet_service.dart';

void main() {
  group('CreateTokenBloc', () {
    late CreateTokenBloc createTokenBloc;
    setUpAll(() async {
      SettingsService settingsService = MockSettingsService();
      TransactionService transactionsService = MockTransactionService();
      WalletService walletService = MockWalletService();
      AddressBookService addressBookService = MockAddressBookService();
      getIt
          .registerLazySingleton<TransactionService>(() => transactionsService);
      getIt.registerLazySingleton<SettingsService>(() => settingsService);
      getIt.registerLazySingleton<WalletService>(() => walletService);
      getIt.registerLazySingleton<AddressBookService>(() => addressBookService);
    });

    setUp(() {
      createTokenBloc = CreateTokenBloc();
    });

    test("test initial state", () {
      expect(createTokenBloc.state,
          CreateTokenState(initialHolders: [InitialHolder()]));
    });

    blocTest(
      'emits [new owner address] when OwnerAddressChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) => createTokenBloc
          .add(const OwnerAddressChangedEvent("new-owner-address")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>().having((state) => state.ownerAddress,
              "ownerAddress", "new-owner-address"),
        ];
      },
    );

    blocTest(
      'emits [new saveOwnerAddressToAddressBook] when SaveOwnerAddressToAddressBookChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) => createTokenBloc
          .add(const SaveOwnerAddressToAddressBookChangedEvent(true)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>().having(
              (state) => state.saveOwnerAddressToAddressBook,
              "saveOwnerAddressToAddressBook",
              true),
        ];
      },
    );

    blocTest(
      'emits [new token name] when TokenNameChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) =>
          createTokenBloc.add(const TokenNameChangedEvent("new-token-name")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>().having(
              (state) => state.tokenName, "tokenName", "new-token-name"),
        ];
      },
    );

    blocTest(
      'emits [new token symbol] when TokenSymbolChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) => createTokenBloc.add(const TokenSymbolChangedEvent("NTS")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>()
              .having((state) => state.tokenSymbol, "tokenSymbol", "NTS"),
        ];
      },
    );

    blocTest(
      'emits [0 when invalid number] when TokenDecimalsChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) =>
          createTokenBloc.add(const TokenDecimalsChangedEvent("invalid-num")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>()
              .having((state) => state.tokenDecimals, "tokenDecimals", 0),
        ];
      },
    );

    blocTest(
      'emits [new token decimals] when TokenDecimalsChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) =>
          createTokenBloc.add(const TokenDecimalsChangedEvent("12345")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>()
              .having((state) => state.tokenDecimals, "tokenDecimals", 12345),
        ];
      },
    );

    blocTest(
      'emits [initial and address] when InitialAddressChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) => createTokenBloc
          .add(const InitialAddressChangedEvent("new-address", 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>()
              .having((state) => state.createTokenStatus, "status",
                  CreateTokenStatus.initial)
              .having((state) => state.initialHolders[0].address, "address",
                  "new-address"),
        ];
      },
    );

    blocTest(
      'emits [saveToAddressBookUpdated and initial] when SaveInitialHolderAddressToAddressBookChangedEvent',
      build: () => createTokenBloc,
      act: (bloc) => createTokenBloc.add(
          const SaveInitialHolderAddressToAddressBookChangedEvent(true, 0)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>()
              .having((state) => state.createTokenStatus, "status",
                  CreateTokenStatus.saveToAddressBookUpdated)
              .having((state) => state.initialHolders[0].saveToAddressBook,
                  "save to address book", true),
          isA<CreateTokenState>().having((state) => state.createTokenStatus,
              "status", CreateTokenStatus.initial),
        ];
      },
    );

    blocTest(
      'emits [initialHolderCountUpdated, initial] when AddInitialHolderEvent',
      build: () => createTokenBloc,
      act: (bloc) => createTokenBloc.add(AddInitialHolderEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>()
              .having((state) => state.createTokenStatus, "status",
                  CreateTokenStatus.initialHolderCountUpdated)
              .having((state) => state.initialHolders.length,
                  "initial holder count", 2),
          isA<CreateTokenState>().having((state) => state.createTokenStatus,
              "status", CreateTokenStatus.initial),
        ];
      },
    );

    blocTest(
      'emits [initialHolderCountUpdated, initial] when RemoveInitialHolderEvent',
      build: () => createTokenBloc,
      act: (bloc) => createTokenBloc.add(const RemoveInitialHolderEvent(1)),
      seed: () => CreateTokenState(initialHolders: [
        InitialHolder(),
        InitialHolder(),
      ]),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<CreateTokenState>()
              .having((state) => state.createTokenStatus, "status",
                  CreateTokenStatus.initialHolderCountUpdated)
              .having((state) => state.initialHolders.length,
                  "initial holder count", 1),
          isA<CreateTokenState>().having((state) => state.createTokenStatus,
              "status", CreateTokenStatus.initial),
        ];
      },
    );
  });
}
