import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/service/authentication_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/app/app_page.dart';
import 'package:mobile_wallet/ui/util/app_main_bloc_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppMainBlocObserver();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  setupServiceLocator(sharedPreferences);
  if (!await getIt<AuthenticationService>().authenticate()) {
    exit(0);
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const AppPage()));
}
