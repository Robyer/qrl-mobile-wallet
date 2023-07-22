import 'package:flutter/foundation.dart';
import 'package:mobile_wallet/model/notarization_message.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/ffi_wallet_service.dart';
import 'package:mobile_wallet/service/grpc_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';

class TransactionService {
  final WalletService _walletService;
  final GrpcService _grpcService;
  final FfiWalletService _ffiWalletService;

  TransactionService(
      this._walletService, this._grpcService, this._ffiWalletService);

  Future<String> sendTransferTransaction(
      int id,
      List<int> amounts,
      List<String> receiverWalletAddresses,
      int otsIndex,
      int fee,
      String? message) async {
    Wallet wallet = await _walletService.getWallet(id);
    receiverWalletAddresses = receiverWalletAddresses
        .map((receiverWalletAddress) => receiverWalletAddress.startsWith("Q")
            ? receiverWalletAddress.substring(1, receiverWalletAddress.length)
            : receiverWalletAddress)
        .toList();
    String transactionData = await compute<List<Object>, String>(
        _ffiWalletService.ffiCreateTransaction, [
      await _walletService.getHexSeed(id),
      amounts,
      receiverWalletAddresses,
      otsIndex,
      fee,
      message ?? "",
      1,
    ]);
    return await _grpcService.sendTransferTransaction(
        wallet.address,
        await _walletService.getXmsspk(id),
        amounts,
        receiverWalletAddresses,
        otsIndex,
        fee,
        transactionData,
        message ?? "");
  }

  Future<String> sendMessageTransaction(
      int id, String message, int otsIndex, int fee,
      {MessageType messageType = MessageType.text}) async {
    Wallet wallet = await _walletService.getWallet(id);
    String transactionData = await compute<List<Object>, String>(
        _ffiWalletService.ffiCreateTransaction, [
      await _walletService.getHexSeed(id),
      <int>[],
      <String>[],
      otsIndex,
      fee,
      message,
      messageType == MessageType.text ? 1 : 2,
    ]);
    return await _grpcService.sendMessageTransaction(
        wallet.address,
        await _walletService.getXmsspk(id),
        message,
        otsIndex,
        fee,
        transactionData,
        messageType: messageType);
  }

  Future<List<TransactionData>> findTransactions(
      String walletAddress, int batchCount,
      {int skip = -1}) async {
    return await _grpcService.findTransactions(walletAddress, batchCount,
        skip: skip);
  }

  Future<NotarizationMessage?> findNotarization(String transactionHash) async {
    return NotarizationMessage.fromTransactionData(
        await _grpcService.findMessageTransaction(transactionHash));
  }
}
