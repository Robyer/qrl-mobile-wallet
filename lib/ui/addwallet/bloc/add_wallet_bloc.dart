import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:wakelock/wakelock.dart';

part 'add_wallet_event.dart';

part 'add_wallet_state.dart';

class AddWalletBloc extends Bloc<AddWalletEvent, AddWalletState> {
  final WalletService _walletService;
  final AddWalletMode _addWalletMode;

  AddWalletBloc(this._addWalletMode)
      : _walletService = getIt<WalletService>(),
        super(AddWalletState(_addWalletMode)) {
    on<NameChangedEvent>((event, emit) async {
      String newName = event.value;
      if (newName.isNotEmpty) {
        if (_addWalletMode == AddWalletMode.create && newName.isNotEmpty) {
          emit(state.copyWith(status: AddWalletStatus.valid, name: newName));
        } else if (_addWalletMode != AddWalletMode.create &&
            (state.mnemonic != null || state.hexSeed != null)) {
          emit(state.copyWith(status: AddWalletStatus.valid, name: newName));
        } else {
          emit(state.copyWith(name: newName));
        }
      } else {
        emit(state.copyWith(status: AddWalletStatus.initial, name: null));
      }
    }, transformer: sequential());

    on<TreeHeightChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(treeHeight: event.value));
      },
    );

    on<HashFunctionChangedEvent>(
      (event, emit) async {
        emit(state.copyWith(hashFunction: event.value));
      },
    );

    on<WalletModeChangedEvent>(
      (event, emit) async {
        if (event.value == AddWalletMode.mnemonic) {
          emit(state.copyWith(addWalletMode: event.value, hexSeed: null));
        } else if (event.value == AddWalletMode.hexSeed) {
          emit(state.copyWith(addWalletMode: event.value, mnemonic: null));
        }
      },
    );

    on<HexSeedChangedEvent>((event, emit) async {
      String newHexSeed = event.value;
      if (newHexSeed.isNotEmpty) {
        if (state.name != null) {
          emit(state.copyWith(
              status: AddWalletStatus.valid, hexSeed: newHexSeed));
        } else {
          emit(state.copyWith(hexSeed: newHexSeed));
        }
      } else {
        emit(state.copyWith(status: AddWalletStatus.initial, hexSeed: null));
      }
    }, transformer: sequential());

    on<MnemonicChangedEvent>((event, emit) async {
      String newMnemonic = event.value;
      if (newMnemonic.isNotEmpty) {
        if (state.name != null) {
          emit(state.copyWith(
              status: AddWalletStatus.valid, mnemonic: newMnemonic));
        } else {
          emit(state.copyWith(mnemonic: newMnemonic));
        }
      } else {
        emit(state.copyWith(status: AddWalletStatus.initial, mnemonic: null));
      }
    }, transformer: sequential());

    on<ConfirmEvent>(
      (event, emit) async {
        try {
          Wakelock.enable();
          emit(state.copyWith(status: AddWalletStatus.creating));
          Wallet wallet;
          if (_addWalletMode == AddWalletMode.create) {
            wallet = await _walletService.createWallet(state.name!,
                treeHeight: state.treeHeight, hashFunction: state.hashFunction);
          } else {
            wallet = await _walletService.createWallet(state.name!,
                mnemonic: state.mnemonic, hexSeed: state.hexSeed);
          }
          emit(state.copyWith(
              status: AddWalletStatus.created, createdWallet: wallet));
        } on Exception catch (e, stacktrace) {
          var errorMessage = e.toString();
          log(errorMessage, stackTrace: stacktrace);
          emit(state.copyWith(
              status: AddWalletStatus.error, errorMessage: errorMessage));
        } finally {
          Wakelock.disable();
        }
      },
    );
  }
}
