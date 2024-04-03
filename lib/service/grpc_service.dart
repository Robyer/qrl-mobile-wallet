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

  Future<ExtendedWalletData> getExtendedWalletData(String walletAddress,
      {bool loadTokenTransaction = false}) async {
    List<int> addressBytes = StringUtil.toBytes(walletAddress);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      GetAddressStateResp getAddressStateResp = await publicAPIClient
          .getAddressState(GetAddressStateReq(address: addressBytes));
      var state = getAddressStateResp.state;
      List<TransactionData> transactions =
          await _findUnconfirmedTransactions(publicAPIClient, walletAddress);
      List<TokenData> tokens =
          await Future.wait(state.tokens.entries.map((e) async {
        TokenData tokenData =
            TokenData(e.key, BigInt.parse(e.value.toStringUnsigned()).toInt());
        if (loadTokenTransaction) {
          tokenData.tokenTransactionData =
              await findTokenTransaction(tokenData.tokenTransactionHash);
        }
        return tokenData;
      }).toList());
      tokens.sort((a, b) => (a.tokenTransactionData?.tokenSymbol ?? "")
          .toLowerCase()
          .compareTo(
              (b.tokenTransactionData?.tokenSymbol ?? "").toLowerCase()));
      return ExtendedWalletData(state.balance.toInt(),
          _getOtsIndex(state) + transactions.length, tokens);
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
      {int skip = -1, DateTime? fromDate, DateTime? toDate}) async {
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
          skip: skip == -1 ? 0 : skip, fromDate: fromDate, toDate: toDate));
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
        String senderAddress =
            StringUtil.fromBytes(transactionExtended.addrFrom);
        bool incoming = senderAddress != walletAddress;
        Transaction tx = transactionExtended.tx;
        if ("transfer" == tx.whichTransactionType().name.toLowerCase()) {
          Transaction_Transfer transfer = tx.transfer;
          String? message = tx.transfer.messageData.isNotEmpty
              ? utf8.decode(tx.transfer.messageData)
              : null;
          for (int i = 0; i < transfer.addrsTo.length; i++) {
            String receiverAddress = StringUtil.fromBytes(transfer.addrsTo[i]);
            if (!incoming || receiverAddress == walletAddress) {
              transactions.add(TransactionData(
                  TransactionType.transfer,
                  StringUtil.fromBytes(tx.transactionHash),
                  "transfer",
                  senderAddress,
                  DateTime.fromMillisecondsSinceEpoch(
                      transactionExtended.timestampSeconds.toInt() * 1000),
                  incoming,
                  true,
                  tx.fee.toInt(),
                  receiverAddress: receiverAddress,
                  amount: transfer.amounts[i].toInt(),
                  message: message,
                  messageType: MessageType.text));
            }
          }
        } else if ("message" == tx.whichTransactionType().name.toLowerCase()) {
          transactions.add(_convertMessage(transactionExtended));
        } else if ("token" == tx.whichTransactionType().name.toLowerCase()) {
          transactions.add(_convertToken(transactionExtended));
        } else if ("transfertoken" ==
            tx.whichTransactionType().name.toLowerCase()) {
          await _convertTransferToken(transactions, transactionExtended,
              walletAddress, publicAPIClient);
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
      {int skip = 0,
      DateTime? fromDate,
      DateTime? toDate}) async {
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
    for (int i = totalTransactions - 1 - skip; i >= lastTransactionToGet; i--) {
      GetObjectResp getObjectResp = await publicAPIClient
          .getObject(GetObjectReq(query: transactionsHashes[i]));
      TransactionExtended transaction = getObjectResp.transaction;
      if (fromDate != null || toDate != null) {
        DateTime transactionDate = DateTime.fromMillisecondsSinceEpoch(
            transaction.timestampSeconds.toInt() * 1000);
        if (fromDate != null && fromDate.isAfter(transactionDate)) {
          break;
        }
        if (toDate != null && toDate.isBefore(transactionDate)) {
          break;
        }
      }
      Transaction tx = transaction.tx;
      if ("transfer" == tx.whichTransactionType().name.toLowerCase()) {
        _convertTransfer(transaction, walletAddress, tx, transactions);
      } else if ("message" == tx.whichTransactionType().name.toLowerCase()) {
        transactions.add(_convertMessage(transaction));
      } else if ("token" == tx.whichTransactionType().name.toLowerCase()) {
        transactions.add(_convertToken(transaction));
      } else if ("transfertoken" ==
          tx.whichTransactionType().name.toLowerCase()) {
        await _convertTransferToken(
            transactions, transaction, walletAddress, publicAPIClient);
      }
    }
    return transactions;
  }

  void _convertTransfer(TransactionExtended transaction, String walletAddress,
      Transaction tx, List<TransactionData> transactions) {
    String senderAddress = StringUtil.fromBytes(transaction.addrFrom);
    bool incoming = senderAddress != walletAddress;
    String? message = tx.transfer.messageData.isNotEmpty
        ? utf8.decode(tx.transfer.messageData)
        : null;
    for (int j = 0; j < tx.transfer.addrsTo.length; j++) {
      String receiverAddress = StringUtil.fromBytes(tx.transfer.addrsTo[j]);
      if (!incoming || receiverAddress == walletAddress) {
        transactions.add(TransactionData(
            TransactionType.transfer,
            StringUtil.fromBytes(tx.transactionHash),
            "transfer",
            senderAddress,
            DateTime.fromMillisecondsSinceEpoch(
                transaction.timestampSeconds.toInt() * 1000),
            incoming,
            false,
            tx.fee.toInt(),
            receiverAddress: receiverAddress,
            amount: tx.transfer.amounts[j].toInt(),
            message: message,
            messageType: MessageType.text));
      }
    }
  }

  TransactionData _convertMessage(TransactionExtended transaction) {
    Transaction tx = transaction.tx;
    MessageType messageType = MessageType.text;
    String? message;
    if (tx.message.messageHash.isNotEmpty) {
      try {
        message = utf8.decode(tx.message.messageHash);
      } on FormatException {
        message = StringUtil.fromBytes(tx.message.messageHash);
        messageType = MessageType.hex;
      }
    }
    return TransactionData(
        TransactionType.message,
        StringUtil.fromBytes(tx.transactionHash),
        "message",
        StringUtil.fromBytes(transaction.addrFrom),
        DateTime.fromMillisecondsSinceEpoch(
            transaction.timestampSeconds.toInt() * 1000),
        false,
        false,
        tx.fee.toInt(),
        message: message,
        messageType: messageType);
  }

  TransactionData _convertToken(TransactionExtended transaction) {
    Transaction tx = transaction.tx;
    Transaction_Token transactionToken = tx.token;
    return TransactionData(
        TransactionType.token,
        StringUtil.fromBytes(tx.transactionHash),
        "token",
        StringUtil.fromBytes(transaction.addrFrom),
        DateTime.fromMillisecondsSinceEpoch(
            transaction.timestampSeconds.toInt() * 1000),
        false,
        false,
        tx.fee.toInt(),
        tokenName: utf8.decode(transactionToken.name),
        tokenSymbol: utf8.decode(transactionToken.symbol),
        tokenDecimals: transactionToken.decimals.toInt(),
        tokenOwnerAddress: StringUtil.fromBytes(transactionToken.owner),
        initialTokenHolders: transactionToken.initialBalances
            .map((addressAmount) => InitialTokenHolder(
                StringUtil.fromBytes(addressAmount.address),
                BigInt.parse(addressAmount.amount.toStringUnsigned()).toInt()))
            .toList());
  }

  Future<void> _convertTransferToken(
      List<TransactionData> transactions,
      TransactionExtended transaction,
      String walletAddress,
      PublicAPIClient publicAPIClient) async {
    Transaction tx = transaction.tx;
    Transaction_TransferToken transactionTransferToken = tx.transferToken;

    GetObjectResp getObjectResp = await publicAPIClient
        .getObject(GetObjectReq(query: transactionTransferToken.tokenTxhash));
    Transaction_Token transactionToken = getObjectResp.transaction.tx.token;
    String tokenName = utf8.decode(transactionToken.name);
    String tokenSymbol = utf8.decode(transactionToken.symbol);
    int tokenDecimals = transactionToken.decimals.toInt();
    String tokenHash =
        StringUtil.fromBytes(transactionTransferToken.tokenTxhash);

    String senderAddress = StringUtil.fromBytes(transaction.addrFrom);
    bool incoming = senderAddress != walletAddress;
    for (int j = 0; j < transactionTransferToken.addrsTo.length; j++) {
      String receiverAddress =
          StringUtil.fromBytes(transactionTransferToken.addrsTo[j]);
      if (!incoming || receiverAddress == walletAddress) {
        transactions.add(TransactionData(
            TransactionType.transferToken,
            StringUtil.fromBytes(tx.transactionHash),
            "transferToken",
            senderAddress,
            DateTime.fromMillisecondsSinceEpoch(
                transaction.timestampSeconds.toInt() * 1000),
            incoming,
            false,
            tx.fee.toInt(),
            receiverAddress: receiverAddress,
            amount: BigInt.parse(
                    transactionTransferToken.amounts[j].toStringUnsigned())
                .toInt(),
            tokenName: tokenName,
            tokenSymbol: tokenSymbol,
            tokenDecimals: tokenDecimals,
            tokenHash: tokenHash));
      }
    }
  }

  Future<String> sendTransferTransaction(
      String senderWalletAddress,
      String xmssPk,
      List<int> amounts,
      List<List<int>> receiverWalletAddressesBytes,
      int otsIndex,
      int fee,
      String transactionData,
      List<int> messageBytes) async {
    List<Int64> int64Amounts = amounts.map((amount) => Int64(amount)).toList();
    Int64 int64Fee = Int64(fee);
    String signature =
        transactionData.substring(0, (transactionData.length - 64));
    List<int> txSignature = StringUtil.toBytes(signature);
    String hash = transactionData.substring(
        (transactionData.length - 64), transactionData.length);
    List<int> messageData = Uint8List.fromList(messageBytes);
    List<int> txHash = StringUtil.toBytes(hash);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      var transferCoinsReq = TransferCoinsReq(
          messageData: messageData,
          addressesTo: receiverWalletAddressesBytes,
          amounts: int64Amounts,
          fee: int64Fee,
          xmssPk: StringUtil.toBytes(xmssPk));
      TransferCoinsResp transferCoinsResp =
          await publicAPIClient.transferCoins(transferCoinsReq);
      await publicAPIClient.pushTransaction(PushTransactionReq(
          transactionSigned: Transaction(
              transfer:
                  transferCoinsResp.extendedTransactionUnsigned.tx.transfer,
              signature: txSignature,
              transactionHash: txHash,
              fee: int64Fee,
              publicKey:
                  transferCoinsResp.extendedTransactionUnsigned.tx.publicKey,
              nonce: Int64(12))));
      return hash;
    } finally {
      clientChannel.shutdown();
    }
  }

  Future<String> sendTransferTokenTransaction(
      String senderWalletAddress,
      String xmssPk,
      List<int> amounts,
      List<List<int>> receiverWalletAddressesBytes,
      int otsIndex,
      int fee,
      String transactionData,
      List<int> tokenTransactionHashBytes) async {
    List<Int64> int64Amounts = amounts.map((amount) => Int64(amount)).toList();
    Int64 int64Fee = Int64(fee);
    String signature =
        transactionData.substring(0, (transactionData.length - 64));
    List<int> txSignature = StringUtil.toBytes(signature);
    String hash = transactionData.substring(
        (transactionData.length - 64), transactionData.length);
    List<int> txHash = StringUtil.toBytes(hash);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      var transferTokenTxnReq = TransferTokenTxnReq(
          tokenTxhash: tokenTransactionHashBytes,
          addressesTo: receiverWalletAddressesBytes,
          amounts: int64Amounts,
          fee: int64Fee,
          xmssPk: StringUtil.toBytes(xmssPk));
      TransferCoinsResp transferCoinsResp =
          await publicAPIClient.getTransferTokenTxn(transferTokenTxnReq);
      await publicAPIClient.pushTransaction(PushTransactionReq(
          transactionSigned: Transaction(
              transferToken: transferCoinsResp
                  .extendedTransactionUnsigned.tx.transferToken,
              signature: txSignature,
              transactionHash: txHash,
              fee: int64Fee,
              publicKey:
                  transferCoinsResp.extendedTransactionUnsigned.tx.publicKey,
              nonce: Int64(12))));
      return hash;
    } finally {
      clientChannel.shutdown();
    }
  }

  Future<String> sendTokenTransaction(
      String senderWalletAddress,
      String xmssPk,
      List<int> symbolBytes,
      List<int> nameBytes,
      List<int> ownerBytes,
      int decimals,
      List<int> initialBalances,
      List<List<int>> receiverWalletAddressesBytes,
      int otsIndex,
      int fee,
      String transactionData) async {
    Int64 int64Decimals = Int64(decimals);
    List<AddressAmount> addressAmounts = [];
    for (int i = 0; i < receiverWalletAddressesBytes.length; i++) {
      addressAmounts.add(AddressAmount(
          address: receiverWalletAddressesBytes[i],
          amount: Int64(initialBalances[i])));
    }
    Int64 int64Fee = Int64(fee);
    String signature =
        transactionData.substring(0, (transactionData.length - 64));
    List<int> txSignature = StringUtil.toBytes(signature);
    String hash = transactionData.substring(
        (transactionData.length - 64), transactionData.length);
    List<int> txHash = StringUtil.toBytes(hash);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      var tokenTxnReq = TokenTxnReq(
          symbol: symbolBytes,
          name: nameBytes,
          owner: ownerBytes,
          decimals: int64Decimals,
          initialBalances: addressAmounts,
          fee: int64Fee,
          xmssPk: StringUtil.toBytes(xmssPk));
      TransferCoinsResp transferCoinsResp =
          await publicAPIClient.getTokenTxn(tokenTxnReq);
      await publicAPIClient.pushTransaction(PushTransactionReq(
          transactionSigned: Transaction(
              token: transferCoinsResp.extendedTransactionUnsigned.tx.token,
              signature: txSignature,
              transactionHash: txHash,
              fee: int64Fee,
              publicKey:
                  transferCoinsResp.extendedTransactionUnsigned.tx.publicKey,
              nonce: Int64(12))));
      return hash;
    } finally {
      clientChannel.shutdown();
    }
  }

  Future<String> sendMessageTransaction(
      String senderWalletAddress,
      String xmssPk,
      List<int> messageBytes,
      int otsIndex,
      int fee,
      String transactionData,
      {MessageType messageType = MessageType.text}) async {
    Int64 int64Fee = Int64(fee);
    String signature =
        transactionData.substring(0, (transactionData.length - 64));
    List<int> txSignature = StringUtil.toBytes(signature);
    String hash = transactionData.substring(
        (transactionData.length - 64), transactionData.length);
    List<int> messageData;
    if (messageType == MessageType.text) {
      messageData = Uint8List.fromList(messageBytes);
    } else {
      messageData = messageBytes;
    }
    List<int> txHash = StringUtil.toBytes(hash);
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      var transferCoinsReq = MessageTxnReq(
          message: messageData,
          fee: int64Fee,
          xmssPk: StringUtil.toBytes(xmssPk));
      TransferCoinsResp transferCoinsResp =
          await publicAPIClient.getMessageTxn(transferCoinsReq);
      await publicAPIClient.pushTransaction(PushTransactionReq(
          transactionSigned: Transaction(
              message: transferCoinsResp.extendedTransactionUnsigned.tx.message,
              signature: txSignature,
              transactionHash: txHash,
              fee: int64Fee,
              publicKey:
                  transferCoinsResp.extendedTransactionUnsigned.tx.publicKey,
              nonce: Int64(12))));
      return hash;
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
        if ("transfer" == tx.whichTransactionType().name.toLowerCase() ||
            "transferToken" == tx.whichTransactionType().name.toLowerCase()) {
          String senderAddress = StringUtil.fromBytes(transaction.addrFrom);
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

  Future<TransactionData?> findMessageTransaction(
      String transactionHash) async {
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      GetObjectResp getObjectResp = await publicAPIClient
          .getObject(GetObjectReq(query: StringUtil.toBytes(transactionHash)));
      TransactionExtended transaction = getObjectResp.transaction;
      if ("message" ==
          transaction.tx.whichTransactionType().name.toLowerCase()) {
        return _convertMessage(transaction);
      }
      return null;
    } finally {
      clientChannel.shutdown();
    }
  }

  Future<TransactionData?> findTokenTransaction(String transactionHash) async {
    ClientChannel clientChannel = await getClientChannel();
    try {
      PublicAPIClient publicAPIClient = PublicAPIClient(clientChannel);
      GetObjectResp getObjectResp = await publicAPIClient
          .getObject(GetObjectReq(query: StringUtil.toBytes(transactionHash)));
      TransactionExtended transaction = getObjectResp.transaction;
      if ("token" == transaction.tx.whichTransactionType().name.toLowerCase()) {
        return _convertToken(transaction);
      }
      return null;
    } finally {
      clientChannel.shutdown();
    }
  }
}
