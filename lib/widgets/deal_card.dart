import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/deals/domain/deal.dart';
import '../features/settings/presentation/currency_provider.dart';
import '../features/settings/providers/settings_provider.dart';

enum DealCardView { grid, list }

class DealCard extends ConsumerWidget {
  const DealCard({
    super.key,
    required this.deal,
    this.view = DealCardView.list,
    // These are optional because for horizontal cards, the price is calculated inside
    this.displayPrice,
    this.currency,
    this.trailingActions,
    required this.onTap,
  });

  final Deal deal;
  final DealCardView view;
  final double? displayPrice;
  final String? currency;
  final List<Widget>? trailingActions;
  final VoidCallback onTap;

  String _formatAmount(double price) {
    final rounded = price.round();
    final s = rounded.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGridView = view == DealCardView.grid;

    if (isGridView) {
      return _GridCard(
        deal: deal,
        onTap: onTap,
        displayPrice: displayPrice,
        currency: currency,
        trailingActions: trailingActions,
      );
    }

    // LIST VIEW
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            // This is for the main list view
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Image ---
              SizedBox(
                width: 110,
                height: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: deal.imageUrl != null && deal.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: deal.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.secondary,
                          child: const Icon(Icons.shopping_bag_outlined),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // --- Details ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.source,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatAmount(displayPrice ?? 0)} ${currency ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        if (deal.originalPrice != null &&
                            (displayPrice ?? 0) < deal.originalPrice!)
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 2),
                            child: Text(
                              _formatAmount(deal.originalPrice!),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // --- Actions ---
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [...?trailingActions],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridCard extends ConsumerWidget {
  const _GridCard({
    required this.deal,
    required this.onTap,
    this.displayPrice,
    this.currency,
    this.trailingActions,
  });
  final Deal deal;
  final VoidCallback onTap;
  final double? displayPrice;
  final String? currency;
  final List<Widget>? trailingActions;

  String _formatAmount(double price) {
    final rounded = price.round();
    final s = rounded.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyConverterProvider);
    final pct = deal.discountPercent?.round() ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148,
        height: 192,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + discount badge ──────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: deal.imageUrl != null && deal.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: deal.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, err) => ColoredBox(
                            color: Theme.of(context).colorScheme.surface,
                            child: Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                size: 28,
                              ),
                            ),
                          ),
                        )
                      : ColoredBox(
                          color: Theme.of(context).colorScheme.surface,
                          child: Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              size: 28,
                            ),
                          ),
                        ),
                ),
                if (pct > 0)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-$pct%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // ── Details ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    _PriceDisplay(
                      currencyState: currencyState,
                      displayPrice: displayPrice ?? deal.currentPrice,
                      targetCurrency: currency ?? deal.currency,
                      displayOriginalPrice: deal.originalPrice,
                      formatAmount: _formatAmount,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  const _PriceDisplay({
    required this.currencyState,
    required this.displayPrice,
    required this.targetCurrency,
    this.displayOriginalPrice,
    required this.formatAmount,
  });

  final AsyncValue<ExchangeRates?> currencyState;
  final double displayPrice;
  final String targetCurrency;
  final double? displayOriginalPrice;
  final String Function(double) formatAmount;

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
              color: const Color(0xFF00E676), // Kept for specific design choice
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (displayOriginalPrice != null) ...[
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
        child: Container(
          height: 13,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      error: (_, _) => const Text('N/A'),
    );
  }
}
