import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass_colors.dart';

/// A helper to show a dialog with a glassmorphism effect.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassColors.glassBlurSigma,
          sigmaY: GlassColors.glassBlurSigma,
        ),
        child: AlertDialog(
          title: title,
          content: content,
          actions: actions,
          backgroundColor: GlassColors.glassFill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: GlassColors.glowBorder),
          ),
        ),
      );
    },
  );
}
