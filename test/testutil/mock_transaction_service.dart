import 'package:mobile_wallet/model/notarization_message.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mockito/mockito.dart';

class MockTransactionService extends Mock implements TransactionService {
@override
  Future<NotarizationMessage?> findNotarization(String transactionHash) async {
    return Future(() => null);
  }
}
