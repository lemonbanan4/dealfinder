import 'package:flutter/material.dart';

import 'legal_page.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Terms of Service',
      sections: [
        LegalSection(
          heading: 'Acceptance of Terms',
          body:
              'By downloading, installing, or using the PrisPuls application '
              '("Service"), you agree to be bound by these Terms of Service '
              '("Terms"). If you do not agree, please do not use the Service.\n\n'
              'These Terms constitute a legally binding agreement between you '
              'and PrisPuls AS ("PrisPuls", "we", "us").',
        ),
        LegalSection(
          heading: 'Affiliate Disclosure',
          isHighlighted: true,
          body:
              'PrisPuls participates in various affiliate marketing programs, '
              'which means we may get paid commissions on editorially chosen '
              'products purchased through our links to retailer sites.\n\n'
              'When you click an outbound product link and subsequently '
              'complete a purchase, PrisPuls may receive a referral commission '
              'from the relevant retailer. This commission is paid by the '
              'retailer and does not result in any additional charge to you.\n\n'
              'The existence of an affiliate relationship does not influence '
              'our editorial selections, deal rankings, or price data. '
              'PrisPuls is committed to displaying accurate, impartial pricing '
              'information for all users.',
        ),
        LegalSection(
          heading: 'Description of Service',
          body:
              'PrisPuls is a price-comparison and deal-aggregation platform. '
              'We collect publicly available pricing and product information '
              'from retailers and present it to users for informational '
              'purposes. We do not sell products directly and are not a party '
              'to any transaction between you and a retailer.',
        ),
        LegalSection(
          heading: 'Accuracy of Information',
          body:
              'We strive to keep pricing and availability information accurate '
              'and up to date. However, prices change frequently and we cannot '
              'guarantee that the information displayed is current or error-free '
              'at the moment you view it.\n\n'
              'PrisPuls is not responsible for discrepancies between prices '
              'shown in the app and prices displayed on a retailer\'s website '
              'or charged at checkout. Always verify the final price on the '
              'retailer\'s site before completing a purchase.',
        ),
        LegalSection(
          heading: 'User Accounts',
          body:
              'Certain features (such as price alerts) require you to create '
              'an account. You are responsible for maintaining the '
              'confidentiality of your credentials and for all activity that '
              'occurs under your account. Notify us immediately at '
              'support@prispuls.no if you suspect unauthorised access.',
        ),
        LegalSection(
          heading: 'Acceptable Use',
          body:
              'You agree not to:\n\n'
              '• Use the Service for any unlawful purpose or in violation of '
              'these Terms.\n'
              '• Attempt to gain unauthorised access to any part of the '
              'Service or its infrastructure.\n'
              '• Scrape, crawl, or otherwise systematically extract data from '
              'the Service without our prior written consent.\n'
              '• Transmit any malicious code, viruses, or disruptive '
              'programs.\n'
              '• Impersonate any person or entity or misrepresent your '
              'affiliation with any person or entity.',
        ),
        LegalSection(
          heading: 'Intellectual Property',
          body:
              'All content, design, software, and trademarks associated with '
              'PrisPuls are the exclusive property of PrisPuls AS or its '
              'licensors. You may not reproduce, distribute, or create '
              'derivative works without our express written permission.',
        ),
        LegalSection(
          heading: 'Third-Party Links & Retailers',
          body:
              'The Service contains links to third-party retailer websites. '
              'These links are provided for your convenience. PrisPuls has no '
              'control over, and assumes no responsibility for, the content, '
              'privacy practices, or availability of third-party sites. '
              'Visiting a retailer\'s website is at your own risk and subject '
              'to that retailer\'s own terms and privacy policy.',
        ),
        LegalSection(
          heading: 'Disclaimer of Warranties',
          body:
              'The Service is provided "as is" and "as available" without '
              'warranties of any kind, either express or implied. To the '
              'fullest extent permitted by applicable law, PrisPuls disclaims '
              'all warranties including implied warranties of merchantability, '
              'fitness for a particular purpose, and non-infringement.',
        ),
        LegalSection(
          heading: 'Limitation of Liability',
          body:
              'To the maximum extent permitted by law, PrisPuls shall not be '
              'liable for any indirect, incidental, special, consequential, or '
              'punitive damages arising out of or related to your use of the '
              'Service, even if we have been advised of the possibility of '
              'such damages.',
        ),
        LegalSection(
          heading: 'Governing Law',
          body:
              'These Terms are governed by and construed in accordance with '
              'the laws of Norway. Any dispute arising under these Terms shall '
              'be subject to the exclusive jurisdiction of the courts of Oslo, '
              'Norway, without regard to conflict-of-law provisions.',
        ),
        LegalSection(
          heading: 'Changes to Terms',
          body:
              'We reserve the right to modify these Terms at any time. '
              'Material changes will be communicated via in-app notification '
              'or email at least 14 days before taking effect. Continued use '
              'of the Service after the effective date constitutes acceptance '
              'of the revised Terms.',
        ),
        LegalSection(
          heading: 'Contact',
          body:
              'Questions about these Terms? Contact us:\n\n'
              'PrisPuls AS\n'
              'Email: legal@prispuls.no\n'
              'Website: www.prispuls.no',
        ),
      ],
    );
  }
}
