import 'dart:ui';

import 'package:flutter/material.dart';

class LiquidGlassBackground extends StatelessWidget {
  const LiquidGlassBackground({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    // Outer shell provides the gradient border (top-left electric blue → bottom-right dark).
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00B4FF).withAlpha(90),
            const Color(0xFF0A1540).withAlpha(60),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 0.8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // blue[900] at 15% — the dark blue glass fill
                    const Color(0xFF0D47A1).withAlpha(38),
                    const Color(0xFF050815).withAlpha(210),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
