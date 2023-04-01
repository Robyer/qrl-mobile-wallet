part of 'app_bloc.dart';

enum AppStatus { loading, ready }

class AppState extends Equatable {
  final AppStatus status;
  final int walletCount;
  final AppSettings appSettings;

  const AppState(
      {this.status = AppStatus.loading,
      this.walletCount = 0,
      required this.appSettings});

  AppState copyWith({
    AppStatus? status,
    int? walletCount,
    AppSettings? appSettings,
  }) {
    return AppState(
      status: status ?? this.status,
      walletCount: walletCount ?? this.walletCount,
      appSettings: appSettings ?? this.appSettings,
    );
  }

  @override
  List<Object> get props => [status, walletCount, appSettings];
}
