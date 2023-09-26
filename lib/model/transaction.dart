enum TransactionType {
  transfer,
  message,
  token,
  transferToken,
}

enum MessageType { text, hex }

class TransactionData {
  final TransactionType transactionType;
  final String hash;
  final String type;
  final String senderAddress;
  final String? receiverAddress;
  final int? amount;
  final DateTime dateTime;
  final bool incoming;
  final bool unconfirmed;
  final String? message;
  final MessageType? messageType;
  final int fee;
  final String? tokenName;
  final String? tokenSymbol;
  final int? tokenDecimals;
  final String? tokenHash;
  final String? tokenOwnerAddress;
  final List<InitialTokenHolder>? initialTokenHolders;

  TransactionData(
    this.transactionType,
    this.hash,
    this.type,
    this.senderAddress,
    this.dateTime,
    this.incoming,
    this.unconfirmed,
    this.fee, {
    this.receiverAddress,
    this.amount,
    this.message,
    this.messageType,
    this.tokenName,
    this.tokenSymbol,
    this.tokenDecimals,
    this.tokenHash,
    this.tokenOwnerAddress,
    this.initialTokenHolders,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionData &&
          runtimeType == other.runtimeType &&
          hash == other.hash;

  @override
  int get hashCode => hash.hashCode;
}

class InitialTokenHolder {
  final String address;
  final int amount;

  InitialTokenHolder(this.address, this.amount);
}
