import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.iconSize = 22, this.fontSize = 18});

  final double iconSize;
  final double fontSize;

  // A single gradient spans the icon + wordmark together (one shader per
  // element, same stops) rather than each picking its own — a shared
  // brand gradient reads as one continuous mark instead of two
  // separately-colored pieces sitting next to each other.
  static const _gradient = LinearGradient(
    colors: [GlassColors.purple400, GlassColors.orange400],
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => _gradient.createShader(bounds),
          child: Image.asset(
            'assets/images/app_icon.png',
            width: iconSize,
            height: iconSize,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;

              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                child: child,
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => _gradient.createShader(bounds),
          child: Text(
            'PrisPuls',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
