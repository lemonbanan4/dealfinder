import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF060710), Color(0xFF0D1535), Color(0xFF060710)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Decorative blobs so the blur has something to act on
        Positioned(
          top: -60,
          left: -80,
          child: _Blob(color: const Color(0xFF006EFF), size: 280),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: _Blob(color: const Color(0xFF0044AA), size: 220),
        ),
        Positioned(
          top: 200,
          right: 40,
          child: _Blob(color: const Color(0xFF00B4FF), size: 120),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(45),
      ),
    );
  }
}
