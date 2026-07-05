import 'package:flutter/material.dart';

/// Palette for the "liquid glass" design system: a deep bluish gradient
/// backdrop with translucent, frosted-glass surfaces and soft white/light
/// borders (rather than solid fills or colored borders) so cards read as
/// panes of glass floating above the gradient.
class GlassColors {
  GlassColors._();

  static const backgroundStart = Color(0xFF0A192F);
  static const backgroundEnd = Color(0xFF112240);

  /// Flat fallback for contexts that need a single Color (e.g.
  /// ColorScheme.surface, Scaffold.backgroundColor) rather than a gradient.
  static const background = backgroundStart;

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundStart, backgroundEnd],
  );

  static const surface = Color(0xFF112240);
  static const glowBorder = Color(0x40FFFFFF);
  static const glowBorderHover = Color(0x80FFFFFF);
  static const glassFill = Color(0x1AFFFFFF);
  static const glassFillHover = Color(0x26FFFFFF);
}
