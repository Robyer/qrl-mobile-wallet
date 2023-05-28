import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:mobile_wallet/ui/addwallet/bloc/add_wallet_bloc.dart';

import '../../../testutil/mock_wallet_service.dart';

void main() {
  group('AddWalletBloc', () {
    late AddWalletBloc addWalletBlocCreate;
    late AddWalletBloc addWalletBlocHex;
    late AddWalletBloc addWalletBlocMnemonic;

    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      WalletService walletService = MockWalletService();
      getIt.registerLazySingleton<WalletService>(() => walletService);
    });

    setUp(() {
      addWalletBlocCreate = AddWalletBloc(AddWalletMode.create);
      addWalletBlocHex = AddWalletBloc(AddWalletMode.hexSeed);
      addWalletBlocMnemonic = AddWalletBloc(AddWalletMode.mnemonic);
    });

    test("test initial state", () {
      expect(addWalletBlocCreate.state, const AddWalletState(AddWalletMode.create));
      expect(addWalletBlocHex.state, const AddWalletState(AddWalletMode.hexSeed));
      expect(addWalletBlocMnemonic.state, const AddWalletState(AddWalletMode.mnemonic));
    });

    blocTest(
      'emits [valid] when NameChangedEvent with change',
      build: () => addWalletBlocCreate,
      act: (bloc) => addWalletBlocCreate.add(const NameChangedEvent("changed")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddWalletState>()
              .having((state) => state.status, "status", AddWalletStatus.valid)
              .having((state) => state.name, "name", "changed"),
        ];
      },
    );

    blocTest(
      'emits [initial] when NameChangedEvent without change',
      build: () => addWalletBlocHex,
      act: (bloc) => addWalletBlocHex.add(const NameChangedEvent("")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddWalletState>()
              .having(
                  (state) => state.status, "status", AddWalletStatus.initial)
              .having((state) => state.name, "name", null),
        ];
      },
    );

    blocTest(
      'emits [new hex seed] when HexSeedChangedEvent',
      build: () => addWalletBlocHex,
      act: (bloc) => addWalletBlocHex.add(const HexSeedChangedEvent("new hex")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddWalletState>()
              .having((state) => state.hexSeed, "hex seed", "new hex"),
        ];
      },
    );

    blocTest(
      'emits [new mnemonic] when MnemonicChangedEvent',
      build: () => addWalletBlocHex,
      act: (bloc) =>
          addWalletBlocHex.add(const MnemonicChangedEvent("new mnemonic")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddWalletState>()
              .having((state) => state.mnemonic, "mnemonic", "new mnemonic"),
        ];
      },
    );

    blocTest(
      'emits [new tree height] when TreeHeightChangedEvent',
      build: () => addWalletBlocCreate,
      act: (bloc) => addWalletBlocCreate.add(const TreeHeightChangedEvent(5)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddWalletState>()
              .having((state) => state.treeHeight, "tree height", 5),
        ];
      },
    );

    blocTest(
      'emits [new hash function] when HashFunctionChangedEvent',
      build: () => addWalletBlocCreate,
      act: (bloc) => addWalletBlocCreate.add(const HashFunctionChangedEvent(2)),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          isA<AddWalletState>()
              .having((state) => state.hashFunction, "hash function", 2),
        ];
      },
    );
  });
}
