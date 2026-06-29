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
  final bool hasPaginationError;
  final VoidCallback? onRetry;

  const DealsSliver({
    super.key,
    required this.deals,
    required this.onFavoriteTap,
    required this.view,
    this.isLoading = false,
    this.isLoadingMore = false,
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
            icon: (favorites.asData?.value.contains(deal.id) ?? false)
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
      return SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).size.width / 200)
              .floor()
              .clamp(1, 4),
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
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

  void _onDealTap(WidgetRef ref, Deal deal) {
    ref.read(recentlyViewedProvider.notifier).addDeal(deal.id);
    launchUrl(Uri.parse(deal.url), mode: LaunchMode.externalApplication);
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
      return SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).size.width / 200)
              .floor()
              .clamp(1, 4),
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) =>
            const _ShimmerDealCard(view: DealCardView.grid),
      );
    } else {
      return SliverList.separated(
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
      child: _shimmerContainer(height: 192),
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
