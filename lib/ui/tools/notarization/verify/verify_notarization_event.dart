part of 'verify_notarization_bloc.dart';

abstract class VerifyNotarizationEvent extends Equatable {
  const VerifyNotarizationEvent();

  @override
  List<Object?> get props => [];
}

class TransactionHashChangedEvent extends VerifyNotarizationEvent {
  final String transactionHash;

  const TransactionHashChangedEvent(this.transactionHash);

  @override
  List<Object?> get props => [transactionHash];
}

class SearchEvent extends VerifyNotarizationEvent {}

class VerifyEvent extends VerifyNotarizationEvent {
  final FilePickerResult filePickerResult;

  const VerifyEvent(this.filePickerResult);

  @override
  List<Object?> get props => [filePickerResult];
}
