import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/deal_card.dart';
import '../../settings/presentation/top_deals_shimmer.dart';
import '../domain/deal.dart';
import '../providers/recently_viewed_provider.dart';

class HorizontalDealSliver extends ConsumerWidget {
  const HorizontalDealSliver({
    super.key,
    required this.dealsProvider,
    required this.header,
    required this.view,
  });

  final dynamic dealsProvider;
  final Widget header;
  final DealCardView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(dealsProvider) as AsyncValue<List<Deal>>;

    return dealsAsync.when(
      loading: () => const TopDealsShimmer(),
      error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      data: (deals) {
        if (deals.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              _DealSliverContent(deals: deals, view: view),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Grid-mode tiles (e.g. "Insane Deals") host the wide, horizontal `_GridCard`
// row layout (thumbnail + title/source/sparkline/price + action-button
// column) — this needs to stay wide enough for that content or it'll
// overflow, unlike the old vertical image-on-top layout these were sized for.
const _gridTileWidth = 280.0;
const _gridTileHeight = 180.0;

// List-mode tiles (e.g. "Recently Viewed") host `DealCard`'s horizontal list
// layout (110x110 image + Expanded title/source/sparkline/price column). A
// `ListView` only bounds its cross-axis (height here, since this scrolls
// horizontally) — each item MUST bring its own fixed width, or the card's
// internal `Expanded` gets an unbounded width constraint and throws.
const _listTileWidth = 320.0;
const _listTileHeight = 140.0;

class _DealSliverContent extends ConsumerWidget {
  const _DealSliverContent({required this.deals, required this.view});
  final List<Deal> deals;
  final DealCardView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = view == DealCardView.grid;

    // For grid, calculate height dynamically based on available width
    double containerHeight = _listTileHeight + 20; // Default for list view
    if (isGrid) {
      final screenWidth = MediaQuery.of(context).size.width;
      const horizontalPadding = 16.0;
      const spacing = 10.0;
      final availableWidth = screenWidth - (horizontalPadding * 2);
      final crossAxisCount =
          ((availableWidth + spacing) ~/ (_gridTileWidth + spacing)).clamp(1, 10);
      final rowCount = (deals.length / crossAxisCount).ceil();
      containerHeight =
          rowCount * _gridTileHeight + (rowCount - 1) * spacing + 20;
    }

    return SizedBox(
      height: containerHeight,
      child: isGrid
          ? _DealGridView(deals: deals)
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: deals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: _listTileWidth,
                child: DealCard(
                  deal: deals[index],
                  view: view,
                  onTap: () {
                    ref
                        .read(recentlyViewedProvider.notifier)
                        .addDeal(deals[index].id);
                    launchUrl(
                      Uri.parse(deals[index].url),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class _DealGridView extends ConsumerWidget {
  const _DealGridView({required this.deals});
  final List<Deal> deals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double horizontalPadding = 16.0;
        const double spacing = 10.0;

        final crossAxisCount =
            ((constraints.maxWidth - horizontalPadding * 2 + spacing) ~/
            (_gridTileWidth + spacing)).clamp(1, 10);

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 10,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: _gridTileWidth / _gridTileHeight,
          ),
          itemCount: deals.length,
          itemBuilder: (context, index) => DealCard(
            deal: deals[index],
            view: DealCardView.grid,
            onTap: () {
              ref
                  .read(recentlyViewedProvider.notifier)
                  .addDeal(deals[index].id);
              launchUrl(
                Uri.parse(deals[index].url),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        );
      },
    );
  }
}
