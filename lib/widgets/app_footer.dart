import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/deals/domain/product_category.dart';
import '../features/legal/presentation/about_us_page.dart';
import '../features/legal/presentation/privacy_policy_page.dart';
import '../features/legal/presentation/terms_of_service_page.dart';
import '../theme/glass_colors.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kAccentBlue = Color(0xFF00B4FF);
const _kMuted = Color(0xFF8A8AA0);
const _kHeading = Color(0xFFE4E6F0);

/// A professional, "trusted by" style footer mirroring the reference
/// Plusshop design: logo + tagline, a row of trust badges, three link
/// columns (Shop / Information / Support), and a copyright bar.
///
/// [onShopCategoryTap], when provided, wires the "Shop" column's category
/// links back to the feed's category filter (see `FeedPage._onFooterShopTap`);
/// when null, those links render inert (e.g. if this footer is ever reused
/// on a page with no deal feed to filter).
class AppFooter extends StatelessWidget {
  const AppFooter({super.key, this.onShopCategoryTap});

  final ValueChanged<String>? onShopCategoryTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0C0D15),
        border: Border(top: BorderSide(color: GlassColors.glowBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _FooterBrand(),
          const SizedBox(height: 28),
          const _TrustBadgeRow(),
          const SizedBox(height: 36),
          const Divider(color: GlassColors.glowBorder, height: 1),
          const SizedBox(height: 32),
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _shopColumn(onShopCategoryTap)),
                    Expanded(child: _informationColumn(context)),
                    Expanded(child: _supportColumn(context)),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shopColumn(onShopCategoryTap),
                    const SizedBox(height: 28),
                    _informationColumn(context),
                    const SizedBox(height: 28),
                    _supportColumn(context),
                  ],
                ),
          const SizedBox(height: 32),
          const Divider(color: GlassColors.glowBorder, height: 1),
          const SizedBox(height: 16),
          const _FooterBottomBar(),
        ],
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/app_icon.png', width: 28, height: 28),
            const SizedBox(width: 8),
            const Text(
              'PrisPuls',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Scandinavia's smartest way to compare prices.",
          style: TextStyle(color: _kMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Trust badges ─────────────────────────────────────────────────────────────

class _TrustBadgeRow extends StatelessWidget {
  const _TrustBadgeRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _TrustBadge(icon: Icons.lock_outline, label: 'Secure (HTTPS)'),
        _TrustBadge(icon: Icons.verified_user_outlined, label: 'Verified Affiliate Partner'),
        _TrustBadge(icon: Icons.privacy_tip_outlined, label: 'GDPR Compliant'),
        _TrustBadge(icon: Icons.bolt_outlined, label: 'Live Price Updates'),
        _TrustBadge(emoji: '🇸🇪', label: 'Sweden'),
        _TrustBadge(emoji: '🇳🇴', label: 'Norway'),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({this.icon, this.emoji, required this.label})
    : assert(icon != null || emoji != null, 'Provide an icon or an emoji flag');

  final IconData? icon;
  final String? emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GlassColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GlassColors.glowBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 15, color: _kAccentBlue)
          else
            Text(emoji!, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _kHeading,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Link columns ─────────────────────────────────────────────────────────────

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _kHeading,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }
}

Widget _shopColumn(ValueChanged<String>? onTap) {
  return _FooterColumn(
    title: 'Shop',
    children: [
      for (final category in dealCategories.where((c) => c != 'All'))
        _FooterLink(label: category, onTap: onTap == null ? null : () => onTap(category)),
    ],
  );
}

Widget _informationColumn(BuildContext context) {
  return _FooterColumn(
    title: 'Information',
    children: [
      _FooterLink(label: 'About Us', onTap: () => _push(context, const AboutUsPage())),
      _FooterLink(
        label: 'Privacy Policy',
        onTap: () => _push(context, const PrivacyPolicyPage()),
      ),
      _FooterLink(
        label: 'Terms of Service',
        onTap: () => _push(context, const TermsOfServicePage()),
      ),
    ],
  );
}

Widget _supportColumn(BuildContext context) {
  return _FooterColumn(
    title: 'Support',
    children: [
      _FooterLink(
        label: 'Contact Us',
        onTap: () => launchUrl(Uri.parse('mailto:support@prispuls.com')),
      ),
      _FooterLink(
        label: 'Affiliate Disclosure',
        onTap: () => _push(context, const AboutUsPage()),
      ),
    ],
  );
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => page));
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: _kMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── Bottom bar ────────────────────────────────────────────────────────────────

class _FooterBottomBar extends StatelessWidget {
  const _FooterBottomBar();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        Text(
          '© ${DateTime.now().year} PrisPuls. All rights reserved.',
          style: const TextStyle(color: _kMuted, fontSize: 11, letterSpacing: 0.1),
        ),
      ],
    );
  }
}
