import 'package:flutter/material.dart';

// ─── Design tokens (mirrors deal_card.dart palette) ──────────────────────────
const _kAccentBlue = Color(0xFF00B4FF);
const _kBorderDark = Color(0xFF252638);
const _kSurface = Color(0xFF12131A);
const _kBackground = Color(0xFF0A0B10);

/// A standard full-screen scaffold for legal/info pages (About, Privacy,
/// Terms). Accepts a list of [LegalSection] models and renders them as
/// scrollable glass-tinted cards.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? _kBackground : null,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0C0D15) : null,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : null,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : null,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? _kBorderDark : Theme.of(context).dividerColor,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        itemCount: sections.length,
        itemBuilder: (context, index) =>
            _SectionCard(section: sections[index], isDark: isDark),
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
  const _SectionCard({required this.section, required this.isDark});
  final LegalSection section;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = section.isHighlighted
        ? _kAccentBlue.withAlpha(120)
        : isDark
            ? _kBorderDark
            : Colors.grey.shade200;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? _kSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: section.isHighlighted
              ? [
                  BoxShadow(
                    color: _kAccentBlue.withAlpha(18),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
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
                      color: _kAccentBlue,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      section.heading,
                      style: TextStyle(
                        color: section.isHighlighted
                            ? _kAccentBlue
                            : isDark
                                ? Colors.white
                                : null,
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
                style: TextStyle(
                  color: isDark ? const Color(0xFFB0B0C8) : Colors.grey.shade700,
                  fontSize: 13.5,
                  height: 1.65,
                  letterSpacing: 0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
