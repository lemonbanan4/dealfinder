import 'package:flutter/material.dart';

import '../../../../theme/glass_colors.dart';

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: GlassColors.glowBorder);
  }
}
