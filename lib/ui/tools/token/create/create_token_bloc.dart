import 'dart:developer' as developer;
import 'dart:math';

import 'package:bloc/src/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:decimal/decimal.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_event.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_state.dart';

class CreateTokenBloc extends AddTransactionBloc<CreateTokenState> {
  final WalletService _walletService;
  final AddressBookService _addressBookService;
  final TransactionService _transactionService;

  CreateTokenBloc()
      : _transactionService = getIt<TransactionService>(),
        _walletService = getIt<WalletService>(),
        _addressBookService = getIt<AddressBookService>(),
        super(CreateTokenState(initialHolders: [InitialHolder()])) {
    on<OwnerAddressChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(ownerAddress: event.ownerAddress));
        await checkReviewable(emit);
      },
      transformer: sequential(),
    );
    on<SaveOwnerAddressToAddressBookChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(
            saveOwnerAddressToAddressBook: event.saveOwnerToAddressBook));
      },
      transformer: sequential(),
    );

    on<TokenNameChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(tokenName: event.tokenName));
        await checkReviewable(emit);
      },
      transformer: sequential(),
    );

    on<TokenSymbolChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(tokenSymbol: event.tokenSymbol));
        await checkReviewable(emit);
      },
      transformer: sequential(),
    );

    on<TokenDecimalsChangedEvent>(
      (event, emit) async {
        String tokenDecimalsString = event.tokenDecimals;
        int tokenDecimals = 0;
        if (tokenDecimalsString.isNotEmpty) {
          try {
            tokenDecimals = int.parse(tokenDecimalsString);
          } on Exception catch (e, stacktrace) {
            developer.log(e.toString(), stackTrace: stacktrace);
          }
        }
        for (InitialHolder initialHolder in state.initialHolders) {
          if (initialHolder.initialBalance != null) {
            initialHolder.initialBalance = null;
          }
        }
        emit(state.copyWith(tokenDecimals: tokenDecimals));
      },
      transformer: sequential(),
    );

    on<InitialAddressChangedEvent>(
      (event, emit) async {
        int initialHolderNumber = event.initialHolder;
        List<InitialHolder> initialHolders = state.initialHolders;
        if (initialHolders.length >= initialHolderNumber) {
          InitialHolder initialHolder = initialHolders[initialHolderNumber];
          String newAddress = event.address;
          initialHolder.address = newAddress;
          emit(state.copyWith(initialHolders: initialHolders));
          await checkReviewable(emit);
        }
      },
      transformer: sequential(),
    );

    on<SaveInitialHolderAddressToAddressBookChangedEvent>(
      (event, emit) async {
        int initialHolderNumber = event.initialHolder;
        List<InitialHolder> initialHolders = state.initialHolders;
        if (initialHolders.length >= initialHolderNumber) {
          InitialHolder initialHolder = initialHolders[initialHolderNumber];
          initialHolder.saveToAddressBook = event.value;
          CreateTokenStatus currentCreateTokenStatus = state.createTokenStatus;
          emit(state.copyWith(
              createTokenStatus: CreateTokenStatus.saveToAddressBookUpdated,
              initialHolders: initialHolders));
          emit(state.copyWith(createTokenStatus: currentCreateTokenStatus));
          await checkReviewable(emit);
        }
      },
      transformer: sequential(),
    );

    on<InitialBalanceChangedEvent>(
      (event, emit) async {
        String initialBalanceString = event.initialBalanceString;
        int initialBalance = 0;
        if (initialBalanceString.isNotEmpty) {
          initialBalance = (Decimal.parse(initialBalanceString) *
                  BigInt.from(10).pow(state.tokenDecimals).toDecimal())
              .toBigInt()
              .toInt();
        }

        int initialHolderNumber = event.initialHolder;
        List<InitialHolder> initialHolders = state.initialHolders;
        if (initialHolders.length >= initialHolderNumber) {
          InitialHolder initialHolder = initialHolders[initialHolderNumber];
          initialHolder.initialBalance = initialBalance;

          List<BigInt> filteredLines = initialHolders
              .where((initialHolder) =>
                  initialHolder.initialBalance != null &&
                  initialHolder.initialBalance! > 0)
              .map(
                  (initialHolder) => BigInt.from(initialHolder.initialBalance!))
              .toList();
          BigInt totalAmount = filteredLines.isNotEmpty
              ? filteredLines.reduce((value, element) => value + element)
              : BigInt.zero;
          if (!totalAmount.isValidInt) {
            emit(state.copyWith(
                reviewable: false,
                createTokenStatus: CreateTokenStatus.initialBalanceToLarge));
          } else {
            await checkReviewable(emit);
          }
        }
      },
      transformer: sequential(),
    );

    on<AddInitialHolderEvent>((event, emit) async {
      List<InitialHolder> initialHolders = state.initialHolders;
      initialHolders.add(InitialHolder());
      CreateTokenStatus currentCreateTokenStatus = state.createTokenStatus;
      emit(state.copyWith(
          reviewable: false,
          initialHolders: initialHolders,
          createTokenStatus: CreateTokenStatus.initialHolderCountUpdated));
      emit(state.copyWith(createTokenStatus: currentCreateTokenStatus));
    });

    on<RemoveInitialHolderEvent>((event, emit) async {
      List<InitialHolder> initialHolders = state.initialHolders;
      initialHolders.removeAt(event.initialHolder);
      CreateTokenStatus createTokenStatus = state.createTokenStatus;
      emit(state.copyWith(
          initialHolders: initialHolders,
          createTokenStatus: CreateTokenStatus.initialHolderCountUpdated));
      emit(state.copyWith(createTokenStatus: createTokenStatus));
      await checkReviewable(emit);
    });
  }

  @override
  Future<void> checkReviewable(Emitter<CreateTokenState> emit) async {
    if (state.ownerAddress.isNotEmpty &&
        state.tokenName.isNotEmpty &&
        state.tokenSymbol.isNotEmpty &&
        state.tokenDecimals > 0 &&
        state.fee < (state.extendedWalletData?.balance ?? 0) &&
        _isValid()) {
      emit(state.copyWith(reviewable: true));
    } else {
      emit(state.copyWith(reviewable: false));
    }
  }

  bool _isValid() {
    return state.initialHolders.every((initialHolder) {
      if ((initialHolder.address != null &&
              initialHolder.address!.isNotEmpty) &&
          (initialHolder.initialBalance != null &&
              initialHolder.initialBalance! > 0)) {
        return true;
      }
      return false;
    });
  }

  @override
  Future<bool> verify(Emitter<CreateTokenState> emit) async {
    bool allAddressesValid = true;
    List<InitialHolder> initialHolders = state.initialHolders;
    if (await _walletService.isAddressValid(state.ownerAddress)) {
      bool saveToAddressBook = state.saveOwnerAddressToAddressBook;
      if (saveToAddressBook &&
          await _addressBookService.hasAddress(state.ownerAddress)) {
        emit(state.copyWith(saveOwnerAddressToAddressBook: false));
      }
    } else {
      allAddressesValid = false;
    }
    for (InitialHolder initialHolder in initialHolders) {
      if (await _walletService.isAddressValid(initialHolder.address ?? "")) {
        bool saveToAddressBook = initialHolder.saveToAddressBook;
        if (saveToAddressBook &&
            await _addressBookService.hasAddress(initialHolder.address!)) {
          initialHolder.saveToAddressBook = false;
        }
      } else {
        allAddressesValid = false;
      }
    }
    if (allAddressesValid) {
      emit(state.copyWith(initialHolders: initialHolders));
      return true;
    } else {
      emit(state.copyWith(
        createTokenStatus: CreateTokenStatus.addressInvalid,
      ));
      emit(state.copyWith(
        status: AddTransactionStatus.ready,
        createTokenStatus: CreateTokenStatus.initial,
        reviewable: false,
      ));
      return false;
    }
  }

  @override
  Future<String> send(Emitter<CreateTokenState> emit) async {
    return await _transactionService.sendTokenTransaction(
      state.currentWallet!.id,
      state.tokenSymbol,
      state.tokenName,
      state.ownerAddress,
      state.tokenDecimals,
      state.initialHolders.map((line) => line.initialBalance!).toList(),
      state.initialHolders.map((line) => line.address!).toList(),
      state.extendedWalletData!.otsIndex,
      state.fee,
    );
  }
}
