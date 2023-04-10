part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class InitSettingsEvent extends SettingsEvent {}

class UseDeviceLoginChanged extends SettingsEvent {
  final bool useDeviceLogin;

  const UseDeviceLoginChanged(this.useDeviceLogin);

  @override
  List<Object?> get props => [useDeviceLogin];
}

class UseTransactionNotificationChanged extends SettingsEvent {
  final bool useTransactionNotification;

  const UseTransactionNotificationChanged(this.useTransactionNotification);

  @override
  List<Object?> get props => [useTransactionNotification];
}

class UsePriceNotificationChanged extends SettingsEvent {
  final bool usePriceNotification;

  const UsePriceNotificationChanged(this.usePriceNotification);

  @override
  List<Object?> get props => [usePriceNotification];
}

class AppLanguageChanged extends SettingsEvent {
  final AppLanguage appLanguage;

  const AppLanguageChanged(this.appLanguage);

  @override
  List<Object?> get props => [appLanguage];
}

class NodeUrlChanged extends SettingsEvent {
  final String nodeUrl;

  const NodeUrlChanged(this.nodeUrl);

  @override
  List<Object?> get props => [nodeUrl];
}

class PortChanged extends SettingsEvent {
  final int port;

  const PortChanged(this.port);

  @override
  List<Object?> get props => [port];
}

class SaveEvent extends SettingsEvent {}
