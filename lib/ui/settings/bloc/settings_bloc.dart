import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/model/app_language.dart';
import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/service/authentication_service.dart';
import 'package:mobile_wallet/service/notification_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;
  final AuthenticationService _authenticationService;
  final NotificationService _notificationService;

  SettingsBloc()
      : _settingsService = getIt<SettingsService>(),
        _authenticationService = getIt<AuthenticationService>(),
        _notificationService = getIt<NotificationService>(),
        super(const SettingsState()) {
    on<InitSettingsEvent>(
      (event, emit) async {
        emit(state.copyWith(status: SettingsStatus.loadingAppSettings));
        AppSettings appSettings = await _settingsService.getAppSettings();
        emit(state.copyWith(
            status: SettingsStatus.ready,
            currentAppSettings: appSettings,
            useDeviceLogin: appSettings.useDeviceLogin,
            nodeUrl: appSettings.nodeUrl,
            port: appSettings.port,
            appLanguage: appSettings.appLanguage,
            useTransactionNotification: appSettings.useTransactionNotification,
            usePriceNotification: appSettings.usePriceNotification));
        emit(state.copyWith(status: SettingsStatus.noChanges));
      },
    );

    on<UseDeviceLoginChanged>(
      (event, emit) async {
        emit(state.copyWith(
            status: SettingsStatus.useDeviceLoginChanged,
            useDeviceLogin: event.useDeviceLogin));
        _checkChanges(emit);
      },
      transformer: sequential(),
    );

    on<UseTransactionNotificationChanged>(
      (event, emit) async {
        emit(state.copyWith(
            status: SettingsStatus.useTransactionNotificationChanged,
            useTransactionNotification: event.useTransactionNotification));
        _checkChanges(emit);
      },
      transformer: sequential(),
    );

    on<UsePriceNotificationChanged>(
      (event, emit) async {
        emit(state.copyWith(
            status: SettingsStatus.usePriceNotificationChanged,
            usePriceNotification: event.usePriceNotification));
        _checkChanges(emit);
      },
      transformer: sequential(),
    );

    on<AppLanguageChanged>(
      (event, emit) async {
        emit(state.copyWith(
            status: SettingsStatus.appLanguageChanged,
            appLanguage: event.appLanguage));
        _checkChanges(emit);
      },
      transformer: sequential(),
    );

    on<NodeUrlChanged>(
      (event, emit) async {
        emit(state.copyWith(
            status: SettingsStatus.nodeUrlChanged, nodeUrl: event.nodeUrl));
        _checkChanges(emit);
      },
      transformer: sequential(),
    );

    on<PortChanged>(
      (event, emit) async {
        emit(state.copyWith(
            status: SettingsStatus.portChanged, port: event.port));
        _checkChanges(emit);
      },
      transformer: sequential(),
    );
    on<SaveEvent>(
      (event, emit) async {
        await _save(emit);
      },
      transformer: droppable(),
    );
  }

  void _checkChanges(Emitter<SettingsState> emit) {
    AppSettings currentAppSettings = state.currentAppSettings!;
    if (currentAppSettings.useDeviceLogin != state.useDeviceLogin ||
        currentAppSettings.port != state.port ||
        currentAppSettings.nodeUrl != state.nodeUrl ||
        currentAppSettings.appLanguage != state.appLanguage ||
        currentAppSettings.usePriceNotification != state.usePriceNotification ||
        currentAppSettings.useTransactionNotification !=
            state.useTransactionNotification) {
      emit(state.copyWith(status: SettingsStatus.dirty));
    } else {
      emit(state.copyWith(status: SettingsStatus.noChanges));
    }
  }

  Future<void> _save(Emitter<SettingsState> emit) async {
    try {
      Wakelock.enable();
      emit(state.copyWith(status: SettingsStatus.saving));
      AppSettings currentAppSettings = state.currentAppSettings!;
      if (currentAppSettings.useDeviceLogin != state.useDeviceLogin) {
        await _useDeviceLoginChanged(emit);
      }
      if (currentAppSettings.usePriceNotification !=
          state.usePriceNotification) {
        await _usePriceNotificationChanged(emit);
      } else if (state.usePriceNotification &&
          currentAppSettings.appLanguage != state.appLanguage) {
        await _notificationService.cancelPriceNotification();
        await _usePriceNotificationChanged(emit);
      }
      if (currentAppSettings.useTransactionNotification !=
          state.useTransactionNotification) {
        await _useTransactionNotificationChanged(emit);
      }
      AppSettings appSettings = AppSettings(
          useDeviceLogin: state.useDeviceLogin,
          nodeUrl: state.nodeUrl,
          port: state.port,
          appLanguage: state.appLanguage,
          useTransactionNotification: state.useTransactionNotification,
          usePriceNotification: state.usePriceNotification);
      await _settingsService.saveAppSettings(appSettings);
      emit(state.copyWith(
          status: SettingsStatus.saved, currentAppSettings: appSettings));
      emit(state.copyWith(status: SettingsStatus.noChanges));
    } finally {
      Wakelock.disable();
    }
  }

  Future<void> _useDeviceLoginChanged(Emitter<SettingsState> emit) async {
    if (state.useDeviceLogin) {
      if (!(await _authenticationService.hasDeviceAuthentication())) {
        emit(state.copyWith(
            status: SettingsStatus.noAuthenticationFound,
            useDeviceLogin: false));
      }
    } else {
      if (!(await getIt<AuthenticationService>().authenticate())) {
        emit(state.copyWith(
            status: SettingsStatus.authenticationFailed,
            useDeviceLogin: false));
      }
    }
  }

  Future<void> _usePriceNotificationChanged(Emitter<SettingsState> emit) async {
    if (await _checkAndRequestPermission(Permission.notification)) {
      if (state.usePriceNotification) {
        await _notificationService
            .schedulePriceNotification(state.appLanguage.name);
      } else {
        await _notificationService.cancelPriceNotification();
      }
    } else {
      emit(state.copyWith(
          status: SettingsStatus.permissionNotGranted,
          usePriceNotification: false));
    }
  }

  Future<void> _useTransactionNotificationChanged(
      Emitter<SettingsState> emit) async {
    if (await _checkAndRequestPermission(Permission.notification)) {
      if (state.useTransactionNotification) {
        await _notificationService.scheduleTransactionNotification();
      } else {
        await _notificationService.cancelTransactionNotification();
      }
    } else {
      emit(state.copyWith(
          status: SettingsStatus.permissionNotGranted,
          useTransactionNotification: false));
    }
  }

  Future<bool> _checkAndRequestPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    if (status.isDenied || status.isRestricted || status.isLimited) {
      status = await permission.request();
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return status.isGranted;
  }
}
