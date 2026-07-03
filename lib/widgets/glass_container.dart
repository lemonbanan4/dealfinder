import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';

/// A frosted-glass surface with a subtle glowing border, used for cards and
/// floating containers throughout the app. On web/desktop, hovering
/// intensifies both the blur and the glow to signal interactivity.
class GlassContainer extends StatefulWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.blurSigma = 16,
    this.hoverBlurSigma = 26,
    this.fillColor,
    this.hoverFillColor,
    this.borderColor,
    this.hoverBorderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final double hoverBlurSigma;

  /// Overrides for the default translucent-white glass palette. Pass these
  /// when a surface needs to match a specific look (e.g. the deep-charcoal
  /// deal card design) without affecting every other GlassContainer in the
  /// app, which keeps the shared `GlassColors` defaults.
  final Color? fillColor;
  final Color? hoverFillColor;
  final Color? borderColor;
  final Color? hoverBorderColor;

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _hovering = false;

  void _setHovering(bool value) {
    if (_hovering != value) setState(() => _hovering = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final targetSigma = _hovering ? widget.hoverBlurSigma : widget.blurSigma;
    final targetGlow = _hovering
        ? widget.hoverBorderColor ?? GlassColors.glowBorderHover
        : widget.borderColor ?? GlassColors.glowBorder;
    final targetFill = _hovering
        ? widget.hoverFillColor ?? GlassColors.glassFillHover
        : widget.fillColor ?? GlassColors.glassFill;

    Widget content = TweenAnimationBuilder<double>(
      tween: Tween(begin: widget.blurSigma, end: targetSigma),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      builder: (context, sigma, child) {
        return ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: targetFill,
          borderRadius: radius,
          border: Border.all(color: targetGlow, width: 1),
          boxShadow: [
            BoxShadow(
              color: targetGlow.withValues(alpha: _hovering ? 0.45 : 0.25),
              blurRadius: _hovering ? 24 : 12,
              spreadRadius: _hovering ? 1 : 0,
            ),
          ],
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          child: content,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _setHovering(true),
      onExit: (_) => _setHovering(false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: content,
    );
  }
}
