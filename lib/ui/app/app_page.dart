import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_wallet/model/app_language.dart';
import 'package:mobile_wallet/service/authentication_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/addwallet/add_wallet_page.dart';
import 'package:mobile_wallet/ui/app/app_bloc.dart';
import 'package:mobile_wallet/ui/main/main_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:secure_application/secure_application.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
        create: (_) => AppBloc()..add(InitEvent()), child: _AppView());
  }
}

class _AppView extends StatelessWidget {
  final SecureApplicationController _secureApplicationController =
      SecureApplicationController(SecureApplicationState());

  _AppView();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _secureApplicationController.secure();
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) =>
          current.status == AppStatus.loading ||
          current.status == AppStatus.ready,
      builder: (context, state) {
        if (state.status != AppStatus.ready) {
          return const ColoredBox(
            color: CustomColors.qrlDarkBlueColor,
            child: SizedBox(
              child: Center(
                child: CircularProgressIndicator(
                  color: CustomColors.qrlYellowColor,
                ),
              ),
            ),
          );
        }
        return MaterialApp(
          locale: state.appSettings.appLanguage.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLanguage.availableLocales(),
          title: 'QRL Mobile Wallet',
          theme: ThemeData(
            canvasColor: Colors.transparent,
            appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(
                  color: Colors.white,
                ),
                color: Colors.transparent),
            textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                  fontFamily: "Roboto-Medium",
                ),
          ),
          initialRoute: state.walletCount == 0 ? "/add-wallet" : "/main",
          routes: {
            '/add-wallet': (context) => const AddWalletPage(),
            "/main": (context) => const MainPage(),
          },
          builder: (context, child) => SecureApplication(
            secureApplicationController: _secureApplicationController,
            onNeedUnlock: (secureApplicationController) async {
              if (secureApplicationController != null) {
                if (await getIt<AuthenticationService>().authenticate()) {
                  secureApplicationController.authSuccess(unlock: true);
                } else {
                  secureApplicationController.authFailed(unlock: false);
                }
              }
              return null;
            },
            child:
                SecureGate(blurr: 100, opacity: 0, child: child ?? Container()),
          ),
        );
      },
    );
  }
}
