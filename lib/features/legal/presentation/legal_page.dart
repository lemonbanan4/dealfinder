import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/glass_colors.dart';

/// A standard full-screen scaffold for legal/info pages (About, Privacy,
/// Terms). Accepts a list of [LegalSection] models and renders them as
/// scrollable glass-tinted cards. Always the dark glass look, matching the
/// rest of the app (feed, nav bar, settings) — this is one tap away from
/// Settings, so it needs to look like the same app, not a different one.
class LegalPage extends StatelessWidget {
  const LegalPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: GlassColors.glowBorder),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        itemCount: sections.length,
        itemBuilder: (context, index) => _SectionCard(section: sections[index]),
      ),
    );
  }
}

/// A single section displayed in a [LegalPage].
///
/// Set [isHighlighted] to `true` to apply a blue accent border —
/// used for the Affiliate Disclosure section.
class LegalSection {
  const LegalSection({
    required this.heading,
    required this.body,
    this.isHighlighted = false,
  });

  final String heading;
  final String body;
  final bool isHighlighted;
}

// ─── Private card widget ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});
  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final borderColor = section.isHighlighted
        ? GlassColors.sky400.withValues(alpha: 0.4)
        : GlassColors.glowBorder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassColors.glassBlurSigma,
            sigmaY: GlassColors.glassBlurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: GlassColors.glassFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: section.isHighlighted
                  ? [
                      BoxShadow(
                        color: GlassColors.sky400.withValues(alpha: 0.1),
                        blurRadius: 16,
                      ),
                    ]
                  : GlassColors.glassShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading row
                  Row(
                    children: [
                      if (section.isHighlighted) ...[
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: GlassColors.sky400,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          section.heading,
                          style: TextStyle(
                            color: section.isHighlighted
                                ? GlassColors.sky400
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Body text
                  Text(
                    section.body,
                    style: const TextStyle(
                      color: GlassColors.textMuted,
                      fontSize: 13.5,
                      height: 1.65,
                      letterSpacing: 0.05,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
