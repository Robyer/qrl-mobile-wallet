import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/balance/balance_page.dart';
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
        body: _widgetOptions.elementAt(index),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff163246),
                CustomColors.qrlDarkBlueMaterial,
              ],
              stops: [0.3, 1],
            ),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.account_balance_wallet,
                  size: 22,
                ),
                label: AppLocalizations.of(context)!.balance,
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.wallet,
                  size: 22,
                ),
                label: AppLocalizations.of(context)!.wallets,
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.settings,
                  size: 22,
                ),
                label: AppLocalizations.of(context)!.settings,
              ),
            ],
            currentIndex: index,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: CustomColors.qrlYellowColor,
            unselectedItemColor: Colors.grey,
            onTap: BlocProvider.of<MainCubit>(context).updateSelectedIndex,
          ),
        ),
      );
    });
  }
}
