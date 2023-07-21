import 'package:bloc/src/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:decimal/decimal.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_event.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_state.dart';

class AddTransferBloc extends AddTransactionBloc<AddTransferState> {
  final TransactionService _transactionService;
  final AddressBookService _addressBookService;

  AddTransferBloc()
      : _transactionService = getIt<TransactionService>(),
        _addressBookService = getIt<AddressBookService>(),
        super(AddTransferState(transactionLines: [TransactionLine()])) {
    on<AddressChangedEvent>(
      (event, emit) async {
        int transactionLineNumber = event.transactionLine;
        List<TransactionLine> transactionLines = state.transactionLines;
        if (transactionLines.length >= transactionLineNumber) {
          TransactionLine transactionLine =
              transactionLines[transactionLineNumber];
          String newAddress = event.address;
          transactionLine.address = newAddress;
          emit(state.copyWith(transactionLines: transactionLines));
          await checkReviewable(emit);
        }
      },
      transformer: sequential(),
    );

    on<SaveToAddressBookChangedEvent>(
      (event, emit) async {
        int transactionLineNumber = event.transactionLine;
        List<TransactionLine> transactionLines = state.transactionLines;
        if (transactionLines.length >= transactionLineNumber) {
          TransactionLine transactionLine =
              transactionLines[transactionLineNumber];
          transactionLine.saveToAddressBook = event.value;
          AddTransferStatus currentTransferStatus = state.transferStatus;
          emit(state.copyWith(
              transferStatus: AddTransferStatus.saveToAddressBookUpdated,
              transactionLines: transactionLines));
          emit(state.copyWith(transferStatus: currentTransferStatus));
          await checkReviewable(emit);
        }
      },
      transformer: sequential(),
    );

    on<AmountChangedEvent>(
      (event, emit) async {
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
          TransactionLine transactionLine =
              transactionLines[transactionLineNumber];
          transactionLine.amount = amount;
          await checkReviewable(emit);
        }
      },
      transformer: sequential(),
    );

    on<AddTransactionLineEvent>((event, emit) async {
      List<TransactionLine> transactionLineList = state.transactionLines;
      transactionLineList.add(TransactionLine());
      AddTransferStatus currentTransferStatus = state.transferStatus;
      emit(state.copyWith(
          reviewable: false,
          transactionLines: transactionLineList,
          transferStatus: AddTransferStatus.transactionLineCountUpdated));
      emit(state.copyWith(transferStatus: currentTransferStatus));
    });

    on<RemoveTransactionLineEvent>((event, emit) async {
      List<TransactionLine> transactionLineList = state.transactionLines;
      transactionLineList.removeAt(event.transactionLine);
      AddTransferStatus currentTransferStatus = state.transferStatus;
      emit(state.copyWith(
          transactionLines: transactionLineList,
          transferStatus: AddTransferStatus.transactionLineCountUpdated));
      emit(state.copyWith(transferStatus: currentTransferStatus));
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
  Future<void> checkReviewable(Emitter<AddTransferState> emit) async {
    if (_isValid(emit)) {
      emit(state.copyWith(
        reviewable: true,
      ));
    } else {
      emit(state.copyWith(
        reviewable: false,
      ));
    }
  }

  bool _isValid(Emitter<AddTransferState> emit) {
    List<int> filteredLines = state.transactionLines
        .where((transactionLine) => transactionLine.amount != null)
        .map((transactionLine) => transactionLine.amount!)
        .toList();
    int totalAmount =
        filteredLines.isNotEmpty ? filteredLines.reduce((a, b) => a + b) : 0;
    if (totalAmount + state.fee > (state.extendedWalletData?.balance ?? 0)) {
      if (totalAmount > 0 && (state.extendedWalletData?.balance ?? 0) > 0) {
        emit(state.copyWith(
          transferStatus: AddTransferStatus.notEnoughFunds,
        ));
        emit(state.copyWith(
          status: AddTransactionStatus.ready,
          transferStatus: AddTransferStatus.initial,
          reviewable: false,
        ));
      }
      return false;
    }
    return state.transactionLines.every((transactionLine) {
      if ((transactionLine.address != null &&
              transactionLine.address!.isNotEmpty) &&
          (transactionLine.amount != null && transactionLine.amount! > 0)) {
        return true;
      }
      return false;
    });
  }

  @override
  Future<bool> verify(Emitter<AddTransferState> emit) async {
    bool allAddressesValid = true;
    List<TransactionLine> transactionLines = state.transactionLines;
    for (TransactionLine transactionLine in transactionLines) {
      if (await getIt<WalletService>()
          .isAddressValid(transactionLine.address ?? "")) {
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
      emit(state.copyWith(transactionLines: transactionLines));
      return true;
    } else {
      emit(state.copyWith(
        transferStatus: AddTransferStatus.addressInvalid,
      ));
      emit(state.copyWith(
        status: AddTransactionStatus.ready,
        transferStatus: AddTransferStatus.initial,
        reviewable: false,
      ));
      return false;
    }
  }

  @override
  Future<String> send(Emitter<AddTransferState> emit) async {
    return await _transactionService.sendTransferTransaction(
        state.currentWallet!.id,
        state.transactionLines.map((line) => line.amount!).toList(),
        state.transactionLines.map((line) => line.address!).toList(),
        state.extendedWalletData!.otsIndex,
        state.fee,
        state.message);
  }
}
