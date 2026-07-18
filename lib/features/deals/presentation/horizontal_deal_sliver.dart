import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/deal_card.dart';
import '../../settings/presentation/currency_provider.dart';
import '../../settings/presentation/top_deals_shimmer.dart';
import '../../settings/providers/settings_provider.dart';
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
// 230 (not 180) — this hosts the same _GridCard as the main feed grid,
// whose mainAxisExtent needed the same +50 bump to fit the _GetDealButton
// CTA added later without clipping it (see responsiveDealGrid in
// deal_slivers.dart for the matching fix and its full explanation).
const _gridTileHeight = 230.0;

// List-mode tiles (e.g. "Recently Viewed") host `DealCard`'s horizontal list
// layout (110x110 image + Expanded title/source/sparkline/price column). A
// `ListView` only bounds its cross-axis (height here, since this scrolls
// horizontally) — each item MUST bring its own fixed width, or the card's
// internal `Expanded` gets an unbounded width constraint and throws.
const _listTileWidth = 320.0;
const _listTileHeight = 140.0;

class _DealSliverContent extends StatelessWidget {
  const _DealSliverContent({required this.deals, required this.view});
  final List<Deal> deals;
  final DealCardView view;

  @override
  Widget build(BuildContext context) {
    final isGrid = view == DealCardView.grid;

    // For grid, calculate height dynamically based on available width
    double containerHeight = _listTileHeight + 20; // Default for list view
    if (isGrid) {
      final screenWidth = MediaQuery.of(context).size.width;
      const horizontalPadding = 16.0;
      const spacing = 10.0;
      final availableWidth = screenWidth - (horizontalPadding * 2);
      final crossAxisCount =
          ((availableWidth + spacing) ~/ (_gridTileWidth + spacing)).clamp(
            1,
            10,
          );
      final rowCount = (deals.length / crossAxisCount).ceil();
      containerHeight =
          rowCount * _gridTileHeight + (rowCount - 1) * spacing + 20;
    }

    return SizedBox(
      height: containerHeight,
      child: isGrid
          ? _DealGridView(deals: deals)
          : _FadingHorizontalDealList(deals: deals, view: view),
    );
  }
}

/// A horizontally-scrolling row of [DealCard]s (used for "Recently Viewed")
/// whose leading/trailing edges fade to transparent instead of hard-clipping
/// a partially-visible card against the glass panel's edge. Each edge fade
/// only appears while there's actually more content to scroll to in that
/// direction, so a fully-scrolled-to-the-end list shows its last card at
/// full opacity rather than perpetually faded.
class _FadingHorizontalDealList extends ConsumerStatefulWidget {
  const _FadingHorizontalDealList({required this.deals, required this.view});

  final List<Deal> deals;
  final DealCardView view;

  @override
  ConsumerState<_FadingHorizontalDealList> createState() =>
      _FadingHorizontalDealListState();
}

const _edgeFadeWidth = 32.0;

class _FadingHorizontalDealListState
    extends ConsumerState<_FadingHorizontalDealList> {
  final _controller = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFades());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateFades);
    _controller.dispose();
    super.dispose();
  }

  void _updateFades() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final showLeft = position.pixels > 4;
    final showRight = position.pixels < position.maxScrollExtent - 4;
    if (showLeft != _showLeftFade || showRight != _showRightFade) {
      setState(() {
        _showLeftFade = showLeft;
        _showRightFade = showRight;
      });
    }
  }

  // A plain vertical mouse wheel doesn't drive a horizontal ListView on
  // Flutter web by default (only shift+wheel or a trackpad's horizontal
  // swipe do) — redirect vertical wheel deltas into horizontal scrolling
  // so this row responds to a normal mouse wheel too.
  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final delta = event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs()
        ? event.scrollDelta.dx
        : event.scrollDelta.dy;
    _controller.jumpTo(
      (_controller.position.pixels + delta).clamp(
        _controller.position.minScrollExtent,
        _controller.position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final targetCurrency = settings.displayCurrency;
    final converter = ref.watch(currencyConverterProvider.notifier);

    final list = ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: widget.deals.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final deal = widget.deals[index];
        return SizedBox(
          width: _listTileWidth,
          child: DealCard(
            deal: deal,
            view: widget.view,
            displayPrice: converter.convert(
              deal.currentPrice,
              deal.currency,
              targetCurrency,
            ),
            displayOriginalPrice: deal.originalPrice == null
                ? null
                : converter.convert(
                    deal.originalPrice!,
                    deal.currency,
                    targetCurrency,
                  ),
            currency: targetCurrency,
            onTap: () {
              ref.read(recentlyViewedProvider.notifier).addDeal(deal.id);
              launchUrl(
                Uri.parse(deal.url),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        );
      },
    );

    final fadedList = (!_showLeftFade && !_showRightFade)
        ? list
        : ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) {
              final leftStop = (_edgeFadeWidth / rect.width).clamp(0.01, 0.49);
              final rightStop = (1 - _edgeFadeWidth / rect.width).clamp(
                0.51,
                0.99,
              );
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _showLeftFade ? Colors.transparent : Colors.black,
                  Colors.black,
                  Colors.black,
                  _showRightFade ? Colors.transparent : Colors.black,
                ],
                stops: [0.0, leftStop, rightStop, 1.0],
              ).createShader(rect);
            },
            child: list,
          );

    return Listener(onPointerSignal: _handlePointerSignal, child: fadedList);
  }
}

class _DealGridView extends ConsumerWidget {
  const _DealGridView({required this.deals});
  final List<Deal> deals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final targetCurrency = settings.displayCurrency;
    final converter = ref.watch(currencyConverterProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        const double horizontalPadding = 16.0;
        const double spacing = 10.0;

        final crossAxisCount =
            ((constraints.maxWidth - horizontalPadding * 2 + spacing) ~/
                    (_gridTileWidth + spacing))
                .clamp(1, 10);

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
          itemBuilder: (context, index) {
            final deal = deals[index];
            return DealCard(
              deal: deal,
              view: DealCardView.grid,
              displayPrice: converter.convert(
                deal.currentPrice,
                deal.currency,
                targetCurrency,
              ),
              displayOriginalPrice: deal.originalPrice == null
                  ? null
                  : converter.convert(
                      deal.originalPrice!,
                      deal.currency,
                      targetCurrency,
                    ),
              currency: targetCurrency,
              onTap: () {
                ref.read(recentlyViewedProvider.notifier).addDeal(deal.id);
                launchUrl(
                  Uri.parse(deal.url),
                  mode: LaunchMode.externalApplication,
                );
              },
            );
          },
        );
      },
    );
  }
}
