import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/addwallet/bloc/add_wallet_bloc.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/component/scan_qr_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

class HexSeedField extends StatefulWidget {
  const HexSeedField({Key? key}) : super(key: key);

  @override
  State<HexSeedField> createState() => _HexSeedFieldState();
}

class _HexSeedFieldState extends State<HexSeedField> {
  final TextEditingController _hexSeedController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return QrlTextField(
      _hexSeedController,
      (value) => BlocProvider.of<AddWalletBloc>(context)
          .add(HexSeedChangedEvent(value)),
      text: AppLocalizations.of(context)!.hexseed,
      focusNode: _focusNode,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      suffixIcon: IconButton(
        icon: const Icon(Icons.qr_code),
        tooltip: AppLocalizations.of(context)!.scanHexseed,
        color: CustomColors.qrlYellowColor,
        onPressed: () {
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
          _scanHexSeed();
        },
      ),
    );
  }

  void _scanHexSeed() async {
    String? scannedHexSeed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanQrPage()),
    );
    if (mounted && scannedHexSeed != null && scannedHexSeed.isNotEmpty) {
      setState(() {
        _hexSeedController.value = TextEditingValue(text: scannedHexSeed);
        Util.dismissKeyboard(context);
      });
    }
  }

  @override
  void dispose() {
    _hexSeedController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
