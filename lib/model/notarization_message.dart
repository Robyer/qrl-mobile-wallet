import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/util/string_util.dart';

class NotarizationMessage extends Equatable {
  final String notary;
  final String hashFunction;
  final String fileHash;
  final String additionalMessage;

  const NotarizationMessage(
      this.notary, this.hashFunction, this.fileHash, this.additionalMessage);

  static NotarizationMessage? fromTransactionData(
      TransactionData? transactionData) {
    if (transactionData != null && transactionData.message != null) {
      String message = transactionData.message!;
      if (message.length >= 70 &&
          message.substring(0, 5).toLowerCase() == "afafa") {
        String hashFunction = message.substring(5, 6);
        if ("2" == hashFunction) {
          String fileHash = message.substring(6, 70);
          String additionalMessage = "";
          if (message.length > 70) {
            String additionalMessageHash = message.substring(70);
            additionalMessage =
                utf8.decode(StringUtil.toBytes(additionalMessageHash));
          }
          return NotarizationMessage(transactionData.senderAddress,
              hashFunction, fileHash, additionalMessage);
        }
      }
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [notary, hashFunction, fileHash, additionalMessage];
}
