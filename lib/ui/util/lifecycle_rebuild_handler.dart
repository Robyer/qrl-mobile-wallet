import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:mobile_wallet/service/authentication_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/service/settings_service.dart';
import 'package:mobile_wallet/ui/util/util.dart';
import 'package:secure_application/secure_application.dart';

class LifecycleRebuildHandler extends StatefulWidget {
  final Widget child;
  final SecureApplicationController secureApplicationController;

  const LifecycleRebuildHandler(
      {required this.child,
      required this.secureApplicationController,
      super.key});

  @override
  State<LifecycleRebuildHandler> createState() =>
      _LifecycleRebuildHandlerState();
}

class _LifecycleRebuildHandlerState extends State<LifecycleRebuildHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS && Util.safariOpen) {
        Util.safariOpen = false;
        widget.secureApplicationController.secure();
        var authenticationService = getIt<AuthenticationService>();
        await authenticationService.authenticate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
