import 'package:file_picker/file_picker.dart';
import 'package:mobile_wallet/ui/addtransaction/add_transaction_bloc.dart';

abstract class AddNotarizationEvent extends AddTransactionEvent {
  const AddNotarizationEvent();
}

class UploadFileEvent extends AddNotarizationEvent {
  final FilePickerResult filePickerResult;

  const UploadFileEvent(this.filePickerResult);

  @override
  List<Object?> get props => [filePickerResult];
}

class HasMessageChangedEvent extends AddNotarizationEvent {
  final bool hasMessage;

  const HasMessageChangedEvent(this.hasMessage);

  @override
  List<Object?> get props => [hasMessage];
}

class MessageChangedEvent extends AddNotarizationEvent {
  final String message;

  const MessageChangedEvent(this.message);

  @override
  List<Object?> get props => [message];
}
