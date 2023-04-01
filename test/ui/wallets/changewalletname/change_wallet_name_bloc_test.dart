import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/wallets/changewalletname/change_wallet_name_bloc.dart';

import '../../../testutil/mock_wallet_service.dart';

void main() {
  group('ChangeWalletNameBloc', () {
    late ChangeWalletNameBloc changeWalletNameBloc;
    final Wallet wallet = Wallet(1, "name-1", "address-1", 1);

    setUpAll(() async {
      WalletService walletService = MockWalletService();
      getIt.registerLazySingleton<WalletService>(() => walletService);
    });

    setUp(() {
      changeWalletNameBloc = ChangeWalletNameBloc(wallet);
    });

    test("test initial state", () {
      expect(changeWalletNameBloc.state, ChangeWalletNameState(wallet: wallet));
    });

    blocTest(
      'emits [dirty] when ChangedEvent with change',
      build: () => changeWalletNameBloc,
      act: (bloc) => changeWalletNameBloc.add(const ChangedEvent("changed")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          ChangeWalletNameState(
              status: ChangeWalletNameStatus.dirty,
              wallet: wallet,
              newName: "changed"),
        ];
      },
    );

    blocTest(
      'emits [noChange] when ChangedEvent with no change',
      build: () => changeWalletNameBloc,
      act: (bloc) => changeWalletNameBloc.add(const ChangedEvent("name-1")),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          ChangeWalletNameState(
              status: ChangeWalletNameStatus.noChange,
              wallet: wallet,
              newName: "name-1"),
        ];
      },
    );

    blocTest(
      'emits [wallet with change] when ConfirmEvent',
      build: () => changeWalletNameBloc,
      seed: () => ChangeWalletNameState(
          status: ChangeWalletNameStatus.dirty,
          wallet: wallet,
          newName: "changed"),
      act: (bloc) => changeWalletNameBloc.add(ConfirmEvent()),
      wait: const Duration(seconds: 1),
      expect: () {
        return [
          ChangeWalletNameState(
              status: ChangeWalletNameStatus.nameSaved,
              wallet: wallet,
              newName: "changed"),
        ];
      },
    );
  });
}
