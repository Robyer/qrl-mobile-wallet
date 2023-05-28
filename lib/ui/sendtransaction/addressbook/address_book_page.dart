import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/address_book_entry.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mobile_wallet/service/service_locator.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/middle_ellipsis_text.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/sendtransaction/addressbook/changeaddressname/change_address_name_bloc.dart';
import 'package:mobile_wallet/ui/sendtransaction/addressbook/changeaddressname/change_address_name_view.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({Key? key}) : super(key: key);

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  List<AddressBookEntry>? _addressBook;
  int? _currentSelectedIndex;

  @override
  void initState() {
    super.initState();
    _init();
  }

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
              titleText: AppLocalizations.of(context)!.addressBook),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: _addressBook == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: CustomColors.qrlYellowColor,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(AppLocalizations.of(context)!
                                  .loadingAddresses),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount:
                            _addressBook != null ? _addressBook?.length : 0,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            color: (_currentSelectedIndex != null &&
                                    _currentSelectedIndex == index)
                                ? CustomColors.qrlLightBlueColor
                                    .withOpacity(0.1)
                                : null,
                            child: InkWell(
                              onTap: () => {
                                if (mounted)
                                  {
                                    setState(() {
                                      _currentSelectedIndex = index;
                                    })
                                  }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 32, right: 16, top: 8, bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: Text(
                                              "${_addressBook?[index].name}",
                                              style: const TextStyle(
                                                  color: CustomColors
                                                      .qrlLightBlueColor,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          MiddleEllipsisText(
                                            "Q${_addressBook?[index].address}",
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[500],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                        child: const Padding(
                                          padding: EdgeInsets.only(
                                              left: 4, right: 4),
                                          child: Icon(
                                              color:
                                                  CustomColors.qrlYellowColor,
                                              Icons.edit),
                                        ),
                                        onTap: () => _showUpdateWalletName(
                                            context, _addressBook![index])),
                                    InkWell(
                                        child: const Padding(
                                          padding: EdgeInsets.only(left: 4),
                                          child: Icon(
                                              color:
                                                  CustomColors.qrlYellowColor,
                                              Icons.delete_outline_sharp),
                                        ),
                                        onTap: () => _onPressedDelete(index)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 16),
                  child: SizedBox(
                    width: 256,
                    child: QrlButton(
                      _currentSelectedIndex != null
                          ? () => Navigator.of(context).pop(
                              _addressBook![_currentSelectedIndex!].address)
                          : null,
                      text: AppLocalizations.of(context)!.confirm,
                      baseColor: CustomColors.qrlLightBlueColor,
                      backgroundColor: CustomColors.qrlLightBlueColorBackground,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  _init() async {
    AddressBookService addressBookService = getIt<AddressBookService>();
    List<AddressBookEntry> addressBook =
        await addressBookService.getAddressBook();
    if (mounted) {
      setState(() {
        _addressBook = addressBook;
      });
    }
  }

  _showUpdateWalletName(
      BuildContext context, AddressBookEntry addressBookEntry) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return BlocProvider<ChangeAddressNameBloc>(
              create: (_) => ChangeAddressNameBloc(addressBookEntry),
              child:
                  BlocListener<ChangeAddressNameBloc, ChangeAddressNameState>(
                      listenWhen: (previous, current) =>
                          current.status == ChangeAddressNameStatus.nameSaved,
                      listener: (context, state) {
                        if (state.status == ChangeAddressNameStatus.nameSaved) {
                          _init();
                          Navigator.of(context).pop();
                        }
                      },
                      child: ChangeAddressNameView(addressBookEntry.name)));
        });
  }

  void _onPressedDelete(int index) async {
    Dialogs.showConfirmDialog(
        context, AppLocalizations.of(context)!.confirmRemoveAddress, () async {
      if (mounted) {
        Dialogs.showLoadingDialog(
            context, AppLocalizations.of(context)!.deletingAddress);
      }
      _addressBook!.removeAt(index);
      AddressBookService addressBookService = getIt<AddressBookService>();
      await addressBookService.saveAddressBook(_addressBook!);
      if (mounted) {
        _init();
        Dialogs.hideLoadingDialog(context);
      }
    });
  }
}
