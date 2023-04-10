import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/model/app_language.dart';
import 'package:mobile_wallet/ui/app/app_bloc.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select.dart';
import 'package:mobile_wallet/ui/component/dialogs.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/component/snack_bars.dart';
import 'package:mobile_wallet/ui/settings/bloc/settings_bloc.dart';
import 'package:mobile_wallet/ui/settings/community_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
        create: (_) => SettingsBloc()..add(InitSettingsEvent()),
        child: const _SettingsView());
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          current.status == SettingsStatus.saving ||
          current.status == SettingsStatus.noAuthenticationFound ||
          current.status == SettingsStatus.authenticationFailed ||
          current.status == SettingsStatus.permissionNotGranted ||
          current.status == SettingsStatus.saved,
      listener: (context, state) async {
        switch (state.status) {
          case SettingsStatus.saving:
            Dialogs.showLoadingDialog(
                context, AppLocalizations.of(context)!.savingSettings);
            break;
          case SettingsStatus.noAuthenticationFound:
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.noAuthenticationFound);
            break;
          case SettingsStatus.authenticationFailed:
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.authenticationFailed);
            break;
          case SettingsStatus.permissionNotGranted:
            SnackBars.showSnackBar(
                context, AppLocalizations.of(context)!.permissionNotGranted);
            break;
          case SettingsStatus.saved:
            Dialogs.hideLoadingDialog(context);
            BlocProvider.of<AppBloc>(context).add(SettingsUpdatedEvent());
            SnackBars.showSnackBar(
                context,
                (await AppLocalizations.delegate.load(state.appLanguage.locale))
                    .settingsSaved);
            break;
        }
      },
      buildWhen: (previous, current) => current.status == SettingsStatus.ready,
      builder: (context, state) {
        if (state.status == SettingsStatus.ready) {
          return _buildWidget(context);
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(AppLocalizations.of(context)!.loadingSettings),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Column _buildWidget(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(AppLocalizations.of(context)!.settings,
              style: const TextStyle(
                color: CustomColors.qrlLightBlueColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUseDeviceLoginBuilder(),
                _buildUseTransactionNotificationBuilder(),
                _buildUsePriceNotificationBuilder(),
                _buildAppLanguageBuilder(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(AppLocalizations.of(context)!.warning,
                        style: const TextStyle(
                          color: CustomColors.qrlLightBlueColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                  ),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    AppLocalizations.of(context)!.deviatingDefault,
                    textAlign: TextAlign.center,
                  ),
                )),
                _buildNodeUrlBuilder(),
                _buildPortBuilder(),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 256,
              child: QrlButton(
                () {
                  Util.dismissKeyboard(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityPage()),
                  );
                },
                text: AppLocalizations.of(context)!.join,
                baseColor: CustomColors.qrlLightBlueColor,
              ),
            ),
            _buildConfirmBuilder(),
          ],
        ),
      ],
    );
  }

  BlocBuilder<SettingsBloc, SettingsState> _buildUseDeviceLoginBuilder() {
    return BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            current.status == SettingsStatus.ready ||
            current.status == SettingsStatus.useDeviceLoginChanged,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 8),
            child: SwitchListTile(
                activeColor: CustomColors.qrlLightBlueColor,
                title: Text(AppLocalizations.of(context)!.useDeviceLogin),
                onChanged: (value) {
                  Util.dismissKeyboard(context);
                  BlocProvider.of<SettingsBloc>(context)
                      .add(UseDeviceLoginChanged(value));
                },
                value: state.useDeviceLogin),
          );
        });
  }

  BlocBuilder<SettingsBloc, SettingsState>
      _buildUseTransactionNotificationBuilder() {
    return BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            current.status == SettingsStatus.ready ||
            current.status == SettingsStatus.useTransactionNotificationChanged,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: SwitchListTile(
                activeColor: CustomColors.qrlLightBlueColor,
                title: Text(
                    AppLocalizations.of(context)!.useTransactionNotification),
                onChanged: (value) => BlocProvider.of<SettingsBloc>(context)
                    .add(UseTransactionNotificationChanged(value)),
                value: state.useTransactionNotification),
          );
        });
  }

  BlocBuilder<SettingsBloc, SettingsState> _buildUsePriceNotificationBuilder() {
    return BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            current.status == SettingsStatus.ready ||
            current.status == SettingsStatus.usePriceNotificationChanged,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16, right: 8),
            child: SwitchListTile(
                activeColor: CustomColors.qrlLightBlueColor,
                title: Text(AppLocalizations.of(context)!.usePriceNotification),
                onChanged: (value) => BlocProvider.of<SettingsBloc>(context)
                    .add(UsePriceNotificationChanged(value)),
                value: state.usePriceNotification),
          );
        });
  }

  BlocBuilder<SettingsBloc, SettingsState> _buildAppLanguageBuilder() {
    return BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            current.status == SettingsStatus.ready ||
            current.status == SettingsStatus.appLanguageChanged,
        builder: (context, state) {
          return BottomSheetSelect<AppLanguage>(
            selectedItem: state.appLanguage,
            items: AppLanguage.values,
            floatingLabelValue: AppLocalizations.of(context)!.language,
            valueChanged: (AppLanguage? value) {
              if (value != null) {
                BlocProvider.of<SettingsBloc>(context)
                    .add(AppLanguageChanged(value));
              }
            },
            labelConverter: (value) {
              return value.displayName;
            },
            itemConverter: (value) {
              return value.displayName;
            },
          );
        });
  }

  BlocBuilder<SettingsBloc, SettingsState> _buildNodeUrlBuilder() {
    return BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            current.status == SettingsStatus.ready,
        builder: (context, state) {
          return Padding(
            padding:
                const EdgeInsets.only(top: 16, bottom: 8, left: 32, right: 32),
            child: QrlTextFormField(
              (value) => BlocProvider.of<SettingsBloc>(context)
                  .add(NodeUrlChanged(value)),
              initialValue: state.nodeUrl,
              text: AppLocalizations.of(context)!.nodeUrl,
            ),
          );
        });
  }

  BlocBuilder<SettingsBloc, SettingsState> _buildPortBuilder() {
    return BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            current.status == SettingsStatus.ready,
        builder: (context, state) {
          return Padding(
            padding:
                const EdgeInsets.only(top: 8, bottom: 16, left: 32, right: 32),
            child: QrlTextFormField(
              (value) => BlocProvider.of<SettingsBloc>(context)
                  .add(PortChanged(value.isNotEmpty ? int.parse(value) : 0)),
              initialValue: state.port.toString(),
              text: AppLocalizations.of(context)!.port,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
            ),
          );
        });
  }

  BlocBuilder<SettingsBloc, SettingsState> _buildConfirmBuilder() {
    return BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) =>
            current.status == SettingsStatus.noChanges ||
            current.status == SettingsStatus.dirty,
        builder: (context, state) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: 256,
                child: QrlButton(
                  state.status == SettingsStatus.dirty
                      ? () {
                          Util.dismissKeyboard(context);
                          BlocProvider.of<SettingsBloc>(context)
                              .add(SaveEvent());
                        }
                      : null,
                  text: AppLocalizations.of(context)!.confirm,
                  baseColor: CustomColors.qrlLightBlueColor,
                ),
              ),
            ),
          );
        });
  }
}
