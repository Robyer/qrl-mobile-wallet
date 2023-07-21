import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/component/scan_qr_page.dart';
import 'package:mobile_wallet/ui/addressbook/address_book_page.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_bloc.dart';
import 'package:mobile_wallet/ui/balance/transfer/add_transfer_event.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

class AddressField extends StatefulWidget {
  final int _index;
  final String? _initialValue;

  const AddressField(this._index, this._initialValue, {Key? key})
      : super(key: key);

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  late final TextEditingController _addressController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget._initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return QrlTextField(
      _addressController,
      (value) => BlocProvider.of<AddTransferBloc>(context)
          .add(AddressChangedEvent(value, widget._index)),
      text: AppLocalizations.of(context)!.walletAddress,
      focusNode: _focusNode,
      autoFocus: false,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.account_box),
            tooltip: AppLocalizations.of(context)!.openAddressBook,
            color: CustomColors.qrlYellowColor,
            onPressed: () {
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
              _openAddressBook();
            },
          ),
          IconButton(
            padding: const EdgeInsets.only(left: 8, right: 14),
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.qr_code),
            tooltip: AppLocalizations.of(context)!.scanAddress,
            color: CustomColors.qrlYellowColor,
            onPressed: () {
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
              _scanAddress();
            },
          ),
        ],
      ),
    );
  }

  void _openAddressBook() async {
    String? receiverWalletAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressBookPage()),
    );
    if (mounted &&
        receiverWalletAddress != null &&
        receiverWalletAddress.isNotEmpty) {
      BlocProvider.of<AddTransferBloc>(context)
          .add(AddressChangedEvent(receiverWalletAddress, widget._index));
      setState(() {
        _addressController.value =
            TextEditingValue(text: receiverWalletAddress);
        Util.dismissKeyboard(context);
      });
    }
  }

  void _scanAddress() async {
    String? scannedWalletAddress = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanQrPage()),
    );
    if (mounted &&
        scannedWalletAddress != null &&
        scannedWalletAddress.isNotEmpty) {
      BlocProvider.of<AddTransferBloc>(context)
          .add(AddressChangedEvent(scannedWalletAddress, widget._index));
      setState(() {
        _addressController.value = TextEditingValue(text: scannedWalletAddress);
        Util.dismissKeyboard(context);
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
