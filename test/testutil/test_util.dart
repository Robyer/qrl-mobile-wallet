import 'package:flutter/material.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> mockStartApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({
    "test-1": "value-1",
    "test-2": 10,
  });
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  setupServiceLocator(sharedPreferences);
}
