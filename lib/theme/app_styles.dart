import 'package:flutter/material.dart';

/// Flutter-side port of the "Liquid Glass" CSS design system from the
/// `iGaming-Affiliate-Review` project (`src/index.css`'s `.glass-card`,
/// `.glass-card-interactive`, and `.neon-border-*` utility classes) — kept
/// as literal a translation of those rgba()/box-shadow values as Flutter's
/// APIs allow, so this app's glass surfaces match that CSS pixel-for-pixel
/// rather than approximating it.
///
/// See [GlassCard] (lib/widgets/glass_card.dart) for the widget built on
/// top of these constants.
class AppStyles {
  AppStyles._();

  // ─── .glass-card ────────────────────────────────────────────────────────
  // background: rgba(8, 12, 28, 0.45);
  // backdrop-filter: blur(16px);
  // border: 1px solid rgba(255, 255, 255, 0.08);
  // box-shadow: 0 4px 30px rgba(0, 0, 0, 0.5);
  static const glassCardFill = Color.fromRGBO(8, 12, 28, 0.45);
  static const glassCardBorder = Color.fromRGBO(255, 255, 255, 0.08);
  static const glassCardBlurSigma = 16.0;
  static const glassCardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      offset: Offset(0, 4),
      blurRadius: 30,
    ),
  ];

  // ─── .glass-card-interactive:hover ──────────────────────────────────────
  // transform: translateY(-3px) scale(1.01);
  // border-color: rgba(56, 189, 248, 0.25);
  // box-shadow: 0 20px 40px -15px rgba(0, 0, 0, 0.7), 0 0 20px 0 rgba(56, 189, 248, 0.12);
  static const glassCardHoverBorder = Color.fromRGBO(56, 189, 248, 0.25);
  static const glassCardHoverShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.7),
      offset: Offset(0, 20),
      blurRadius: 40,
      spreadRadius: -15,
    ),
    BoxShadow(color: Color.fromRGBO(56, 189, 248, 0.12), blurRadius: 20),
  ];
  static const glassCardHoverLift = Offset(0, -3);
  static const glassCardHoverScale = 1.01;

  // transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  static const glassCardHoverDuration = Duration(milliseconds: 300);
  static const glassCardHoverCurve = Cubic(0.16, 1, 0.3, 1);

  // ─── .neon-border-* ──────────────────────────────────────────────────────
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
}
