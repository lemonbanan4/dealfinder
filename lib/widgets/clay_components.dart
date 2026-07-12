import 'package:flutter/material.dart';

import '../theme/clay_colors.dart';

/// A "White Claymorphism" surface: a soft off-white fill with a dual
/// box-shadow (pure-white highlight top-left, soft gray shadow
/// bottom-right) and an extreme border radius. Used as the base building
/// block for any clay card/panel; see [ClayButton] for the tappable pill
/// variant.
class ClayContainer extends StatefulWidget {
  const ClayContainer({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = ClayColors.clayBorderRadius,
    this.padding,
    this.margin,
    this.fillColor,
    this.pressedFillColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? fillColor;
  final Color? pressedFillColor;

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final pressed = interactive && _pressed;
    final radius = BorderRadius.circular(widget.borderRadius);

    Widget content = AnimatedContainer(
      duration: ClayColors.clayHoverDuration,
      curve: ClayColors.clayHoverCurve,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: pressed
            ? (widget.pressedFillColor ?? widget.fillColor ?? ClayColors.clayFill)
            : (widget.fillColor ?? ClayColors.clayFill),
        borderRadius: radius,
        boxShadow: pressed
            ? ClayColors.clayShadowsPressed
            : ClayColors.clayShadows(),
      ),
      child: widget.child,
    );

    if (interactive) {
      content = GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// A pill-shaped clay button — [ClayContainer] with a fully-rounded radius
/// and centered label/child, sinking into a "pressed" shadow on tap.
class ClayButton extends StatelessWidget {
  const ClayButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.fillColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      onTap: onPressed,
      borderRadius: ClayColors.clayPillRadius,
      padding: padding,
      fillColor: fillColor,
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          color: ClayColors.textHeading,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      ),
    );
  }
}
