import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

part 'change_wallet_name_event.dart';

part 'change_wallet_name_state.dart';

class ChangeWalletNameBloc
    extends Bloc<ChangeWalletNameEvent, ChangeWalletNameState> {
  final WalletService _walletService;

  ChangeWalletNameBloc(Wallet wallet)
      : _walletService = getIt<WalletService>(),
        super(ChangeWalletNameState(wallet: wallet)) {
    on<ChangedEvent>(
      (event, emit) async {
        String newName = event._value;
        if (state.wallet.name != newName) {
          emit(state.copyWith(
              status: ChangeWalletNameStatus.dirty, newName: newName));
        } else {
          emit(state.copyWith(
              status: ChangeWalletNameStatus.noChange, newName: newName));
        }
      },
      transformer: sequential(),
    );

    on<ConfirmEvent>((event, emit) async {
      if (state.status == ChangeWalletNameStatus.dirty) {
        await _walletService.updateWalletName(state.wallet.id, state.newName!);
      }
      Wallet wallet = state.wallet;
      wallet.name = state.newName!;
      emit(state.copyWith(
          status: ChangeWalletNameStatus.nameSaved, wallet: wallet));
    });
  }
}
