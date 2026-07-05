import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/deal_card.dart';
import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/deal.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/favorites_provider.dart';

/// A single, reusable sliver that renders deals in the responsive 2-column
/// grid used throughout the feed.
class DealsSliver extends ConsumerWidget {
  final List<Deal> deals;
  final bool isLoading;
  final bool isLoadingMore;
  final void Function(Deal) onFavoriteTap;
  final bool isEmpty;
  final Object? error;
  final bool hasPaginationError;
  final VoidCallback? onRetry;

  const DealsSliver({
    super.key,
    required this.deals,
    required this.onFavoriteTap,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isEmpty = false,
    this.error,
    this.hasPaginationError = false,
    this.onRetry,
  });

  bool get _showError => hasPaginationError && !isLoadingMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return _buildShimmer(context);
    }

    if (error != null && deals.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Something went wrong:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No deals found.\nTry a different search or category!',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final favorites = ref.watch(favoritesProvider);
    final settings = ref.watch(appSettingsProvider);
    final targetCurrency = settings.displayCurrency;
    final converter = ref.watch(currencyConverterProvider.notifier);

    Widget itemBuilder(BuildContext context, int index) {
      final deal = deals[index];
      final displayPrice = converter.convert(
        deal.currentPrice,
        deal.currency,
        targetCurrency,
      );

      return DealCard(
        view: DealCardView.grid,
        deal: deal,
        displayPrice: displayPrice,
        currency: targetCurrency,
        onTap: () {
          _onDealTap(ref, deal);
        },
        trailingActions: [
          IconButton(
            icon: (favorites.value?.contains(deal.id) ?? false)
                ? Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.error,
                  )
                : const Icon(Icons.favorite_border),
            onPressed: () => onFavoriteTap(deal),
          ),
        ],
      );
    }

    return responsiveDealGrid(
      itemCount: deals.length + (isLoadingMore || _showError ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == deals.length) {
          return _buildBottomWidget(context);
        }
        return itemBuilder(context, index);
      },
    );
  }

  Widget _buildBottomWidget(BuildContext context) {
    if (_showError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load more deals.'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  // Bug 7 fix: await launchUrl and handle errors gracefully
  Future<void> _onDealTap(WidgetRef ref, Deal deal) async {
    ref.read(recentlyViewedProvider.notifier).addDeal(deal.id);
    final uri = Uri.tryParse(deal.url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // URL could not be launched (no browser or invalid scheme) — fail silently
    }
  }

  Widget _buildShimmer(BuildContext context) {
    const itemCount = 8;
    return responsiveDealGrid(
      itemCount: itemCount,
      itemBuilder: (context, index) => const _ShimmerDealCard(),
    );
  }
}

class _ShimmerDealCard extends StatelessWidget {
  const _ShimmerDealCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surfaceBright;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: const _GridShimmer(),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // No fixed height: the SliverGrid's mainAxisExtent (see
      // [responsiveDealGrid]) already gives this tile a tight size.
      child: _shimmerContainer(),
    );
  }
}

Widget _shimmerContainer({double? width, double? height}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

/// Shared grid for every deal grid (real + shimmer): a centered, max-3-column
/// layout per the design system. `SliverLayoutBuilder` reads the sliver's
/// actual available width (not the full viewport) so this responds correctly
/// even when nested inside a narrower centered/padded region.
Widget responsiveDealGrid({
  required int itemCount,
  required NullableIndexedWidgetBuilder itemBuilder,
}) {
  return SliverLayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.crossAxisExtent;
      // Capped at 2 (not 3): at 3-up, card images were cramped. Wider cards
      // also get a taller image area (see _GridCard in deal_card.dart) so
      // they don't just stretch a short image across more width.
      final columns = width >= 420 ? 2 : 1;
      return SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          // Cards are now a horizontal row (thumbnail + details), matching
          // the reference design — much shorter than the old image-on-top
          // layout, hence the smaller fixed extent.
          mainAxisExtent: 160,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    },
  );
}
