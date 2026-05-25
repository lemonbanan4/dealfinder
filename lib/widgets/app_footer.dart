import 'package:flutter/material.dart';

import '../features/legal/presentation/about_us_page.dart';
import '../features/legal/presentation/privacy_policy_page.dart';
import '../features/legal/presentation/terms_of_service_page.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kAccentBlue = Color(0xFF00B4FF);
const _kMuted = Color(0xFF5A5A78);
const _kBorderDark = Color(0xFF252638);

/// A compact, persistent footer rendered at the bottom of the app shell.
///
/// Contains three text links (About Us, Privacy Policy, Terms of Service)
/// and a copyright notice. Matches the dark Liquid Glass design language.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0D15) : Colors.grey.shade50,
        border: Border(
          top: BorderSide(
            color: isDark ? _kBorderDark : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Navigation links ───────────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              _FooterLink(
                label: 'About Us',
                onTap: () => _push(context, const AboutUsPage()),
              ),
              _Dot(),
              _FooterLink(
                label: 'Privacy Policy',
                onTap: () => _push(context, const PrivacyPolicyPage()),
              ),
              _Dot(),
              _FooterLink(
                label: 'Terms of Service',
                onTap: () => _push(context, const TermsOfServicePage()),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // ── Copyright notice ───────────────────────────────────────────────
          Text(
            '© ${DateTime.now().year} PrisPuls. All rights reserved.',
            style: const TextStyle(
              color: _kMuted,
              fontSize: 11,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            color: _kAccentBlue,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: _kAccentBlue,
            decorationStyle: TextDecorationStyle.solid,
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Text(
        '·',
        style: TextStyle(
          color: _kMuted,
          fontSize: 14,
          height: 1,
        ),
      ),
    );
  }
}
