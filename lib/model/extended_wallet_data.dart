class ExtendedWalletData {
  final int _balance;
  final int _otsIndex;

  ExtendedWalletData(this._balance, this._otsIndex);

  int get balance => _balance;

  int get otsIndex => _otsIndex;
}
