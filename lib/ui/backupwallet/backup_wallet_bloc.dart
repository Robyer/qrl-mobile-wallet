import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

part 'backup_wallet_event.dart';

part 'backup_wallet_state.dart';

class BackupWalletBloc extends Bloc<BackupWalletEvent, BackupWalletState> {
  final WalletService _walletService;

  BackupWalletBloc(Wallet wallet)
      : _walletService = getIt<WalletService>(),
        super(BackupWalletState(wallet: wallet)) {
    on<InitEvent>((event, emit) async {
      emit(state.copyWith(status: BackupWalletStatus.loadingHexSeed));
      String hexSeed = await _walletService.getHexSeed(wallet.id);
      emit(state.copyWith(
          status: BackupWalletStatus.loadingMnemonic, hexSeed: hexSeed));
      String mnemonic = await _walletService.getMnemonic(hexSeed);
      emit(
          state.copyWith(status: BackupWalletStatus.ready, mnemonic: mnemonic));
    });
  }
}
