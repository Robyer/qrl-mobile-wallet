part of 'verify_notarization_bloc.dart';

enum VerifyNotarizationStatus {
  initial,
  searching,
  notarizationFound,
  notarizationNotFound,
  verifying,
  verified,
  verifyFailed
}

class VerifyNotarizationState extends Equatable {
  final VerifyNotarizationStatus status;
  final String? transactionHash;
  final NotarizationMessage? notarizationMessage;
  final String? lastFileName;

  const VerifyNotarizationState({
    this.status = VerifyNotarizationStatus.initial,
    this.transactionHash,
    this.notarizationMessage,
    this.lastFileName,
  });

  VerifyNotarizationState copyWith(
      {VerifyNotarizationStatus? status,
      String? transactionHash,
      NotarizationMessage? notarizationMessage,
      String? lastFileName}) {
    return VerifyNotarizationState(
      status: status ?? this.status,
      transactionHash: transactionHash ?? this.transactionHash,
      notarizationMessage: notarizationMessage ?? this.notarizationMessage,
      lastFileName: lastFileName ?? this.lastFileName,
    );
  }

  @override
  List<Object> get props => [
        status,
        transactionHash ?? "",
        notarizationMessage ?? "",
        lastFileName ?? "",
      ];
}
