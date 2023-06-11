import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:wakelock/wakelock.dart';

part 'send_transaction_event.dart';
part 'send_transaction_state.dart';

class SendTransactionBloc
    extends Bloc<SendTransactionEvent, SendTransactionState> {
  final SettingsService _settingsService;
  final TransactionService _transactionService;
  final AddressBookService _addressBookService;

  SendTransactionBloc(Wallet wallet, ExtendedWalletData extendedWalletData)
      : _settingsService = getIt<SettingsService>(),
        _transactionService = getIt<TransactionService>(),
        _addressBookService = getIt<AddressBookService>(),
        super(SendTransactionState(wallet, extendedWalletData,
            transactionLines: [TransactionLine()])) {
    on<InitEvent>((event, emit) async {
      await _handleInitEvent(emit);
    });
    on<AddressChangedEvent>(
      (event, emit) async {
        _handleAddressChangedEvent(event, emit);
      },
      transformer: sequential(),
    );
    on<SaveToAddressBookChangedEvent>(
      (event, emit) async {
        _handleSaveToAddressBookChangedEvent(emit, event);
      },
      transformer: sequential(),
    );
    on<AmountChangedEvent>(
      (event, emit) async {
        _handleAmountChangedEvent(event, emit);
      },
      transformer: sequential(),
    );
    on<FeeChangedEvent>(
      (event, emit) async {
        await _handleFeeChangedEvent(event, emit);
      },
    );
    on<AddTransactionLineEvent>((event, emit) async {
      _handleAddTransactionLineEvent(event, emit);
    });
    on<RemoveTransactionLineEvent>((event, emit) async {
      _handleRemoveTransactionLineEvent(event, emit);
    });
    on<ReviewEvent>(
      (event, emit) async {
        await _handleReviewEvent(emit);
      },
      transformer: droppable(),
    );
    on<SendEvent>(
      (event, emit) async {
        await _handleSendEvent(emit);
      },
      transformer: droppable(),
    );
    on<HasMessageChangedEvent>((event, emit) async {
      _handleHasMessageChangedEvent(event, emit);
    });
    on<MessageChangedEvent>(
      (event, emit) async {
        _handleMessageChangedEvent(event, emit);
      },
      transformer: sequential(),
    );
  }

  Future<void> _handleInitEvent(Emitter<SendTransactionState> emit) async {
    int fee = await _settingsService.getFeeSetting();
    emit(state.copyWith(status: SendTransactionStatus.initial, fee: fee));
  }

  void _handleAddressChangedEvent(
      AddressChangedEvent event, Emitter<SendTransactionState> emit) {
    int transactionLineNumber = event.transactionLine;
    List<TransactionLine> transactionLines = state.transactionLines;
    if (transactionLines.length >= transactionLineNumber) {
      TransactionLine transactionLine = transactionLines[transactionLineNumber];
      String newAddress = event.address;
      transactionLine.address = newAddress;
      _checkIsValid(emit, transactionLines, state.fee);
    }
  }

  void _handleSaveToAddressBookChangedEvent(
      Emitter<SendTransactionState> emit, SaveToAddressBookChangedEvent event) {
    int transactionLineNumber = event.transactionLine;
    List<TransactionLine> transactionLines = state.transactionLines;
    if (transactionLines.length >= transactionLineNumber) {
      TransactionLine transactionLine = transactionLines[transactionLineNumber];
      transactionLine.saveToAddressBook = event.value;
      emit(state.copyWith(
          status: SendTransactionStatus.saveToAddressBookUpdated,
          transactionLines: transactionLines));
      _checkIsValid(emit, transactionLines, state.fee);
    }
  }

  Future<void> _handleFeeChangedEvent(
      FeeChangedEvent event, Emitter<SendTransactionState> emit) async {
    int newFee = event.value;
    emit(state.copyWith(status: SendTransactionStatus.feeUpdated, fee: newFee));
    await _settingsService.updateFeeSetting(newFee);
    _checkIsValid(emit, state.transactionLines, newFee);
  }

  void _handleAmountChangedEvent(
      AmountChangedEvent event, Emitter<SendTransactionState> emit) {
    int transactionLineNumber = event.transactionLine;
    int amount;

    String value = event.amountString;
    if (value.isEmpty) {
      amount = 0;
    } else {
      amount = (Decimal.parse(value) * Decimal.fromInt(1000000000))
          .toBigInt()
          .toInt();
    }

    List<TransactionLine> transactionLines = state.transactionLines;
    if (transactionLines.length >= transactionLineNumber) {
      TransactionLine transactionLine = transactionLines[transactionLineNumber];
      transactionLine.amount = amount;
      _checkIsValid(emit, transactionLines, state.fee);
    }
  }

  void _handleAddTransactionLineEvent(
      AddTransactionLineEvent event, Emitter<SendTransactionState> emit) {
    List<TransactionLine> transactionLineList = state.transactionLines;
    transactionLineList.add(TransactionLine());
    emit(state.copyWith(
        status: SendTransactionStatus.transactionLineCountUpdated,
        transactionLines: transactionLineList));
    emit(state.copyWith(status: SendTransactionStatus.initial));
  }

  void _handleRemoveTransactionLineEvent(
      RemoveTransactionLineEvent event, Emitter<SendTransactionState> emit) {
    List<TransactionLine> transactionLineList = state.transactionLines;
    transactionLineList.removeAt(event.transactionLine);
    emit(state.copyWith(
        status: SendTransactionStatus.transactionLineCountUpdated,
        transactionLines: transactionLineList));
    _checkIsValid(emit, transactionLineList, state.fee);
  }

  Future<void> _handleReviewEvent(Emitter<SendTransactionState> emit) async {
    try {
      Wakelock.enable();
      emit(state.copyWith(status: SendTransactionStatus.verifying));
      bool allAddressesValid = true;
      List<TransactionLine> transactionLines = state.transactionLines;
      for (TransactionLine transactionLine in transactionLines) {
        if (await getIt<WalletService>()
            .isAddressValid(transactionLine.address ?? "")) {
          //TODO check this when address valid/added and remove/disable checkbox when address already present
          bool saveToAddressBook = transactionLine.saveToAddressBook;
          if (saveToAddressBook &&
              await _addressBookService.hasAddress(transactionLine.address!)) {
            transactionLine.saveToAddressBook = false;
          }
        } else {
          allAddressesValid = false;
        }
      }
      if (allAddressesValid) {
        emit(state.copyWith(
            status: SendTransactionStatus.verified,
            transactionLines: transactionLines));
      } else {
        emit(state.copyWith(status: SendTransactionStatus.addressInvalid));
      }
    } on Exception catch (e, stacktrace) {
      var errorMessage = e.toString();
      log(errorMessage, stackTrace: stacktrace);
      emit(state.copyWith(
          status: SendTransactionStatus.error, errorMessage: errorMessage));
    } finally {
      Wakelock.disable();
    }
  }

  Future<void> _handleSendEvent(Emitter<SendTransactionState> emit) async {
    try {
      Wakelock.enable();
      emit(state.copyWith(status: SendTransactionStatus.sending));
      await _transactionService.sendTransaction(
          state.wallet.id,
          state.transactionLines.map((line) => line.amount!).toList(),
          state.transactionLines.map((line) => line.address!).toList(),
          state.extendedWalletData.otsIndex,
          state.fee,
          state.message);
      emit(state.copyWith(status: SendTransactionStatus.send));
    } on Exception catch (e, stacktrace) {
      var errorMessage = e.toString();
      log(errorMessage, stackTrace: stacktrace);
      emit(state.copyWith(
          status: SendTransactionStatus.sendError, errorMessage: errorMessage));
    } finally {
      Wakelock.disable();
    }
  }

  void _checkIsValid(Emitter<SendTransactionState> emit,
      List<TransactionLine> transactionLines, int fee) {
    if (_isValid(emit, state.extendedWalletData, transactionLines, fee)) {
      emit(state.copyWith(
          status: SendTransactionStatus.reviewable,
          transactionLines: transactionLines));
    } else {
      emit(state.copyWith(
          status: SendTransactionStatus.initial,
          transactionLines: transactionLines));
    }
  }

  bool _isValid(
      Emitter<SendTransactionState> emit,
      ExtendedWalletData extendedWalletData,
      List<TransactionLine> transactionLines,
      int fee) {
    List<int> filteredLines = transactionLines
        .where((transactionLine) => transactionLine.amount != null)
        .map((transactionLine) => transactionLine.amount!)
        .toList();
    int totalAmount =
        filteredLines.isNotEmpty ? filteredLines.reduce((a, b) => a + b) : 0;
    if (totalAmount + fee > extendedWalletData.balance) {
      if (totalAmount > 0 && extendedWalletData.balance > 0) {
        emit(state.copyWith(status: SendTransactionStatus.notEnoughFunds));
      }
      return false;
    }

    return transactionLines.every((transactionLine) {
      if ((transactionLine.address != null &&
              transactionLine.address!.isNotEmpty) &&
          (transactionLine.amount != null && transactionLine.amount! > 0)) {
        return true;
      }
      return false;
    });
  }

  void _handleHasMessageChangedEvent(
      HasMessageChangedEvent event, Emitter<SendTransactionState> emit) {
    SendTransactionStatus currentStatus = state.status;
    if (event.hasMessage) {
      emit(state.copyWith(
          status: SendTransactionStatus.hasMessageUpdated,
          hasMessage: event.hasMessage));
    } else {
      emit(state.copyWith(
          status: SendTransactionStatus.hasMessageUpdated,
          hasMessage: event.hasMessage,
          message: ""));
    }
    emit(state.copyWith(status: currentStatus));
  }

  void _handleMessageChangedEvent(
      MessageChangedEvent event, Emitter<SendTransactionState> emit) {
    emit(state.copyWith(status: state.status, message: event.message));
  }
}
