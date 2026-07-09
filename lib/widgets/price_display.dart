import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../features/settings/presentation/currency_provider.dart';
import '../theme/glass_colors.dart';
import '../utils/formatters.dart';

/// A widget that displays a price, handling currency conversion,
/// formatting, and an optional original price with a strikethrough.
class PriceDisplay extends StatelessWidget {
  const PriceDisplay({
    super.key,
    required this.currencyState,
    required this.displayPrice,
    required this.targetCurrency,
    this.displayOriginalPrice,
  });

  final AsyncValue<ExchangeRates?> currencyState;
  final double displayPrice;
  final String targetCurrency;
  final double? displayOriginalPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return currencyState.when(
      data: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatAmount(displayPrice)} $targetCurrency',
            style: theme.textTheme.labelLarge?.copyWith(
              color: GlassColors.priceAccent,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (displayOriginalPrice != null &&
              displayOriginalPrice! > displayPrice) ...[
            const SizedBox(height: 1),
            Text(
              '${formatAmount(displayOriginalPrice!)} $targetCurrency',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
                decoration: TextDecoration.lineThrough,
                decorationColor: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ],
      ),
      loading: () => Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surfaceBright,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 13,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
      error: (_, st) => Text('N/A', style: theme.textTheme.labelLarge),
    );
  }
}
