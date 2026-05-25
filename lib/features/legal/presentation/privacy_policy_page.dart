import 'package:flutter/material.dart';

import 'legal_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Privacy Policy',
      sections: [
        LegalSection(
          heading: 'Overview',
          body:
              'PrisPuls ("we", "us", or "our") is committed to protecting your '
              'personal data and respecting your privacy. This Privacy Policy '
              'explains how we collect, use, store, and share information when '
              'you use the PrisPuls application and website.\n\n'
              'This policy is effective as of 1 January 2025 and applies to '
              'all users in the European Economic Area (EEA) and beyond.',
        ),
        LegalSection(
          heading: 'GDPR Compliance & Your Rights',
          body:
              'PrisPuls processes personal data in accordance with the General '
              'Data Protection Regulation (GDPR) (EU) 2016/679. As a data '
              'subject, you have the following rights:\n\n'
              '• Right of access – You may request a copy of the personal data '
              'we hold about you.\n'
              '• Right to rectification – You may ask us to correct inaccurate '
              'or incomplete data.\n'
              '• Right to erasure ("right to be forgotten") – You may request '
              'deletion of your personal data where there is no legitimate '
              'reason for us to continue processing it.\n'
              '• Right to restriction of processing – You may ask us to '
              'suspend processing of your data in certain circumstances.\n'
              '• Right to data portability – You may request a machine-readable '
              'copy of data you have provided to us.\n'
              '• Right to object – You may object to processing based on '
              'legitimate interests or for direct marketing.\n\n'
              'To exercise any of these rights, contact us at '
              'privacy@prispuls.no. We will respond within 30 days.',
        ),
        LegalSection(
          heading: 'Data We Collect',
          body:
              'We may collect and process the following categories of personal '
              'data:\n\n'
              '• Account data: email address and display name when you '
              'register or sign in via a third-party provider (e.g. Google).\n'
              '• Usage data: pages viewed, deals clicked, search queries, '
              'session duration, and in-app navigation events.\n'
              '• Device data: device type, operating system version, app '
              'version, and language settings.\n'
              '• Price-alert preferences: product categories and price '
              'thresholds you configure.\n\n'
              'We do not collect payment card numbers or financial information.',
        ),
        LegalSection(
          heading: 'Cookies & Tracking Technologies',
          body:
              'The PrisPuls web interface uses cookies and similar tracking '
              'technologies to improve performance and personalise your '
              'experience.\n\n'
              'Types of cookies we use:\n\n'
              '• Strictly necessary cookies – Required for the service to '
              'function (e.g. session management, authentication tokens). '
              'These cannot be disabled.\n'
              '• Analytics cookies – Help us understand how users interact '
              'with PrisPuls (e.g. pages visited, errors encountered). We use '
              'anonymised, aggregated data only.\n'
              '• Preference cookies – Remember your settings such as '
              'preferred currency and display language.\n'
              '• Affiliate & partner cookies – When you click through to a '
              'retailer via an affiliate link, that retailer may set its own '
              'cookies to track the referral and attribute any resulting '
              'purchase to us.\n\n'
              'You can manage or withdraw consent for non-essential cookies at '
              'any time through your browser settings or our in-app cookie '
              'preferences. Withdrawing consent will not affect the lawfulness '
              'of processing carried out before withdrawal.',
        ),
        LegalSection(
          heading: 'How We Use Your Data',
          body:
              'We process personal data for the following purposes and legal '
              'bases:\n\n'
              '• Providing the service (contract performance) – Authenticating '
              'your account, delivering price alerts, and displaying '
              'personalised deals.\n'
              '• Improving the service (legitimate interests) – Analysing '
              'usage patterns to identify bugs and improve features.\n'
              '• Legal obligations – Retaining transaction records as required '
              'by applicable law.\n'
              '• Marketing communications (consent) – Sending deal digests or '
              'promotional emails only if you have opted in.',
        ),
        LegalSection(
          heading: 'Data Retention',
          body:
              'We retain account data for as long as your account is active. '
              'Usage logs are retained for a maximum of 24 months in '
              'anonymised form. If you delete your account, we will erase your '
              'personal data within 30 days, except where retention is '
              'required by law.',
        ),
        LegalSection(
          heading: 'Data Sharing & Third Parties',
          body:
              'We do not sell your personal data. We may share data with:\n\n'
              '• Service providers acting as data processors on our behalf '
              '(e.g. Firebase/Google Cloud for hosting and authentication, '
              'analytics platforms).\n'
              '• Affiliate networks to attribute purchases and receive '
              'commissions.\n'
              '• Regulators or law enforcement where required by law.\n\n'
              'All third-party processors are bound by data processing '
              'agreements that require GDPR-compliant data handling.',
        ),
        LegalSection(
          heading: 'Data Security',
          body:
              'We implement appropriate technical and organisational measures '
              'to protect your data against unauthorised access, loss, or '
              'disclosure. These include encrypted data transmission (TLS), '
              'role-based access controls, and regular security reviews.',
        ),
        LegalSection(
          heading: 'Children\'s Privacy',
          body:
              'PrisPuls is not directed at children under the age of 16. We '
              'do not knowingly collect personal data from children. If you '
              'believe a child has provided us with personal data, please '
              'contact privacy@prispuls.no and we will delete it promptly.',
        ),
        LegalSection(
          heading: 'Changes to This Policy',
          body:
              'We may update this Privacy Policy from time to time. Material '
              'changes will be communicated via in-app notification or email '
              'at least 30 days before taking effect. Continued use of the '
              'service after that date constitutes acceptance of the updated '
              'policy.',
        ),
        LegalSection(
          heading: 'Contact & Data Controller',
          body:
              'The data controller for PrisPuls is:\n\n'
              'PrisPuls AS\n'
              'Norway\n'
              'Email: privacy@prispuls.no\n\n'
              'You also have the right to lodge a complaint with your local '
              'supervisory authority. In Norway, this is Datatilsynet '
              '(www.datatilsynet.no).',
        ),
      ],
    );
  }
}
