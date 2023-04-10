part of 'settings_bloc.dart';

enum SettingsStatus {
  initial,
  loadingAppSettings,
  ready,
  noChanges,
  dirty,
  useDeviceLoginChanged,
  useTransactionNotificationChanged,
  usePriceNotificationChanged,
  appLanguageChanged,
  nodeUrlChanged,
  portChanged,
  saving,
  noAuthenticationFound,
  authenticationFailed,
  permissionNotGranted,
  saved,
}

class SettingsState extends Equatable {
  final AppSettings? currentAppSettings;
  final SettingsStatus status;
  final bool useDeviceLogin;
  final String nodeUrl;
  final int port;
  final AppLanguage appLanguage;
  final bool useTransactionNotification;
  final bool usePriceNotification;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.currentAppSettings,
    this.useDeviceLogin = false,
    this.nodeUrl = "mainnet-1.automated.theqrl.org",
    this.port = 19009,
    this.appLanguage = AppLanguage.en,
    this.useTransactionNotification = false,
    this.usePriceNotification = false,
  });

  SettingsState copyWith({
    AppSettings? currentAppSettings,
    SettingsStatus? status,
    bool? useDeviceLogin,
    String? nodeUrl,
    int? port,
    AppLanguage? appLanguage,
    bool? useTransactionNotification,
    bool? usePriceNotification,
  }) {
    return SettingsState(
      status: status ?? this.status,
      currentAppSettings: currentAppSettings ?? this.currentAppSettings,
      useDeviceLogin: useDeviceLogin ?? this.useDeviceLogin,
      nodeUrl: nodeUrl ?? this.nodeUrl,
      port: port ?? this.port,
      appLanguage: appLanguage ?? this.appLanguage,
      useTransactionNotification:
          useTransactionNotification ?? this.useTransactionNotification,
      usePriceNotification: usePriceNotification ?? this.usePriceNotification,
    );
  }

  @override
  List<Object> get props => [
        status,
        currentAppSettings ?? AppSettings(),
        useDeviceLogin,
        nodeUrl,
        port,
        appLanguage,
        useTransactionNotification,
        usePriceNotification,
      ];
}
