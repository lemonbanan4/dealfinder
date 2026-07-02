import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/currency_provider.dart';
import 'local_favorites_notifier.dart';
import '../domain/deal.dart';

class DealDetailsPage extends ConsumerWidget {
  const DealDetailsPage({super.key, required this.deal});

  final Deal deal;

  Future<void> _openDealUrl() async {
    final uri = Uri.tryParse(deal.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formattedPrice = ref.watch(
      formattedPriceProvider(price: deal.currentPrice, currency: deal.currency),
    );
    final originalPrice = ref.watch(
      formattedPriceProvider(
        price: deal.originalPrice,
        currency: deal.currency,
      ),
    );

    final isFavorite = ref.watch(
      favoritesNotifierProvider.select(
        (favs) => favs.value?.contains(deal.id) ?? false,
      ),
    );

    return Scaffold(
      // Using CustomScrollView to create a collapsing app bar effect
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                deal.source,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  shadows: const [Shadow(blurRadius: 2, color: Colors.black54)],
                ),
              ),
              background: deal.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: deal.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(color: Colors.grey.shade300),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? theme.colorScheme.primary : null,
                ),
                onPressed: () => ref
                    .read(favoritesNotifierProvider.notifier)
                    .toggleFavorite(deal.id),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deal.title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        formattedPrice,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (deal.originalPrice != null &&
                          deal.originalPrice! > deal.currentPrice)
                        Text(
                          originalPrice,
                          style: theme.textTheme.titleLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const Spacer(),
                      if (deal.discountPercent != null &&
                          deal.discountPercent! > 0)
                        _DiscountBadge(discount: deal.discountPercent!),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openDealUrl,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View on Retailer Site'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
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

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.discount});

  final double discount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '-${discount.toStringAsFixed(0)}%',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
