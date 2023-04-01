import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

part 'app_event.dart';

part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final WalletService _walletService;
  final SettingsService _settingsService;

  AppBloc()
      : _walletService = getIt<WalletService>(),
        _settingsService = getIt<SettingsService>(),
        super(AppState(appSettings: AppSettings())) {
    on<InitEvent>((event, emit) async {
      var walletCount = await _walletService.getWalletCount();
      AppSettings appSettings = await _settingsService.getAppSettings();
      emit(state.copyWith(
          status: AppStatus.ready,
          walletCount: walletCount,
          appSettings: appSettings));
    });

    on<SettingsUpdatedEvent>((event, emit) async {
      emit(state.copyWith(status: AppStatus.loading));
      AppSettings appSettings = await _settingsService.getAppSettings();
      emit(state.copyWith(status: AppStatus.ready, appSettings: appSettings));
    });
  }
}
