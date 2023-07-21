import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/notarization_message.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';

part 'verify_notarization_event.dart';
part 'verify_notarization_state.dart';

class VerifyNotarizationBloc
    extends Bloc<VerifyNotarizationEvent, VerifyNotarizationState> {
  final TransactionService _transactionService;

  VerifyNotarizationBloc()
      : _transactionService = getIt<TransactionService>(),
        super(const VerifyNotarizationState()) {
    on<TransactionHashChangedEvent>((event, emit) async {
      emit(state.copyWith(transactionHash: event.transactionHash));
    });

    on<SearchEvent>((event, emit) async {
      if (state.transactionHash != null) {
        emit(state.copyWith(status: VerifyNotarizationStatus.searching));
        NotarizationMessage? notarizationMessage;
        try {
          notarizationMessage = await _transactionService
              .findNotarization(state.transactionHash!);
        } catch (e) {
          notarizationMessage = null;
        }
        if (notarizationMessage != null) {
          emit(state.copyWith(
              notarizationMessage: notarizationMessage,
              status: VerifyNotarizationStatus.notarizationFound));
        } else {
          emit(state.copyWith(
              status: VerifyNotarizationStatus.notarizationNotFound));
        }
      } else {
        emit(state.copyWith(status: VerifyNotarizationStatus.initial));
      }
    });

    on<VerifyEvent>((event, emit) async {
      emit(state.copyWith(status: VerifyNotarizationStatus.verifying));
      PlatformFile file = event.filePickerResult.files.first;
      if (file.bytes != null) {
        String hash = sha256.convert(file.bytes!.toList()).toString();
        if (hash == state.notarizationMessage!.fileHash) {
          emit(state.copyWith(
              status: VerifyNotarizationStatus.verified,
              lastFileName: file.name));
          return;
        }
      }
      emit(state.copyWith(
          status: VerifyNotarizationStatus.verifyFailed,
          lastFileName: file.name));
    });
  }
}
