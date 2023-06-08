class TransactionData {
  final String _hash;
  final String _type;
  final String _senderAddress;
  final String _receiverAddress;
  final int _amount;
  final DateTime _dateTime;
  final bool _incoming;
  final bool _unconfirmed;
  final String? _message;
  final int _fee;

  TransactionData(
      this._hash,
      this._type,
      this._senderAddress,
      this._receiverAddress,
      this._amount,
      this._dateTime,
      this._incoming,
      this._unconfirmed,
      this._message,
      this._fee);

  String get hash => _hash;

  String get type => _type;

  String get senderAddress => _senderAddress;

  String get receiverAddress => _receiverAddress;

  int get amount => _amount;

  DateTime get dateTime => _dateTime;

  bool get incoming => _incoming;

  bool get unconfirmed => _unconfirmed;

  String? get message => _message;

  int get fee => _fee;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionData &&
          runtimeType == other.runtimeType &&
          _hash == other._hash;

  @override
  int get hashCode => _hash.hashCode;
}
