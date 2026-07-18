import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';

/// Flutter port of the CSS `.glass-card` / `.glass-card-interactive`
/// classes (see `GlassColors` for the exact rgba/box-shadow token values).
///
/// Static by default (matching `.glass-card`): a frosted, translucent panel
/// with a soft white border and drop shadow. Pass [onTap] to opt into the
/// `.glass-card-interactive` hover treatment — a 3px lift, a subtle scale,
/// and a neon-blue border glow — detected via [MouseRegion] on desktop/web
/// and driven through the same tap via [InkWell] so touch devices still get
/// the ripple + [onTap] without needing a hover state.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.enableBlur = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Set false on highly-repeated instances (e.g. every card in a scrolling
  /// grid) — `BackdropFilter` is a real offscreen render pass per instance,
  /// and N of them live-blurring on every scroll frame is a known source of
  /// mobile jank. Fill/border/shadow stay identical either way so it still
  /// reads as glass, just without the live blur sampling underneath it.
  final bool enableBlur;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovering = false;

  void _setHovering(bool value) {
    if (_hovering != value) setState(() => _hovering = value);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final hovering = interactive && _hovering;
    final radius = BorderRadius.circular(widget.borderRadius);

    final transform = hovering
        ? (Matrix4.identity()
            ..translateByDouble(
              GlassColors.glassHoverLift.dx,
              GlassColors.glassHoverLift.dy,
              0,
              1,
            )
            ..scaleByDouble(
              GlassColors.glassHoverScale,
              GlassColors.glassHoverScale,
              1,
              1,
            ))
        : Matrix4.identity();

    final card = AnimatedContainer(
      duration: GlassColors.glassHoverDuration,
      curve: GlassColors.glassHoverCurve,
      transform: transform,
      transformAlignment: Alignment.center,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: GlassColors.glassFill,
        borderRadius: radius,
        border: Border.all(
          color: hovering
              ? GlassColors.glowBorderHover
              : GlassColors.glowBorder,
        ),
        boxShadow: hovering ? GlassColors.glassHoverShadow : GlassColors.glassShadow,
      ),
      child: widget.child,
    );

    Widget content = widget.enableBlur
        ? ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassColors.glassBlurSigma,
                sigmaY: GlassColors.glassBlurSigma,
              ),
              child: card,
            ),
          )
        : ClipRRect(borderRadius: radius, child: card);

    if (interactive) {
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
      cursor: interactive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: content,
    );
  }
}
