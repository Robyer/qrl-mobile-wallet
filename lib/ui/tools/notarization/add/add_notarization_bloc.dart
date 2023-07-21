import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/src/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_event.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_state.dart';
import 'package:mobile_wallet/util/string_util.dart';

class AddNotarizationBloc extends AddTransactionBloc<AddNotarizationState> {
  final TransactionService _transactionService;

  AddNotarizationBloc()
      : _transactionService = getIt<TransactionService>(),
        super(const AddNotarizationState()) {
    on<UploadFileEvent>((event, emit) async {
      PlatformFile file = event.filePickerResult.files.first;
      if (file.bytes != null) {
        String hash = sha256.convert(file.bytes!.toList()).toString();
        emit(state.copyWith(fileHash: hash, fileName: file.name));
      } else {
        emit(state.copyWith(fileHash: null, fileName: null));
      }
      await checkReviewable(emit);
    });

    on<HasMessageChangedEvent>((event, emit) async {
      emit(state.copyWith(hasMessage: event.hasMessage));
    });

    on<MessageChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(message: event.message));
      },
      transformer: sequential(),
    );
  }

  @override
  Future<void> checkReviewable(Emitter<AddNotarizationState> emit) async {
    if (state.fileHash != null &&
        state.fee < (state.extendedWalletData?.balance ?? 0)) {
      emit(state.copyWith(reviewable: true));
    } else {
      emit(state.copyWith(reviewable: false));
    }
  }

  @override
  Future<bool> verify(Emitter<AddNotarizationState> emit) async {
    return state.fileHash != null &&
        state.fee < (state.extendedWalletData?.balance ?? 0);
  }

  @override
  Future<String> send(Emitter<AddNotarizationState> emit) async {
    String messageData = state.message.isNotEmpty
        ? StringUtil.fromBytes(Uint8List.fromList(utf8.encode(state.message)))
        : "";
    String message = "afafa2${state.fileHash}$messageData";
    return await _transactionService.sendMessageTransaction(
      state.currentWallet!.id,
      message,
      state.extendedWalletData!.otsIndex,
      state.fee,
      messageType: MessageType.hex,
    );
  }
}
