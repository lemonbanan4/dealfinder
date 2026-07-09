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
    this.border,
    this.boxShadow,
    this.enableHoverAnimation = true,
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

  /// Overrides the default `Border.all(...)` — e.g. a bottom-only border for
  /// a full-bleed sticky header instead of a border on all four sides.
  final BoxBorder? border;

  /// Overrides the default hover-reactive glow shadow with a fixed one —
  /// e.g. a static bar that always wants the same glow regardless of hover.
  final List<BoxShadow>? boxShadow;

  /// Set to false for static chrome (e.g. a bar hosting many of its own
  /// interactive children) where the whole surface intensifying its blur
  /// and border on hover would read as a spurious "the whole bar is
  /// hovered" glow rather than signaling one tappable surface.
  final bool enableHoverAnimation;

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
    final hovering = widget.enableHoverAnimation && _hovering;
    final radius = BorderRadius.circular(widget.borderRadius);
    final targetSigma = hovering ? widget.hoverBlurSigma : widget.blurSigma;
    final targetGlow = hovering
        ? widget.hoverBorderColor ?? GlassColors.glowBorderHover
        : widget.borderColor ?? GlassColors.glowBorder;
    final targetFill = hovering
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
          border: widget.border ?? Border.all(color: targetGlow, width: 1),
          boxShadow:
              widget.boxShadow ??
              [
                BoxShadow(
                  color: targetGlow.withValues(alpha: hovering ? 0.45 : 0.25),
                  blurRadius: hovering ? 24 : 12,
                  spreadRadius: hovering ? 1 : 0,
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

    if (!widget.enableHoverAnimation) return content;

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
