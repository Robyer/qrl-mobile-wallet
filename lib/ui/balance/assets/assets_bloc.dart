import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

part 'assets_event.dart';
part 'assets_state.dart';

class AssetsBloc extends Bloc<AssetsEvent, AssetsState> {
  final TransactionService _transactionService;
  final WalletService _walletService;

  AssetsBloc(Wallet wallet)
      : _transactionService = getIt<TransactionService>(),
        _walletService = getIt<WalletService>(),
        super(AssetsState(wallet: wallet)) {
    on<InitEvent>((event, emit) async {
      ExtendedWalletData extendedWalletData =
          await _walletService.getExtendedWalletData(state.wallet.address,
              loadTokenTransaction: true);
      emit(state.copyWith(
          status: AssetsStatus.ready, extendedWalletData: extendedWalletData));
    });
  }
}
