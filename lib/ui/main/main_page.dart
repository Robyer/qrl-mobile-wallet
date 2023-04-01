import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/balance/balance_page.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/main/main_cubit.dart';
import 'package:mobile_wallet/ui/settings/settings_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/wallets/wallets_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainCubit>(
        create: (_) => MainCubit(), child: const _MainView());
  }
}

class _MainView extends StatelessWidget {
  const _MainView({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    BalancePage(),
    WalletsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, int>(builder: (context, index) {
      return Scaffold(
        appBar: QrlAppBar(),
        body: _widgetOptions.elementAt(index),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet),
              label: AppLocalizations.of(context)!.balance,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.wallet),
              label: AppLocalizations.of(context)!.wallets,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocalizations.of(context)!.settings,
            ),
          ],
          currentIndex: index,
          selectedItemColor: CustomColors.qrlDarkBlueColor,
          backgroundColor: CustomColors.qrlYellowColor,
          onTap: BlocProvider.of<MainCubit>(context).updateSelectedIndex,
        ),
      );
    });
  }
}
