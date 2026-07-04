import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/deals/domain/deal.dart';
import '../features/deals/providers/favorites_provider.dart';
import '../features/settings/presentation/currency_provider.dart';
import '../theme/glass_colors.dart';
import '../utils/formatters.dart';
import 'glass_container.dart';
import 'price_display.dart';
import 'price_sparkline.dart';

/// Deep-charcoal glass fill for deal cards specifically, per the premium
/// grid design: a solid-feeling dark panel rather than the translucent
/// white glass used elsewhere in the app.
const _cardFill = Color.fromRGBO(11, 14, 20, 0.82);
const _cardFillHover = Color.fromRGBO(11, 14, 20, 0.92);

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
    return GlassContainer(
      borderRadius: 16,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      fillColor: _cardFill,
      hoverFillColor: _cardFillHover,
      borderColor: GlassColors.glowBorder,
      hoverBorderColor: GlassColors.glowBorderHover,
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
                    PriceSparkline(productId: deal.id, height: 24),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${formatAmount(displayPrice ?? 0)} ${currency ?? ''}',
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
                              formatAmount(deal.originalPrice!),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyConverterProvider);
    final pct = deal.discountPercent?.round() ?? 0;

    final isFavorite = ref.watch(
      favoritesProvider.select(
        (favs) => favs.value?.contains(deal.id) ?? false,
      ),
    );

    return GlassContainer(
      borderRadius: 12,
      onTap: onTap,
      fillColor: _cardFill,
      hoverFillColor: _cardFillHover,
      borderColor: GlassColors.glowBorder,
      hoverBorderColor: GlassColors.glowBorderHover,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // ── Image + discount badge ──────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 170,
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
                // --- Favorite Button ---
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white.withValues(alpha: 0.8),
                    ),
                    onPressed: () async {
                      try {
                        await ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(deal.id);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not update favorite.'),
                            ),
                          );
                        }
                      }
                    },
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
                    const SizedBox(height: 4),
                    PriceSparkline(productId: deal.id, height: 30),
                    const Spacer(),
                    PriceDisplay(
                      currencyState: currencyState,
                      displayPrice: displayPrice ?? deal.currentPrice,
                      targetCurrency: currency ?? deal.currency,
                      displayOriginalPrice: deal.originalPrice,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

