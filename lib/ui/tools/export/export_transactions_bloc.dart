import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

part 'export_transactions_event.dart';

part 'export_transactions_state.dart';

class ExportTransactionsBloc
    extends Bloc<ExportTransactionsEvent, ExportTransactionsState> {
  final WalletService _walletService;

  ExportTransactionsBloc()
      : _walletService = getIt<WalletService>(),
        super(ExportTransactionsState()) {
    on<InitEvent>((event, emit) async {
      emit(state.copyWith(
        status: ExportTransactionsStatus.ready,
      ));
    });
  }
}
