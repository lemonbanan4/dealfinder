import 'package:flutter/material.dart';

import '../../../../widgets/glass_card.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
