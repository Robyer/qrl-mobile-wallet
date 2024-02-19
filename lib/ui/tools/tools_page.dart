import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/component/qrl_app_bar.dart';
import 'package:mobile_wallet/ui/tools/export/export_transactions_page.dart';
import 'package:mobile_wallet/ui/tools/message/add_message_page.dart';
import 'package:mobile_wallet/ui/tools/notarization/add/add_notarization_page.dart';
import 'package:mobile_wallet/ui/tools/notarization/verify/verify_notarization_page.dart';
import 'package:mobile_wallet/ui/tools/token/create/create_token_page.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: CustomColors.qrlDarkBlueLinearGradient,
          image: DecorationImage(
            image: const AssetImage('assets/images/orange-dots-1.png'),
            alignment: Alignment.bottomCenter,
            colorFilter: ColorFilter.mode(
              CustomColors.qrlDarkBlueMaterial.withOpacity(0.15),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Scaffold(
          appBar:
              QrlTitleAppBar(titleText: AppLocalizations.of(context)!.tools),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _buildCard(
                    context,
                    AppLocalizations.of(context)!.sendMessageToolsTitle,
                    AppLocalizations.of(context)!.sendMessageToolsBody,
                    Icons.message_outlined,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddMessagePage()))),
                _buildCard(
                    context,
                    AppLocalizations.of(context)!.notarizeDocumentToolsTitle,
                    AppLocalizations.of(context)!.notarizeDocumentToolsBody,
                    Icons.note_add_outlined,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AddNotarizationPage()))),
                _buildCard(
                    context,
                    AppLocalizations.of(context)!.verifyDocumentToolsTitle,
                    AppLocalizations.of(context)!.verifyDocumentToolsBody,
                    Icons.task_outlined,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const VerifyNotarizationPage()))),
                _buildCard(
                    context,
                    AppLocalizations.of(context)!.exportToolsTitle,
                    AppLocalizations.of(context)!.exportToolsBody,
                    Icons.file_download,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ExportTransactionsPage()))),
                _buildCard(
                    context,
                    AppLocalizations.of(context)!.createTokenToolsTitle,
                    AppLocalizations.of(context)!.createTokenToolsBody,
                    Icons.token_outlined,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateTokenPage()))),
              ],
            ),
          ),
        ));
  }

  Card _buildCard(BuildContext context, String title, String subTitle,
      IconData iconData, Function() onTap) {
    return Card(
      elevation: 1,
      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          horizontalTitleGap: 10,
          leading: SizedBox(
            height: double.infinity,
            child: Icon(
              iconData,
              color: CustomColors.qrlYellowColor,
              size: 28,
            ),
          ),
          title: Text(title,
              style: const TextStyle(
                color: CustomColors.qrlLightBlueColor,
              )),
          subtitle: Text(
            subTitle,
          ),
          dense: true,
          onTap: onTap,
        ),
      ),
    );
  }
}
