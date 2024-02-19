import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/tools/export/export_transactions_bloc.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class ExportTransactionsPage extends StatelessWidget {
  const ExportTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExportTransactionsBloc>(
      create: (_) =>
      ExportTransactionsBloc()
        ..add(InitEvent()),
      child: _ExportTransactionsView(),
    );
  }
}

class _ExportTransactionsView extends StatelessWidget {
  const _ExportTransactionsView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-2.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        appBar: QrlTitleAppBar(
          titleText: 'Export Transactions',
        ),
        body: Text("."),
      ),
    );
  }
}
