import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'legal_page.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LegalPage(
      title: l10n.footerAboutUs,
      sections: [
        LegalSection(heading: l10n.aboutWhoWeAreHeading, body: l10n.aboutWhoWeAreBody),
        LegalSection(heading: l10n.aboutMissionHeading, body: l10n.aboutMissionBody),
        LegalSection(
          heading: l10n.footerAffiliateDisclosure,
          isHighlighted: true,
          body: l10n.aboutAffiliateBody,
        ),
        LegalSection(heading: l10n.aboutTeamHeading, body: l10n.aboutTeamBody),
        LegalSection(heading: l10n.footerContactUs, body: l10n.aboutContactBody),
      ],
    );
  }
}
