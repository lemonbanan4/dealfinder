import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders an animated liquid-glass shader behind [child].
///
/// The [FragmentProgram] is loaded once and cached across all instances.
/// Each widget gets its own [AnimationController] so cards phase-shift
/// naturally as they enter the viewport at different times.
///
/// Falls back to a solid dark surface until the shader asset resolves
/// (typically < 1 frame on Impeller since shaders are pre-compiled).
class LiquidGlassBackground extends StatefulWidget {
  const LiquidGlassBackground({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
  });

  final Widget child;
  final double borderRadius;

  @override
  State<LiquidGlassBackground> createState() =>
      _LiquidGlassBackgroundState();
}

class _LiquidGlassBackgroundState extends State<LiquidGlassBackground>
    with SingleTickerProviderStateMixin {
  // Shared across all instances — one compile, many consumers.
  static Future<ui.FragmentProgram>? _programFuture;

  late final AnimationController _clock;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    // 24-hour controller avoids any visible loop discontinuity in practice.
    _clock = AnimationController(
      vsync: this,
      duration: const Duration(hours: 24),
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    _programFuture ??=
        ui.FragmentProgram.fromAsset('assets/shaders/liquid_glass.frag');
    final program = await _programFuture!;
    if (mounted) setState(() => _shader = program.fragmentShader());
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;

    // ── Fallback: plain dark card before the shader resolves ──────────────────
    if (shader == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF12131A),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: const Color(0xFF252638)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius - 1),
          child: widget.child,
        ),
      );
    }

    // ── Live shader path ──────────────────────────────────────────────────────
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        // Subtle luminous border — evokes the edge of real glass.
        border: Border.all(color: const Color(0x35FFFFFF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 1),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Animated background in its own compositing layer so content
            // layers above it don't repaint on every shader tick.
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _LiquidGlassPainter(
                    shader: shader,
                    clock: _clock,
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _LiquidGlassPainter extends CustomPainter {
  _LiquidGlassPainter({
    required this.shader,
    required this.clock,
  }) : super(repaint: clock); // clock drives per-frame repaints directly

  final ui.FragmentShader shader;
  final AnimationController clock;

  @override
  void paint(Canvas canvas, Size size) {
    // Mutate uniforms in-place each frame — no allocation.
    // Index order must match GLSL declaration order:
    //   uniform float uTime;  → 0
    //   uniform vec2  uSize;  → 1, 2
    shader
      ..setFloat(0, clock.value * 86400.0) // map 0..1 → 0..86400 seconds
      ..setFloat(1, size.width)
      ..setFloat(2, size.height);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  // shouldRepaint is intentionally false — the AnimationController Listenable
  // above triggers targeted repaints on the render object directly, bypassing
  // widget rebuilds and shouldRepaint entirely.
  @override
  bool shouldRepaint(_LiquidGlassPainter old) => false;
}
