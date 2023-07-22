import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/qrl_button.dart';
import 'package:mobile_wallet/ui/component/qrl_textfield.dart';
import 'package:mobile_wallet/ui/tools/notarization/verify/verify_notarization_bloc.dart';
import 'package:mobile_wallet/ui/util/component_util.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

import '../../../component/qrl_app_bar.dart';

class VerifyNotarizationPage extends StatelessWidget {
  const VerifyNotarizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyNotarizationBloc>(
        create: (_) => VerifyNotarizationBloc(),
        child: const _NotarizationView());
  }
}

class _NotarizationView extends StatelessWidget {
  const _NotarizationView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: CustomColors.qrlDarkBlueLinearGradient,
        image: DecorationImage(
          image: const AssetImage('assets/images/orange-dots-4.png'),
          alignment: Alignment.bottomCenter,
          colorFilter: ColorFilter.mode(
            CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: QrlTitleAppBar(titleText: AppLocalizations.of(context)!.verify),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: QrlTextFormField(
                    (value) => BlocProvider.of<VerifyNotarizationBloc>(context)
                        .add(TransactionHashChangedEvent(value)),
                    text: AppLocalizations.of(context)!.transactionHash,
                    autoFocus: true,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.only(left: 8, right: 14),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.search),
                      tooltip: AppLocalizations.of(context)!.search,
                      color: CustomColors.qrlYellowColor,
                      onPressed: () {
                        Util.dismissKeyboard(context);
                        BlocProvider.of<VerifyNotarizationBloc>(context)
                            .add(SearchEvent());
                      },
                    ),
                  ),
                ),
                _buildNotarizationBloc(),
              ]),
            ),
            _buildVerificationBloc(),
          ],
        ),
      ),
    );
  }

  BlocBuilder<VerifyNotarizationBloc, VerifyNotarizationState>
      _buildNotarizationBloc() {
    return BlocBuilder<VerifyNotarizationBloc, VerifyNotarizationState>(
      buildWhen: (previous, current) =>
          (previous.status != VerifyNotarizationStatus.notarizationNotFound &&
              current.status ==
                  VerifyNotarizationStatus.notarizationNotFound) ||
          (previous.status != VerifyNotarizationStatus.notarizationFound &&
              current.status == VerifyNotarizationStatus.notarizationFound) ||
          (previous.status != VerifyNotarizationStatus.searching &&
              current.status == VerifyNotarizationStatus.searching),
      builder: (context, state) {
        if (state.status == VerifyNotarizationStatus.searching) {
          return Padding(
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
                Text(AppLocalizations.of(context)!.searchingNotarization),
              ],
            ),
          );
        } else if (state.status ==
            VerifyNotarizationStatus.notarizationNotFound) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(AppLocalizations.of(context)!.notarizationNotFound),
          );
        } else if (state.status == VerifyNotarizationStatus.notarizationFound) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: ListView(
                children: [
                  ComponentUtil.buildLabelValueCard(
                      AppLocalizations.of(context)!.fromAddress,
                      "Q${state.notarizationMessage!.notary}"),
                  ComponentUtil.buildLabelValueCard(
                      AppLocalizations.of(context)!.hashFunction,
                      Util.notarizationHashFunctions[
                              state.notarizationMessage!.hashFunction] ??
                          ""),
                  ComponentUtil.buildLabelValueCard(
                      AppLocalizations.of(context)!.fileHash,
                      state.notarizationMessage!.fileHash),
                  if (state.notarizationMessage!.additionalMessage.isNotEmpty)
                    ComponentUtil.buildLabelValueCard(
                        AppLocalizations.of(context)!.message,
                        state.notarizationMessage!.additionalMessage),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 256,
                      child: QrlButton(
                        () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(withData: true);
                          if (result != null) {
                            BlocProvider.of<VerifyNotarizationBloc>(context)
                                .add(VerifyEvent(result));
                          }
                        },
                        text: AppLocalizations.of(context)!
                            .verifyDocument
                            .toUpperCase(),
                        baseColor: CustomColors.qrlYellowColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  BlocBuilder<VerifyNotarizationBloc, VerifyNotarizationState>
      _buildVerificationBloc() {
    return BlocBuilder<VerifyNotarizationBloc, VerifyNotarizationState>(
      buildWhen: (previous, current) =>
          (previous.status != VerifyNotarizationStatus.verifying &&
              current.status == VerifyNotarizationStatus.verifying) ||
          (previous.status != VerifyNotarizationStatus.verified &&
              current.status == VerifyNotarizationStatus.verified) ||
          (previous.status != VerifyNotarizationStatus.verifyFailed &&
              current.status == VerifyNotarizationStatus.verifyFailed),
      builder: (context, state) {
        Widget? widget;
        double height = MediaQuery.of(context).size.height -
            (MediaQuery.of(context).padding.top + kToolbarHeight);
        double childHeight = 120 / height;
        if (childHeight > 0.50) {
          childHeight = 0.50;
        }
        if (childHeight < 0.1) {
          childHeight = 0.1;
        }
        if (state.status == VerifyNotarizationStatus.verifying) {
          widget = Center(
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
                  Text(AppLocalizations.of(context)!.verifyingNotarization),
                ],
              ),
            ),
          );
        } else if (state.status == VerifyNotarizationStatus.verifyFailed) {
          widget = Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context)!.documentVerifyFailedTitle,
                  style: const TextStyle(
                    color: CustomColors.qrlYellowColor,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(AppLocalizations.of(context)!
                    .documentVerifyFailedBody(state.lastFileName ?? "")),
              ),
            ]),
          );
        } else if (state.status == VerifyNotarizationStatus.verified) {
          widget = Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context)!.documentVerifiedTitle,
                  style: const TextStyle(
                    color: CustomColors.qrlYellowColor,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(AppLocalizations.of(context)!
                    .documentVerifiedBody(state.lastFileName ?? "")),
              ),
            ]),
          );
        }
        if (widget != null && childHeight != null) {
          return DraggableScrollableSheet(
            key: Key(Random().nextInt(99999).toString()),
            initialChildSize: childHeight,
            minChildSize: 0,
            maxChildSize: childHeight,
            expand: true,
            snap: true,
            snapSizes: const [0],
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff163246),
                      CustomColors.qrlDarkBlueMaterial,
                    ],
                    stops: [0.1, 0.8],
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: widget,
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }
}
