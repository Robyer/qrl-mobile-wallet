part of 'assets_bloc.dart';

abstract class AssetsEvent extends Equatable {
  const AssetsEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends AssetsEvent {}
