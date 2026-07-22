import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/glass_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/deal.dart';
import '../providers/deals_provider.dart';

/// The full, interactive price-history chart on the product detail page —
/// the delivery of PrisPuls's core promise ("see the real price history so
/// you know if a discount is genuine"). The card-level [PriceSparkline] is a
/// tiny decorative teaser of the same `price_history` data; this is the real
/// thing: dated axes, a touch tooltip, and lowest/highest/current summary
/// stats, with prices converted into the viewer's chosen display currency
/// (the stored history is in the store's own feed currency).
///
/// Degrades honestly: with fewer than two tracked points there's no line to
/// draw, so it shows a short "not enough history yet" note rather than a
/// misleading flat line — matching how the sparkline hides itself.
class PriceHistoryChart extends ConsumerWidget {
  const PriceHistoryChart({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final historyAsync = ref.watch(priceHistoryProviderProvider(deal.id));

    return historyAsync.when(
      loading: () => const _ChartFrame(child: _ChartSkeleton()),
      error: (_, _) => const SizedBox.shrink(),
      data: (rawSpots) {
        final targetCurrency = ref.watch(appSettingsProvider).displayCurrency;
        final converter = ref.watch(currencyConverterProvider.notifier);

        // Convert every point from the deal's feed currency into the
        // viewer's display currency, preserving the x (timestamp) axis.
        final spots = [
          for (final s in rawSpots)
            FlSpot(s.x, converter.convert(s.y, deal.currency, targetCurrency)),
        ];

        if (spots.length < 2) {
          return _ChartFrame(
            title: l10n.priceHistoryTitle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.priceHistoryNotEnough,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: GlassColors.textMuted,
                ),
              ),
            ),
          );
        }

        double minY = spots.first.y, maxY = spots.first.y;
        int minIdx = 0;
        for (var i = 0; i < spots.length; i++) {
          if (spots[i].y < minY) {
            minY = spots[i].y;
            minIdx = i;
          }
          if (spots[i].y > maxY) maxY = spots[i].y;
        }
        final current = spots.last.y;
        final yPad = (maxY - minY) * 0.18 + (maxY == minY ? 1 : 0);
        final firstDate = DateTime.fromMillisecondsSinceEpoch(
          spots.first.x.toInt(),
        );
        final dateFmt = DateFormat.MMMd(l10n.localeName);

        // "This is the lowest we've seen" — true only when the current price
        // is at (or below) every earlier tracked point, a genuinely useful
        // buy-signal that the whole app is built to surface honestly.
        final atLowest = current <= minY + 0.001;

        return _ChartFrame(
          title: l10n.priceHistoryTitle,
          subtitle: l10n.priceHistorySince(dateFmt.format(firstDate)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _StatsRow(
                lowest: minY,
                highest: maxY,
                current: current,
                currency: targetCurrency,
                atLowest: atLowest,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: _Chart(
                  spots: spots,
                  minY: minY - yPad,
                  maxY: maxY + yPad,
                  minIdx: minIdx,
                  currency: targetCurrency,
                  ref: ref,
                ),
              ),
              if (atLowest) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_down_rounded,
                      size: 18,
                      color: GlassColors.priceAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.priceHistoryIsLowest,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: GlassColors.priceAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ChartFrame extends StatelessWidget {
  const _ChartFrame({this.title, this.subtitle, required this.child});

  final String? title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: GlassColors.textHeading,
              ),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: GlassColors.textMuted,
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow({
    required this.lowest,
    required this.highest,
    required this.current,
    required this.currency,
    required this.atLowest,
  });

  final double lowest;
  final double highest;
  final double current;
  final String currency;
  final bool atLowest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _Stat(
          label: l10n.priceHistoryLowest,
          value: lowest,
          currency: currency,
          highlight: true,
        ),
        _Stat(
          label: l10n.priceHistoryCurrent,
          value: current,
          currency: currency,
          highlight: atLowest,
        ),
        _Stat(
          label: l10n.priceHistoryHighest,
          value: highest,
          currency: currency,
        ),
      ],
    );
  }
}

class _Stat extends ConsumerWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.currency,
    this.highlight = false,
  });

  final String label;
  final double value;
  final String currency;
  final bool highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatted = ref.watch(
      formattedPriceProvider(price: value, currency: currency),
    );
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: GlassColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            formatted,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight
                  ? GlassColors.priceAccent
                  : GlassColors.textHeading,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({
    required this.spots,
    required this.minY,
    required this.maxY,
    required this.minIdx,
    required this.currency,
    required this.ref,
  });

  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final int minIdx;
  final String currency;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spanMs = spots.last.x - spots.first.x;
    final dateFmt = DateFormat.MMMd(l10n.localeName);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: spots.first.x,
        maxX: spots.last.x,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) <= 0 ? 1 : (maxY - minY) / 3,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: GlassColors.glowBorder, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: (maxY - minY) <= 0 ? 1 : (maxY - minY) / 2,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value >= 1000
                        ? '${(value / 1000).toStringAsFixed(0)}k'
                        : value.toStringAsFixed(0),
                    style: const TextStyle(
                      color: GlassColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: spanMs <= 0 ? 1 : spanMs / 2,
              getTitlesWidget: (value, meta) {
                final d = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dateFmt.format(d),
                    style: const TextStyle(
                      color: GlassColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => GlassColors.surface,
            getTooltipItems: (touched) => [
              for (final t in touched)
                LineTooltipItem(
                  '${_fmt(t.y, currency)}\n',
                  const TextStyle(
                    color: GlassColors.priceAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: dateFmt.format(
                        DateTime.fromMillisecondsSinceEpoch(t.x.toInt()),
                      ),
                      style: const TextStyle(
                        color: GlassColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2.5,
            color: GlassColors.priceAccent,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) =>
                  spot.x == spots[minIdx].x || spot.x == spots.last.x,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: spot.x == spots[minIdx].x
                    ? GlassColors.priceAccent
                    : GlassColors.orange400,
                strokeWidth: 2,
                strokeColor: GlassColors.background,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GlassColors.priceAccent.withValues(alpha: 0.25),
                  GlassColors.priceAccent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact currency label for the tooltip (the provider-based formatter
  // needs a WidgetRef/BuildContext; a tooltip callback has neither, so this
  // renders a plain "1 234 SEK"-style string good enough for the overlay).
  static String _fmt(double value, String currency) {
    final n = NumberFormat.decimalPattern();
    n.maximumFractionDigits = 0;
    return '${n.format(value)} $currency';
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
