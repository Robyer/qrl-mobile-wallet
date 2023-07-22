import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';

part 'change_fee_event.dart';
part 'change_fee_state.dart';

class ChangeFeeBloc extends Bloc<ChangeFeeEvent, ChangeFeeState> {
  final SettingsService _settingsService;

  ChangeFeeBloc(int currentFee)
      : _settingsService = getIt<SettingsService>(),
        super(ChangeFeeState(currentFee: currentFee)) {
    on<ChangedEvent>(
      (event, emit) async {
        int newFee = event._newFee;
        if (state.currentFee != newFee) {
          emit(state.copyWith(status: ChangeFeeStatus.dirty, newFee: newFee));
        } else {
          emit(
              state.copyWith(status: ChangeFeeStatus.noChange, newFee: newFee));
        }
      },
      transformer: sequential(),
    );

    on<ConfirmEvent>((event, emit) async {
      if (state.status == ChangeFeeStatus.dirty) {
        await _settingsService.updateFeeSetting(state.newFee!);
      }
      emit(state.copyWith(
          status: ChangeFeeStatus.feeSaved, newFee: state.newFee));
    });
  }
}
