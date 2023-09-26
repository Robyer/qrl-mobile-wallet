import 'package:mobile_wallet/model/transaction.dart';

class ExtendedWalletData {
  final int balance;
  final int otsIndex;
  final List<TokenData> tokens;

  ExtendedWalletData(this.balance, this.otsIndex, this.tokens);
}

class TokenData {
  final String tokenTransactionHash;
  final int balance;
  TransactionData? tokenTransactionData;

  TokenData(this.tokenTransactionHash, this.balance);
}
