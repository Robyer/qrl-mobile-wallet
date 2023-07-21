import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_wallet/model/extended_wallet_data.dart';
import 'package:mobile_wallet/model/wallet.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Util {
  static final Map<String, String> notarizationHashFunctions = <String, String>{
    "2": "SHA256",
  };

  static Future<void> launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Text getOtsIndexText(
      Wallet wallet, ExtendedWalletData extendedWalletData) {
    int currentOtsIndex = extendedWalletData.otsIndex;
    int totalOtsKeys = _getOtsKeysForHeight(wallet.height);
    int otsKeysLeft = totalOtsKeys - currentOtsIndex;
    return Text(" $currentOtsIndex",
        style: TextStyle(
            color: otsKeysLeft < 16
                ? Colors.redAccent
                : CustomColors.qrlLightBlueColor));
  }

  static int getOtsKeysLeft(
      Wallet wallet, ExtendedWalletData extendedWalletData) {
    int currentOtsIndex = extendedWalletData.otsIndex;
    int totalOtsKeys = _getOtsKeysForHeight(wallet.height);
    return totalOtsKeys - currentOtsIndex;
  }

  static int _getOtsKeysForHeight(int height) {
    switch (height) {
      case 8:
        return 256;
      case 10:
        return 1024;
      case 12:
        return 4096;
      case 14:
        return 16384;
      case 16:
        return 262144;
    }
    return 0;
  }
}
