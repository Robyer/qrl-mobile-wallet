class Transaction {
  final int _amount;
  final String _receiverWalletAddress;
  final int _otsIndex;
  final int _fee;

  Transaction(
      this._amount, this._receiverWalletAddress, this._otsIndex, this._fee);

}

class TransactionLine {
  final int _amount;
  final String _receiverWalletAddress;

  TransactionLine(this._amount, this._receiverWalletAddress);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionLine &&
          runtimeType == other.runtimeType &&
          _amount == other._amount &&
          _receiverWalletAddress == other._receiverWalletAddress;

  @override
  int get hashCode => _amount.hashCode ^ _receiverWalletAddress.hashCode;
}
