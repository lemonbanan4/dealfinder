import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/deals/domain/deal.dart';
import '../features/deals/domain/store_display_names.dart';
import '../features/deals/presentation/price_alert_bottom_sheet.dart';
import '../features/deals/providers/favorites_provider.dart';
import '../features/settings/presentation/currency_provider.dart';
import '../theme/glass_colors.dart';
import '../utils/formatters.dart';
import 'glass_card.dart';
import 'price_display.dart';
import 'price_sparkline.dart';

enum DealCardView { grid, list }

class DealCard extends ConsumerWidget {
  const DealCard({
    super.key,
    required this.deal,
    this.view = DealCardView.list,
    // These are optional because for horizontal cards, the price is calculated inside
    this.displayPrice,
    this.displayOriginalPrice,
    this.currency,
    this.trailingActions,
    required this.onTap,
  });

  final Deal deal;
  final DealCardView view;
  final double? displayPrice;
  final double? displayOriginalPrice;
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
        displayOriginalPrice: displayOriginalPrice,
        currency: currency,
        trailingActions: trailingActions,
      );
    }

    // LIST VIEW
    return GlassCard(
      borderRadius: 16,
      onTap: onTap,
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
                      memCacheWidth: 220,
                      memCacheHeight: 220,
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  storeDisplayName(deal.source),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                PriceSparkline(productId: deal.id, height: 24),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${formatAmount(displayPrice ?? deal.currentPrice)} ${currency ?? deal.currency}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: GlassColors.priceAccent,
                      ),
                    ),
                    if ((displayOriginalPrice ?? deal.originalPrice) != null &&
                        (displayPrice ?? deal.currentPrice) <
                            (displayOriginalPrice ?? deal.originalPrice)!)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 2),
                        child: Text(
                          '${formatAmount((displayOriginalPrice ?? deal.originalPrice)!)} ${currency ?? deal.currency}',
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
    this.displayOriginalPrice,
    this.currency,
    this.trailingActions,
  });
  final Deal deal;
  final VoidCallback onTap;
  final double? displayPrice;
  final double? displayOriginalPrice;
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

    return GlassCard(
      borderRadius: 12,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail + discount badge ────────────────────────────────
          Stack(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: deal.imageUrl != null && deal.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: deal.imageUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 200,
                          memCacheHeight: 200,
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
              ),
              if (pct > 0)
                Positioned(
                  top: 4,
                  left: 4,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // ── Details: title, source, full-width sparkline, price ───────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  storeDisplayName(deal.source),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                PriceSparkline(productId: deal.id, height: 28),
                const SizedBox(height: 6),
                PriceDisplay(
                  currencyState: currencyState,
                  displayPrice: displayPrice ?? deal.currentPrice,
                  targetCurrency: currency ?? deal.currency,
                  displayOriginalPrice:
                      displayOriginalPrice ?? deal.originalPrice,
                ),
                const SizedBox(height: 8),
                _GetDealButton(onPressed: onTap),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // ── Action cluster: favorite, copy link, alert ────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CardActionButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                iconColor: isFavorite ? GlassColors.priceAccent : Colors.white,
                tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
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
              const SizedBox(height: 6),
              _CardActionButton(
                icon: Icons.copy_outlined,
                tooltip: 'Copy link',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: deal.url));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                  }
                },
              ),
              const SizedBox(height: 6),
              _CardActionButton(
                icon: Icons.notification_add_outlined,
                tooltip: 'Set price alert',
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => PriceAlertBottomSheet(deal: deal),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The primary, explicit call-to-action on a grid deal card. Previously the
/// only way to act on a deal was tapping anywhere on the card — this makes
/// that action visible and legible rather than implicit.
class _GetDealButton extends StatelessWidget {
  const _GetDealButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [GlassColors.blue500, GlassColors.indigo600],
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: onPressed,
            child: const Center(
              child: Text(
                'Get Deal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small circular glass icon button used in the deal card's floating
/// action cluster (favorite, copy link, price alert) — a translucent dark
/// backdrop keeps the icon legible over any product photo.
class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        iconSize: 18,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
