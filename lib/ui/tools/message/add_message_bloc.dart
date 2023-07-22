import 'package:bloc/src/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_event.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_state.dart';

class AddMessageBloc extends AddTransactionBloc<AddMessageState> {
  final TransactionService _transactionService;

  AddMessageBloc()
      : _transactionService = getIt<TransactionService>(),
        super(const AddMessageState()) {
    on<MessageChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(message: event.message));
        checkReviewable(emit);
      },
      transformer: sequential(),
    );
  }

  @override
  Future<void> checkReviewable(Emitter<AddMessageState> emit) async {
    if (state.message.isNotEmpty &&
        state.fee < (state.extendedWalletData?.balance ?? 0)) {
      emit(state.copyWith(reviewable: true));
    } else {
      emit(state.copyWith(reviewable: false));
    }
  }

  @override
  Future<bool> verify(Emitter<AddMessageState> emit) async {
    return state.message.isNotEmpty &&
        state.fee < (state.extendedWalletData?.balance ?? 0);
  }

  @override
  Future<String> send(Emitter<AddMessageState> emit) async {
    return await _transactionService.sendMessageTransaction(
      state.currentWallet!.id,
      state.message,
      state.extendedWalletData!.otsIndex,
      state.fee,
    );
  }
}
