import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/analytics_service.dart';
import '../../../services/share_service.dart';
import '../../../widgets/deal_card.dart';
import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/deal.dart';
import 'price_alert_bottom_sheet.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/favorites_provider.dart';
import 'feed_page.dart';

/// A single, reusable sliver that can render deals as either a grid or a list.
///
/// This widget replaces the previous `DealGridSliver` and `DealListSliver`
/// widgets, reducing code duplication. It dynamically builds either a
/// `SliverGrid` or a `SliverList` based on the `view` parameter.
class DealsSliver extends ConsumerWidget {
  final FeedView view;
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
    required this.view,
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
      return _buildShimmer(
        context,
        view == FeedView.grid ? DealCardView.grid : DealCardView.list,
      );
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
        view: view == FeedView.grid ? DealCardView.grid : DealCardView.list,
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
          if (view == FeedView.list)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _onShareTap(deal),
            ),
          if (view == FeedView.list)
            IconButton(
              icon: const Icon(Icons.notification_add_outlined),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => PriceAlertBottomSheet(deal: deal),
                );
              },
            ),
        ],
      );
    }

    if (view == FeedView.grid) {
      return responsiveDealGrid(
        itemCount: deals.length + (isLoadingMore || _showError ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == deals.length) {
            return _buildBottomWidget(context);
          }
          return itemBuilder(context, index);
        },
      );
    } else {
      return SliverMainAxisGroup(
        slivers: [
          SliverList.separated(
            itemCount: deals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: itemBuilder,
          ),
          if (isLoadingMore || _showError)
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverToBoxAdapter(child: _buildBottomWidget(context)),
            ),
        ],
      );
    }
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

  void _onShareTap(Deal deal) {
    AnalyticsService().logEvent(
      name: 'share_deal',
      parameters: {'deal_id': deal.id, 'deal_title': deal.title},
    );
    ShareService.shareDeal(title: deal.title, url: deal.url);
  }

  Widget _buildShimmer(BuildContext context, DealCardView view) {
    final isGridView = view == DealCardView.grid;
    const itemCount = 8;

    if (isGridView) {
      return responsiveDealGrid(
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            const _ShimmerDealCard(view: DealCardView.grid),
      );
    } else {
      return SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) =>
            const _ShimmerDealCard(view: DealCardView.list),
      );
    }
  }
}

class _ShimmerDealCard extends StatelessWidget {
  const _ShimmerDealCard({required this.view});

  final DealCardView view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surfaceBright;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: view == DealCardView.list
          ? const _ListShimmer()
          : const _GridShimmer(),
    );
  }
}

class _ListShimmer extends StatelessWidget {
  const _ListShimmer();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mimics the structure of the DealCard list view
            _shimmerContainer(width: 110, height: 110),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerContainer(height: 16, width: double.infinity),
                    const SizedBox(height: 6),
                    _shimmerContainer(height: 16, width: 200),
                    const SizedBox(height: 8),
                    _shimmerContainer(height: 12, width: 80),
                    const Spacer(),
                    Row(
                      children: [
                        _shimmerContainer(height: 20, width: 90),
                        const SizedBox(width: 8),
                        _shimmerContainer(height: 14, width: 60),
                      ],
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
      final columns = width >= 900 ? 3 : (width >= 620 ? 2 : 1);
      return SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: 280,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    },
  );
}
