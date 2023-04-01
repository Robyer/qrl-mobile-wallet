import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/authentication_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

part 'wallets_event.dart';

part 'wallets_state.dart';

class WalletsBloc extends Bloc<WalletsEvent, WalletsState> {
  final WalletService _walletService;

  WalletsBloc()
      : _walletService = getIt<WalletService>(),
        super(const WalletsState()) {
    on<InitEvent>((event, emit) async {
      emit(state.copyWith(status: WalletsStatus.loadingWallets));
      List<Wallet> wallets = await _walletService.getWallets();
      if (wallets.isEmpty) {
        emit(state.copyWith(status: WalletsStatus.noWallets));
      } else {
        emit(state.copyWith(status: WalletsStatus.ready, wallets: wallets));
      }
    });

    on<DeleteWalletEvent>((event, emit) async {
      emit(state.copyWith(status: WalletsStatus.deletingWallet));
      Wallet walletToDelete = event._wallet;
      await _walletService.deleteWallet(walletToDelete.id);
      emit(state.copyWith(status: WalletsStatus.walletDeleted));
      List<Wallet> wallets = state.wallets!;
      wallets.remove(walletToDelete);
      if (wallets.isEmpty) {
        emit(state.copyWith(status: WalletsStatus.noWallets));
      } else {
        emit(state.copyWith(status: WalletsStatus.ready, wallets: wallets));
      }
    });

    on<BackupWalletEvent>((event, emit) async {
      emit(state.copyWith(status: WalletsStatus.authenticating));
      if (await getIt<AuthenticationService>().authenticate()) {
        emit(state.copyWith(
            status: WalletsStatus.authenticated,
            selectedWallet: event._wallet));
      } else {
        emit(state.copyWith(status: WalletsStatus.authenticationFailed));
      }
    });

    on<WalletNameUpdatedEvent>((event, emit) async {
      emit(state.copyWith(status: WalletsStatus.loadingWallets));
      Wallet updatedWallet = event._wallet;
      List<Wallet> wallets = state.wallets!;
      wallets[wallets.indexWhere((element) => element.id == updatedWallet.id)] =
          updatedWallet;
      emit(state.copyWith(status: WalletsStatus.ready, wallets: wallets));
    });
  }
}
