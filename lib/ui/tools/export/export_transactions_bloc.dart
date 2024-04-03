import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_wallet/model/transaction.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/transaction_service.dart';
import 'package:mobile_wallet/service/wallet_service.dart';
import 'package:mobile_wallet/util/string_util.dart';

part 'export_transactions_event.dart';
part 'export_transactions_state.dart';

class ExportTransactionsBloc
    extends Bloc<ExportTransactionsEvent, ExportTransactionsState> {
  static const int batchCount = 10;
  final WalletService _walletService;
  final TransactionService _transactionService;
  final List<String> headers = [
    "Date",
    "Type",
    "Sent/Received",
    "From address",
    "To address",
    "Amount",
    "Token",
    "Fee",
    "Transactionhash"
  ];
  final DateFormat formatter = DateFormat("HH:mm, MMM d yyyy");

  ExportTransactionsBloc()
      : _walletService = getIt<WalletService>(),
        _transactionService = getIt<TransactionService>(),
        super(const ExportTransactionsState()) {
    on<InitEvent>((event, emit) async {
      emit(state.copyWith(status: ExportTransactionsStatus.loadingWallets));
      List<Wallet> wallets = await _walletService.getWallets();
      int? currentWalletId = await _walletService.getCurrentWalletId();
      Wallet currentWallet = wallets.firstWhere(
          (wallet) => wallet.id == currentWalletId,
          orElse: () => wallets.first);
      DateTime now = DateTime.now();
      emit(state.copyWith(
        status: ExportTransactionsStatus.exportable,
        wallets: wallets,
        currentWallet: currentWallet,
        fromDate: DateTime(now.year, now.month, 1),
        toDate: DateTime(now.year, now.month + 1, 0),
      ));
    });

    on<WalletChangedEvent>((event, emit) async {
      Wallet currentWallet = event.wallet;
      emit(state.copyWith(
          status: ExportTransactionsStatus.exportable,
          currentWallet: currentWallet));
    });

    on<FromDateChangedEvent>((event, emit) async {
      emit(state.copyWith(fromDate: event.value));
    });

    on<ToDateChangedEvent>((event, emit) async {
      emit(state.copyWith(toDate: event.value));
    });

    on<ExportEvent>((event, emit) async {
      emit(state.copyWith(status: ExportTransactionsStatus.exporting));
      try {
        String csvData = const ListToCsvConverter().convert(await getCsvData());
        String? fileLocation = await FileSaver.instance.saveAs(
            name:
                'export-${state.currentWallet?.name}-${DateTime.now().millisecondsSinceEpoch.toString()}',
            bytes: Uint8List.fromList(utf8.encode(csvData)),
            ext: 'csv',
            mimeType: MimeType.csv);
        emit(state.copyWith(
            status: ExportTransactionsStatus.exportComplete,
            fileLocation: fileLocation));
      } on Exception catch (e, stacktrace) {
        var errorMessage = e.toString();
        log(errorMessage, stackTrace: stacktrace);
        emit(state.copyWith(
            status: ExportTransactionsStatus.error,
            errorMessage: errorMessage));
      }
      emit(state.copyWith(status: ExportTransactionsStatus.exportable));
    });
  }

  Future<List<List<String>>> getCsvData() async {
    List<List<String>> headerAndDataList = [];
    headerAndDataList.add(headers);
    bool keepGoing = true;
    int skip = 0;
    while (keepGoing) {
      List<TransactionData> transactions = await _transactionService
          .findTransactions(state.currentWallet!.address, batchCount,
              skip: skip, fromDate: state.fromDate, toDate: state.toDate);
      for (var transaction in transactions) {
        TransactionType type = transaction.transactionType;
        String amount;
        String token;
        if (type == TransactionType.transferToken) {
          amount = StringUtil.formatAmount(transaction.amount ?? 0,
              decimals: transaction.tokenDecimals ?? 0);
          token = transaction.tokenSymbol ?? "";
        } else {
          amount = StringUtil.formatAmount(transaction.amount ?? 0);
          token = "QRL";
        }
        headerAndDataList.add([
          formatter.format(transaction.dateTime),
          transaction.type.toUpperCase(),
          transaction.incoming ? "RECEIVED" : "SENT",
          "Q${transaction.senderAddress}",
          transaction.receiverAddress != null
              ? "Q${transaction.receiverAddress}"
              : "",
          amount,
          token,
          StringUtil.formatAmount(transaction.fee),
          transaction.hash,
        ]);
      }
      if (transactions.length != batchCount) {
        keepGoing = false;
      } else {
        skip += batchCount;
      }
    }
    return headerAndDataList;
  }
}
