import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:mobile_wallet/model/app_settings.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/util/string_util.dart';

import 'proto/qrl.pbgrpc.dart';

class GrpcService {
  final SettingsService _settingsService;

  GrpcService(this._settingsService);

  Future<ExtendedWalletData> getExtendedWalletData(String walletAddress) async {
    List<int> addressBytes = StringUtil.toBytes(walletAddress);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      GetAddressStateResp getAddressStateResp = await publicAPIClient
          .getAddressState(GetAddressStateReq(address: addressBytes));
      var state = getAddressStateResp.state;
      List<TransactionData> transactions =
          await _findUnconfirmedTransactions(publicAPIClient, walletAddress);
      return ExtendedWalletData(
          state.balance.toInt(), _getOtsIndex(state) + transactions.length);
    } finally {
      clientChannel.shutdown();
    }
  }

  int _getOtsIndex(AddressState state) {
    List<List<int>> otsBitfield = state.otsBitfield;
    for (int i = 0; i < otsBitfield.length; i++) {
      int bitfieldByte = otsBitfield[i][0];
      if (bitfieldByte != -1) {
        String bitfieldString = bitfieldByte.toRadixString(2).padLeft(8, "0");
        String reversedBitfieldString = StringUtil.reverse(bitfieldString);
        for (int j = 0; j < reversedBitfieldString.length; j++) {
          if (reversedBitfieldString[j] == "0") {
            return (8 * i) + j;
          }
        }
      }
    }
    return -1;
  }

  Future<List<TransactionData>> findTransactions(
      String walletAddress, int batchCount,
      {int skip = -1}) async {
    List<int> addressBytes = StringUtil.toBytes(walletAddress);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      GetAddressStateResp getAddressStateResp = await publicAPIClient
          .getAddressState(GetAddressStateReq(address: addressBytes));
      var state = getAddressStateResp.state;
      List<TransactionData> transactions = <TransactionData>[];
      if (skip == -1) {
        transactions.addAll(
            await _findUnconfirmedTransactions(publicAPIClient, walletAddress));
      }
      transactions.addAll(await _findTransactions(
          state, publicAPIClient, walletAddress, transactions, batchCount,
          skip: skip == -1 ? 0 : skip));
      return transactions;
    } finally {
      clientChannel.shutdown();
    }
  }

  Future<List<TransactionData>> _findUnconfirmedTransactions(
      PublicAPIClient publicAPIClient, String walletAddress,
      {int offset = 0}) async {
    List<TransactionData> transactions = <TransactionData>[];
    int batchQuantity = 5;
    GetLatestDataResp getLatestDataResp = await publicAPIClient.getLatestData(
        GetLatestDataReq(
            filter: GetLatestDataReq_Filter.TRANSACTIONS_UNCONFIRMED,
            quantity: batchQuantity,
            offset: offset));
    int quantityFound = getLatestDataResp.transactionsUnconfirmed.length;
    if (getLatestDataResp.transactionsUnconfirmed.isNotEmpty) {
      for (TransactionExtended transactionExtended
          in getLatestDataResp.transactionsUnconfirmed) {
        String senderAddress = transactionExtended.addrFrom
            .map((e) => e.toRadixString(16).padLeft(2, '0'))
            .join();
        bool incoming = senderAddress != walletAddress;
        Transaction tx = transactionExtended.tx;
        if ("transfer" == tx.whichTransactionType().name.toLowerCase()) {
          Transaction_Transfer transfer = tx.transfer;
          String? message = tx.transfer.messageData.isNotEmpty
              ? utf8.decode(tx.transfer.messageData)
              : null;
          for (int i = 0; i < transfer.addrsTo.length; i++) {
            String receiverAddress = transfer.addrsTo[i]
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join();
            if (!incoming || receiverAddress == walletAddress) {
              transactions.add(TransactionData(
                  tx.transactionHash
                      .map((e) => e.toRadixString(16).padLeft(2, '0'))
                      .join(),
                  "transfer",
                  senderAddress,
                  receiverAddress,
                  transfer.amounts[i].toInt(),
                  DateTime.fromMillisecondsSinceEpoch(
                      transactionExtended.timestampSeconds.toInt() * 1000),
                  incoming,
                  true,
                  message));
            }
          }
        }
      }
      if (quantityFound == batchQuantity) {
        transactions.addAll(await _findUnconfirmedTransactions(
            publicAPIClient, walletAddress,
            offset: offset + batchQuantity));
      }
    }
    return transactions;
  }

  Future<List<TransactionData>> _findTransactions(
      AddressState state,
      PublicAPIClient publicAPIClient,
      String walletAddress,
      List<TransactionData> transactions,
      int batchCount,
      {int skip = 0}) async {
    List<TransactionData> transactions = <TransactionData>[];
    List<List<int>> transactionsHashes = state.transactionHashes;
    int totalTransactions = transactionsHashes.length;
    if (totalTransactions <= skip) {
      return transactions;
    }
    int lastTransactionToGet = 0;
    if (totalTransactions > (batchCount + skip)) {
      lastTransactionToGet = totalTransactions - batchCount - skip;
    }
    for (int i = totalTransactions - 1; i >= lastTransactionToGet; i--) {
      GetObjectResp getObjectResp = await publicAPIClient
          .getObject(GetObjectReq(query: transactionsHashes[i]));
      TransactionExtended transaction = getObjectResp.transaction;
      Transaction tx = transaction.tx;
      if ("transfer" == tx.whichTransactionType().name.toLowerCase()) {
        String transactionHash = tx.transactionHash
            .map((e) => e.toRadixString(16).padLeft(2, '0'))
            .join();
        String senderAddress = transaction.addrFrom
            .map((e) => e.toRadixString(16).padLeft(2, '0'))
            .join();
        bool incoming = senderAddress != walletAddress;
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
            transaction.timestampSeconds.toInt() * 1000);
        String? message = tx.transfer.messageData.isNotEmpty
            ? utf8.decode(tx.transfer.messageData)
            : null;
        for (int j = 0; j < tx.transfer.addrsTo.length; j++) {
          String receiverAddress = tx.transfer.addrsTo[j]
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join();
          if (!incoming || receiverAddress == walletAddress) {
            transactions.add(TransactionData(
                transactionHash,
                "transfer",
                senderAddress,
                receiverAddress,
                tx.transfer.amounts[j].toInt(),
                dateTime,
                incoming,
                false,
                message));
          }
        }
      }
    }
    return transactions;
  }

  Future<void> sendTransaction(
      String senderWalletAddress,
      String xmssPk,
      List<int> amounts,
      List<String> receiverWalletAddresses,
      int otsIndex,
      int fee,
      String transactionData,
      String message) async {
    List<List<int>> receiverWalletBytesList = receiverWalletAddresses
        .map((address) => StringUtil.toBytes(address))
        .toList();
    List<Int64> int64Amounts = amounts.map((amount) => Int64(amount)).toList();
    Int64 int64Fee = Int64(fee);
    String signature =
        transactionData.substring(0, (transactionData.length - 64));
    List<int> txSignature = StringUtil.toBytes(signature);
    String hash = transactionData.substring(
        (transactionData.length - 64), transactionData.length);
    List<int> messageData = Uint8List.fromList(utf8.encode(message));
    List<int> txHash = StringUtil.toBytes(hash);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      var transferCoinsReq = TransferCoinsReq(
          messageData: messageData,
          addressesTo: receiverWalletBytesList,
          amounts: int64Amounts,
          fee: int64Fee,
          xmssPk: StringUtil.toBytes(xmssPk));
      TransferCoinsResp transferCoinsResp =
          await publicAPIClient.transferCoins(transferCoinsReq);
      await publicAPIClient.pushTransaction(PushTransactionReq(
          transactionSigned: Transaction(
              transfer: Transaction_Transfer(
                  addrsTo: receiverWalletBytesList,
                  amounts: int64Amounts,
                  messageData: messageData),
              signature: txSignature,
              transactionHash: txHash,
              fee: int64Fee,
              publicKey:
                  transferCoinsResp.extendedTransactionUnsigned.tx.publicKey,
              nonce: Int64(12))));
    } finally {
      clientChannel.shutdown();
    }
  }

  Future<ClientChannel> getClientChannel() async {
    AppSettings appSettings = await _settingsService.getAppSettings();
    ClientChannel clientChannel = ClientChannel(
      appSettings.nodeUrl,
      port: appSettings.port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    return clientChannel;
  }

  Future<bool> hasIncomingTransactionsAfterDate(
      String walletAddress, DateTime lastCheckDateTime) async {
    List<int> addressBytes = StringUtil.toBytes(walletAddress);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      GetAddressStateResp getAddressStateResp = await publicAPIClient
          .getAddressState(GetAddressStateReq(address: addressBytes));
      var state = getAddressStateResp.state;
      List<List<int>> transactionsHashes = state.transactionHashes;
      int totalTransactions = transactionsHashes.length;

      for (int i = totalTransactions - 1; i >= 0; i--) {
        GetObjectResp getObjectResp = await publicAPIClient
            .getObject(GetObjectReq(query: transactionsHashes[i]));
        TransactionExtended transaction = getObjectResp.transaction;
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
            transaction.timestampSeconds.toInt() * 1000);
        if (dateTime.isBefore(lastCheckDateTime)) {
          break;
        }
        Transaction tx = transaction.tx;
        if ("transfer" == tx.whichTransactionType().name.toLowerCase()) {
          String senderAddress = transaction.addrFrom
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join();
          bool incoming = senderAddress != walletAddress;
          if (incoming) {
            return true;
          }
        }
      }
    } finally {
      clientChannel.shutdown();
    }
    return false;
  }
}
