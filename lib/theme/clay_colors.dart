import 'package:flutter/material.dart';

/// Design tokens for the "White Claymorphism" look — the single source of
/// truth for every clay surface (`ClayContainer`, `ClayButton`, and anything
/// built on top of them). Mirrors the structure of `GlassColors` so the two
/// systems can be swapped screen-by-screen without drifting into divergent
/// token sources.
class ClayColors {
  ClayColors._();

  // ─── Background ─────────────────────────────────────────────────────────
  static const background = Color(0xFFFFFFFF);
  static const backgroundOffWhite = Color(0xFFF0F3F8);

  // ─── Clay surface (base) ────────────────────────────────────────────────
  /// The surface fill itself — sits between pure white and the off-white
  /// background so the dual shadow below reads clearly against both.
  static const clayFill = Color(0xFFF3F6FA);

  /// Top-left highlight — pure white, soft.
  static const clayHighlight = Color(0xFFFFFFFF);

  /// Bottom-right shadow — soft cool gray, not black, so it stays "soft"
  /// rather than reading as a drop shadow.
  static const clayShadow = Color(0xFFA3B1C6);

  static const clayBorderRadius = 32.0;

  /// Fully pill-shaped — for buttons/pills/chips.
  static const clayPillRadius = 999.0;

  static List<BoxShadow> clayShadows({double intensity = 1.0}) => [
    BoxShadow(
      color: clayHighlight.withValues(alpha: 0.9),
      offset: const Offset(-8, -8),
      blurRadius: 16 * intensity,
    ),
    BoxShadow(
      color: clayShadow.withValues(alpha: 0.35 * intensity),
      offset: const Offset(8, 8),
      blurRadius: 16 * intensity,
    ),
  ];

  /// Pressed/active state — shadows pull in tight to read as "sunken".
  static List<BoxShadow> clayShadowsPressed = [
    BoxShadow(
      color: clayHighlight.withValues(alpha: 0.6),
      offset: const Offset(-3, -3),
      blurRadius: 6,
    ),
    BoxShadow(
      color: clayShadow.withValues(alpha: 0.3),
      offset: const Offset(3, 3),
      blurRadius: 6,
    ),
  ];

  static const clayHoverDuration = Duration(milliseconds: 180);
  static const clayHoverCurve = Curves.easeOut;

  // ─── Text scale ─────────────────────────────────────────────────────────
  static const textHeading = Color(0xFF2D3748);
  static const textBody = Color(0xFF2D3748);
  static const textMuted = Color(0xFF718096);
  static const textPlaceholder = Color(0xFFA0AEC0);
}
