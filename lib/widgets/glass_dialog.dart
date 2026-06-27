import 'dart:ui';

import 'package:flutter/material.dart';

/// A helper to show a dialog with a glassmorphism effect.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          title: title,
          content: content,
          actions: actions,
          backgroundColor: Colors.white.withAlpha(15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withAlpha(28)),
          ),
        ),
      );
    },
  );
}
