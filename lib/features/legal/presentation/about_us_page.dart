import 'package:flutter/material.dart';

import 'legal_page.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'About Us',
      sections: [
        LegalSection(
          heading: 'Who We Are',
          body:
              'PrisPuls is a Scandinavian price-comparison and deal-discovery '
              'service built to help consumers find the best prices on '
              'electronics, home goods, fashion, and more — all in one place.\n\n'
              'Our platform aggregates offers from hundreds of retailers, '
              'refreshed multiple times a day, so you always have the most '
              'current pricing at your fingertips.',
        ),
        LegalSection(
          heading: 'Our Mission',
          body:
              'We believe every consumer deserves to make informed purchasing '
              'decisions without spending hours comparing prices across dozens '
              'of websites. PrisPuls does that work for you — so you can buy '
              'smarter, save more, and spend your time on what matters.',
        ),
        LegalSection(
          heading: 'Affiliate Disclosure',
          isHighlighted: true,
          body:
              'PrisPuls participates in various affiliate marketing programs, '
              'which means we may get paid commissions on editorially chosen '
              'products purchased through our links to retailer sites.\n\n'
              'When you click on a product link and complete a purchase, '
              'PrisPuls may earn a small commission from the retailer at no '
              'additional cost to you. These commissions help us maintain and '
              'continuously improve our service.\n\n'
              'Our editorial decisions — including which products and deals we '
              'feature — are made independently of any affiliate relationship. '
              'We are committed to providing honest, unbiased pricing '
              'information regardless of whether a commercial relationship '
              'exists with a given retailer.',
        ),
        LegalSection(
          heading: 'Our Team',
          body:
              'PrisPuls is built and maintained by a small, passionate team '
              'dedicated to consumer transparency and fair pricing. We are '
              'headquartered in Norway and serve users across the Nordic '
              'region.',
        ),
        LegalSection(
          heading: 'Contact Us',
          body:
              'Have a question, found an incorrect price, or want to partner '
              'with us?\n\n'
              'Email: support@prispuls.no\n'
              'Website: www.prispuls.no\n\n'
              'We typically respond within two business days.',
        ),
      ],
    );
  }
}
