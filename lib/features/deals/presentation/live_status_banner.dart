import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/glass_colors.dart';
import '../../../widgets/glass_card.dart';
import '../providers/feed_stats_provider.dart';
import '../providers/paged_deals_provider.dart';

/// A slim glass "pulse" banner shown above the feed, cycling between a couple
/// of live-status messages (deal count currently tracked, monitoring status)
/// — reads as a heartbeat of the aggregator rather than a static label.
class LiveStatusBanner extends ConsumerStatefulWidget {
  const LiveStatusBanner({super.key});

  @override
  ConsumerState<LiveStatusBanner> createState() => _LiveStatusBannerState();
}

class _LiveStatusBannerState extends ConsumerState<LiveStatusBanner> {
  late final Timer _timer;
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) setState(() => _messageIndex++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = ref.watch(pagedDealsProvider).value?.totalCount;
    final priceDropsToday = ref.watch(feedStatsProvider).value?.priceDropsToday;
    final messages = [
      totalCount != null && totalCount > 0
          ? '🔥 $totalCount+ deals tracked right now'
          : '🔥 New deals synced continuously',
      if (priceDropsToday != null && priceDropsToday > 0)
        '📉 Found $priceDropsToday price drops today',
      '⚡ Live price monitoring active',
    ];
    final message = messages[_messageIndex % messages.length];

    return GlassCard(
      borderRadius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PulsingDot(),
          const SizedBox(width: 10),
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                message,
                key: ValueKey(message),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft radial indigo/blue glow sitting behind [child] — a decorative
/// "spotlight" effect (reference: screenshots/blue_black.png) rather than a
/// flat background, so the live-status banner reads as the focal point of
/// this part of the page instead of just another pill on a plain backdrop.
/// Self-contained (fixed height, no overflow) so it drops into the feed's
/// sliver flow like any other box.
class BannerGlowBackdrop extends StatelessWidget {
  const BannerGlowBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 640,
            height: 220,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0x594F46E5), // indigo-600 glow, ~35% alpha
                  Color(0x00000000),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GlassColors.priceAccent,
            boxShadow: [
              BoxShadow(
                color: GlassColors.priceAccent.withValues(alpha: 0.2 + 0.6 * t),
                blurRadius: 6 + 6 * t,
                spreadRadius: 1 + t,
              ),
            ],
          ),
        );
      },
    );
  }
}
