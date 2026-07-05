import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/deals/providers/deals_provider.dart';
import '../theme/glass_colors.dart';

/// A compact price-history sparkline for a deal card, backed by the real
/// `price_history` records in Supabase (see `priceHistoryProvider`).
///
/// Renders nothing (rather than an empty chart) when there's no history yet,
/// so cards for brand-new products don't show a misleading flat line.
class PriceSparkline extends ConsumerWidget {
  const PriceSparkline({super.key, required this.productId, this.height = 32});

  final String productId;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(priceHistoryProviderProvider(productId));

    return SizedBox(
      height: height,
      child: historyAsync.when(
        data: (spots) {
          if (spots.length < 2) return const SizedBox.shrink();

          var minY = spots.first.y;
          var maxY = spots.first.y;
          for (final spot in spots) {
            if (spot.y < minY) minY = spot.y;
            if (spot.y > maxY) maxY = spot.y;
          }
          final padding = (maxY - minY) * 0.15 + (maxY == minY ? 1 : 0);
          const color = GlassColors.glowBorderHover;

          return LineChart(
            LineChartData(
              minY: minY - padding,
              maxY: maxY + padding,
              // fl_chart doesn't clip its drawing to the chart's own
              // rectangle by default (FlClipData.none()) — the line/gradient
              // fill was painting past this widget's actual (correctly
              // padded) bounds, bleeding across the full card width and
              // visually looking like it ran into the product image above.
              clipData: const FlClipData.all(),
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 1.5,
                  color: color,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.28),
                        color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: Duration.zero,
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}
