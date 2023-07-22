import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_wallet/ui/util/util.dart';

class CommunityList extends StatelessWidget {
  final ScrollController? controller;

  const CommunityList(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NotificationListener(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          controller: controller,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: InkWell(
                onTap: () async {
                  Uri url = Uri.parse("https://www.theqrl.org");
                  await Util.launchInBrowser(url);
                },
                child: Container(
                  decoration: _buildBoxDecoration(
                      'assets/images/security-background.png'),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppLocalizations.of(context)!.securityCardHeader,
                            style: const TextStyle(
                                color: CustomColors.qrlLightBlueColor,
                                fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                            AppLocalizations.of(context)!.securityCardBody,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(colors: [
                                CustomColors.qrlYellowColor,
                                CustomColors.qrlYellowColor.withOpacity(0.1),
                              ], radius: 7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: SizedBox(
                              width: 144,
                              height: 24,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.learnMore,
                                  style: const TextStyle(
                                      color: CustomColors.qrlDarkBlueColor,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: InkWell(
                onTap: () async {
                  Uri url = Uri.parse("https://twitter.com/qrledger");
                  await Util.launchInBrowser(url);
                },
                child: Container(
                  decoration: _buildBoxDecoration(
                      'assets/images/twitter-background.png'),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppLocalizations.of(context)!.twitterCardHeader,
                            style: const TextStyle(
                                color: CustomColors.qrlYellowColor,
                                fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                            textAlign: TextAlign.start,
                            AppLocalizations.of(context)!.twitterCardBody,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(colors: [
                                CustomColors.qrlLightBlueColor,
                                CustomColors.qrlLightBlueColor.withOpacity(0.1),
                              ], radius: 7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: SizedBox(
                              width: 144,
                              height: 24,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .twitterCardButton,
                                  style: const TextStyle(
                                      color: CustomColors.qrlDarkBlueColor,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: InkWell(
                onTap: () async {
                  Uri url =
                      Uri.parse("https://qrl.volt-mine.com/getting-started");
                  await Util.launchInBrowser(url);
                },
                child: Container(
                  decoration: _buildBoxDecoration(
                      'assets/images/blocks-background.png'),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppLocalizations.of(context)!.miningCardHeader,
                            style: const TextStyle(
                                color: CustomColors.qrlLightBlueColor,
                                fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                            AppLocalizations.of(context)!.miningCardBody,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(colors: [
                                    CustomColors.qrlYellowColor,
                                    CustomColors.qrlYellowColor
                                        .withOpacity(0.1),
                                  ], radius: 7),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: SizedBox(
                                  width: 144,
                                  height: 24,
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .miningCardButton,
                                      style: const TextStyle(
                                          color: CustomColors.qrlDarkBlueColor,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: InkWell(
                onTap: () async {
                  Uri url = Uri.parse(
                      "https://www.youtube.com/c/QRLedger?app=mobile");
                  await Util.launchInBrowser(url);
                },
                child: Container(
                  decoration:
                      _buildBoxDecoration('assets/images/atom-background.png'),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "THE",
                              style: TextStyle(
                                  color: CustomColors.qrlLightBlueColor,
                                  fontSize: 18),
                            ),
                            Image.asset(
                              'assets/images/qrl-logo.png',
                              fit: BoxFit.contain,
                              height: 56,
                            ),
                            const Text(
                              "SHOW",
                              style: TextStyle(
                                  color: CustomColors.qrlLightBlueColor,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                textAlign: TextAlign.end,
                                AppLocalizations.of(context)!.youtubeCardBody,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(colors: [
                                CustomColors.qrlLightBlueColor,
                                CustomColors.qrlLightBlueColor.withOpacity(0.1),
                              ], radius: 7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: SizedBox(
                              width: 144,
                              height: 24,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .youtubeCardButton,
                                  style: const TextStyle(
                                      color: CustomColors.qrlDarkBlueColor,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: InkWell(
                onTap: () async {
                  Uri url = Uri.parse("https://theqrc.com/");
                  await Util.launchInBrowser(url);
                },
                child: Container(
                  decoration:
                      _buildBoxDecoration('assets/images/lock-background.png'),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppLocalizations.of(context)!.qrcCardHeader,
                            style: const TextStyle(
                                color: CustomColors.qrlLightBlueColor,
                                fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Text(
                            AppLocalizations.of(context)!.qrcCardBody,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(colors: [
                                    CustomColors.qrlYellowColor,
                                    CustomColors.qrlYellowColor
                                        .withOpacity(0.1),
                                  ], radius: 7),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                child: SizedBox(
                                  width: 144,
                                  height: 24,
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.learnMore,
                                      style: const TextStyle(
                                          color: CustomColors.qrlDarkBlueColor,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: InkWell(
                onTap: () async {
                  Uri url = Uri.parse("https://youtu.be/auDAg8uW1wY");
                  await Util.launchInBrowser(url);
                },
                child: Container(
                  decoration: _buildBoxDecoration(
                      'assets/images/notarization-background.png'),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppLocalizations.of(context)!
                                .notarizationCardHeader,
                            style: const TextStyle(
                                color: CustomColors.qrlYellowColor,
                                fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Text(
                            AppLocalizations.of(context)!.notarizationCardBody,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(colors: [
                                CustomColors.qrlLightBlueColor,
                                CustomColors.qrlLightBlueColor.withOpacity(0.1),
                              ], radius: 7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: SizedBox(
                              width: 144,
                              height: 24,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.learnMore,
                                  style: const TextStyle(
                                      color: CustomColors.qrlDarkBlueColor,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 16),
              child: Container(
                decoration:
                    _buildBoxDecoration('assets/images/globe-background.png'),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          AppLocalizations.of(context)!.communityCardHeader,
                          style: const TextStyle(
                            color: CustomColors.qrlYellowColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Text(
                          AppLocalizations.of(context)!.communityCardBody,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: InkWell(
                          onTap: () async {
                            Uri url = Uri.parse("https://www.theqrl.org");
                            await Util.launchInBrowser(url);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  const FaIcon(FontAwesomeIcons.globe).icon!,
                                  color: CustomColors.qrlYellowColor,
                                  size: 18,
                                ),
                              ),
                              const Text("www.theqrl.org"),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: InkWell(
                          onTap: () async {
                            Uri url = Uri.parse("https://www.qrl.foundation");
                            await Util.launchInBrowser(url);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  const FaIcon(FontAwesomeIcons.globe).icon!,
                                  color: CustomColors.qrlYellowColor,
                                  size: 18,
                                ),
                              ),
                              const Text("www.qrl.foundation"),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildIconCard("Twitter", FontAwesomeIcons.twitter,
                                "https://twitter.com/qrledger"),
                            _buildIconCard("GitHub", FontAwesomeIcons.github,
                                "https://github.com/theQRL/QRL"),
                            _buildIconCard("YouTube", FontAwesomeIcons.youtube,
                                "https://www.youtube.com/c/QRLedger?app=mobile"),
                            _buildIconCard("Discord", FontAwesomeIcons.discord,
                                "https://discord.com/invite/fVrEKDS6bh"),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildIconCard("Telegram", FontAwesomeIcons.telegram,
                              "https://t.me/QRLedgerOfficial"),
                          _buildIconCard("LinkedIN", FontAwesomeIcons.linkedin,
                              "https://www.linkedin.com/company/the-quantum-resistant-ledger/"),
                          _buildIconCard("Facebook", FontAwesomeIcons.facebook,
                              "https://www.facebook.com/theqrl/"),
                          _buildIconCard("Reddit", FontAwesomeIcons.reddit,
                              "https://www.reddit.com/r/qrl"),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child:
                            Text(AppLocalizations.of(context)!.generalEnquiries,
                                style: const TextStyle(
                                  color: CustomColors.qrlYellowColor,
                                )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () async {
                            Uri url = Uri.parse("mailto:info@theqrl.org");
                            await Util.launchInBrowser(url);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  const FaIcon(FontAwesomeIcons.envelope).icon!,
                                  color: CustomColors.qrlLightBlueColor,
                                  size: 18,
                                ),
                              ),
                              const Text("info@theqrl.org"),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child:
                            Text(AppLocalizations.of(context)!.supportRequest,
                                style: const TextStyle(
                                  color: CustomColors.qrlYellowColor,
                                )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () async {
                            Uri url = Uri.parse("mailto:support@theqrl.org");
                            await Util.launchInBrowser(url);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  const FaIcon(FontAwesomeIcons.envelope).icon!,
                                  color: CustomColors.qrlLightBlueColor,
                                  size: 18,
                                ),
                              ),
                              const Text("support@theqrl.org"),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child:
                            Text(AppLocalizations.of(context)!.pressEnquiries,
                                style: const TextStyle(
                                  color: CustomColors.qrlYellowColor,
                                )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: InkWell(
                          onTap: () async {
                            Uri url = Uri.parse("mailto:press@theqrl.org");
                            await Util.launchInBrowser(url);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  const FaIcon(FontAwesomeIcons.envelope).icon!,
                                  color: CustomColors.qrlLightBlueColor,
                                  size: 18,
                                ),
                              ),
                              const Text("press@theqrl.org"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _buildIconCard(String toolTip, IconData iconData, String url) {
    return Card(
      color: CustomColors.qrlLightBlueColor.withOpacity(0.1),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(FaIcon(iconData).icon!),
          tooltip: toolTip,
          color: Colors.white,
          iconSize: 32,
          onPressed: () async {
            Uri uri = Uri.parse(url);
            await Util.launchInBrowser(uri);
          },
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(String image) {
    return BoxDecoration(
      boxShadow: const [
        BoxShadow(
            color: CustomColors.qrlLightBlueColor,
            blurStyle: BlurStyle.outer,
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2)),
      ],
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      image: DecorationImage(
        alignment: Alignment.topCenter,
        image: AssetImage(image),
        fit: BoxFit.cover,
      ),
    );
  }
}
