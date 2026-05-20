import 'package:flutter/material.dart';

const _kElectricBlue = Color(0xFF00B4FF);

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.iconSize = 22, this.fontSize = 18});

  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.radar, color: _kElectricBlue, size: iconSize),
        const SizedBox(width: 6),
        Text(
          'PrisPuls',
          style: TextStyle(
            color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: fontSize,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
