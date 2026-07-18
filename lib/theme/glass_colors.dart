import 'package:flutter/material.dart';

/// Design tokens for the "Liquid Glass" look — a single source of truth
/// shared by every glass surface in the app (`GlassCard`, `GlassContainer`,
/// the top nav bar, deal cards, dropdowns, footer, etc.) so they can't drift
/// into two visually-inconsistent glass systems the way `GlassColors` and
/// the old `AppStyles` did. Ported from the reference React app's CSS
/// (flat slate-950 body, `.glass-card` / `.glass-card:hover`, and the
/// Tailwind accent palette below) — colors only, no unrelated markup.
class GlassColors {
  GlassColors._();

  // ─── Background ─────────────────────────────────────────────────────────
  // A flat, solid backdrop (not a gradient) — deep purple-black.
  static const background = Color(0xFF120B22);

  /// One step lighter than [background] — used where a surface needs to
  /// read as "elevated" with a solid (non-translucent) color, e.g. the
  /// mobile bottom nav bar or a dropdown menu's own backdrop.
  static const surface = Color(0xFF1C1233);

  // ─── Glass card (base) ──────────────────────────────────────────────────
  static const glassFill = Color.fromRGBO(26, 15, 46, 0.45);
  static const glassFillHover = glassFill; // fill doesn't change on hover
  static const glassBorder = Color.fromRGBO(255, 255, 255, 0.08);
  static const glassBlurSigma = 16.0;
  static const glassShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      offset: Offset(0, 4),
      blurRadius: 30,
    ),
  ];

  // Old names kept as aliases so every existing call site (nav bar, deal
  // cards, dropdowns, footer, ...) picks up the new palette without a
  // separate rename pass.
  static const glowBorder = glassBorder;

  // ─── Glass card (hover) ──────────────────────────────────────────────────
  // border-color: rgba(168, 85, 247, 0.35) — purple-500 glow.
  static const glowBorderHover = Color.fromRGBO(168, 85, 247, 0.35);
  static const glassHoverShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.7),
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -15,
    ),
    BoxShadow(color: Color.fromRGBO(168, 85, 247, 0.16), blurRadius: 20),
  ];
  static const glassHoverLift = Offset(0, -3);
  static const glassHoverScale = 1.01;
  static const glassHoverDuration = Duration(milliseconds: 300);
  static const glassHoverCurve = Cubic(0.16, 1, 0.3, 1);

  // ─── Accents (Tailwind hex, used as-is — no compliance/region meaning) ──
  static const blue500 = Color(0xFF3B82F6);
  static const indigo600 = Color(0xFF4F46E5);
  static const emerald400 = Color(0xFF34D399);
  static const blue400 = Color(0xFF60A5FA);
  static const amber400 = Color(0xFFFBBF24);
  static const rose500 = Color(0xFFF43F5E);
  static const sky400 = Color(0xFF38BDF8);

  /// Purple — the primary brand accent (nav hover glow, focus rings,
  /// primary CTA gradient start).
  static const purple400 = Color(0xFFC084FC);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const violet700 = Color(0xFF6D28D9);

  /// Orange — the secondary brand accent, paired with purple on primary
  /// interactive elements (CTA gradient end, hot-deal highlights).
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);

  /// Money/price accent — emerald reads as "good news" (price drop) at a
  /// glance, matching the sparkline/price-text color used across deal cards.
  /// Kept independent of the purple/orange brand accents since it's a
  /// functional (up/down) signal, not a decorative one.
  static const priceAccent = emerald400;

  // ─── Neon glow utilities ────────────────────────────────────────────────
  static const neonBorderBlue = Color.fromRGBO(56, 189, 248, 0.2);
  static const neonGlowBlue = [
    BoxShadow(color: Color.fromRGBO(56, 189, 248, 0.1), blurRadius: 15),
  ];
  static const neonBorderEmerald = Color.fromRGBO(16, 185, 129, 0.2);
  static const neonGlowEmerald = [
    BoxShadow(color: Color.fromRGBO(16, 185, 129, 0.1), blurRadius: 15),
  ];
  static const neonBorderRose = Color.fromRGBO(244, 63, 94, 0.2);
  static const neonGlowRose = [
    BoxShadow(color: Color.fromRGBO(244, 63, 94, 0.1), blurRadius: 15),
  ];
  static const neonBorderPurple = Color.fromRGBO(168, 85, 247, 0.25);
  static const neonGlowPurple = [
    BoxShadow(color: Color.fromRGBO(168, 85, 247, 0.15), blurRadius: 15),
  ];
  static const neonBorderOrange = Color.fromRGBO(249, 115, 22, 0.25);
  static const neonGlowOrange = [
    BoxShadow(color: Color.fromRGBO(249, 115, 22, 0.15), blurRadius: 15),
  ];
  static const neonTextBlue = [
    Shadow(color: Color.fromRGBO(56, 189, 248, 0.4), blurRadius: 8),
  ];

  // ─── Text scale (Tailwind slate) ────────────────────────────────────────
  static const textHeading = Color(0xFFF1F5F9); // slate-100
  static const textBody = Color(0xFFCBD5E1); // slate-300
  static const textMuted = Color(0xFF94A3B8); // slate-400
  static const textPlaceholder = Color(0xFF64748B); // slate-500
}
