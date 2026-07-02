import 'dart:async';

import 'package:dealfinder_pro/features/deals/domain/deal.dart';
import 'package:dealfinder_pro/features/deals/providers/recently_viewed_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../services/supabase_service.dart';
import 'deals_notifier.dart';
import 'widgets/deal_card_skeleton.dart';
import 'deal_slivers.dart';
import 'feed_page.dart';

// These providers control the filters for the deals list.
final searchQueryProvider = StateProvider<String>((ref) => '');
final sortOrderProvider = StateProvider<DealSort>((ref) => DealSort.relevance);
final categoryProvider = StateProvider<String>((ref) => 'All');

// Bug 5 fix: expose a combined filter state that can be watched/read cleanly
final dealsFilterProvider = Provider<({String query, DealSort sort, String category})>((ref) {
  return (
    query: ref.watch(searchQueryProvider),
    sort: ref.watch(sortOrderProvider),
    category: ref.watch(categoryProvider),
  );
});

/// Fetches the full Deal objects for the recently viewed deal IDs.
@riverpod
Stream<List<Deal>> recentlyViewedDeals(RecentlyViewedDealsRef ref) {
  final supabase = ref.watch(supabaseProvider);
  final recentlyViewedIds = ref.watch(recentlyViewedProvider);

  if (recentlyViewedIds.isEmpty) {
    return Stream.value([]);
  }

  // Bug 6 fix: correct primary key is 'product_id', not 'id'
  return supabase
      .from('products')
      .stream(primaryKey: ['product_id'])
      .in_('product_id', recentlyViewedIds)
      .map((dealMaps) => dealMaps.map(Deal.fromJson).toList());
}

/// Static list of categories for the filter bar.
const List<String> dealCategories = [
  'All',
  'Laptops/PC',
  'PC Accessories',
  'Home Electronics',
  'Vacuum Cleaners',
];

class DealsPage extends ConsumerStatefulWidget {
  const DealsPage({super.key});

  @override
  ConsumerState<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends ConsumerState<DealsPage> {
  final _searchController = TextEditingController();
  // Improvement 6: ValueNotifier instead of setState for clear-button visibility
  late final ValueNotifier<bool> _showClear;
  Timer? _debounce;
  final _scrollController = ScrollController();
  // Improvement 7: scroll controller for category chip bar
  final _chipScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _showClear = ValueNotifier(false);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _showClear.dispose();
    _chipScrollController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bug 5 fix: use the correct parametrised provider
    final filter = ref.watch(dealsFilterProvider);
    final dealsAsync = ref.watch(dealsNotifierProvider(filter.query, filter.sort));
    final dealsState = dealsAsync.valueOrNull;
    final category = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Deals'),
        actions: [
          PopupMenuButton<DealSort>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              ref.read(sortOrderProvider.notifier).state = sort;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DealSort.relevance,
                child: Text('Relevance'),
              ),
              const PopupMenuItem(
                value: DealSort.priceAsc,
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: DealSort.priceDesc,
                child: Text('Price: High to Low'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 50),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ValueListenableBuilder<bool>(
                  // Improvement 6: no setState rebuild for just show/hide clear
                  valueListenable: _showClear,
                  builder: (context, showClear, _) => TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search deals...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: showClear
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  controller: _chipScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: dealCategories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = dealCategories[index];
                    return ChoiceChip(
                      label: Text(cat),
                      selected: category == cat,
                      onSelected: (isSelected) {
                        if (isSelected) {
                          ref.read(categoryProvider.notifier).state = cat;
                          // Improvement 7: scroll selected chip into view
                          _chipScrollController.animateTo(
                            index * 100.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ], // Bug 3 fix: was `)` here instead of `]`
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          // Bug 5 fix: invalidate the correct parametrised provider
          ref.invalidate(dealsNotifierProvider(filter.query, filter.sort));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // --- Recently Viewed Section ---
            ref.watch(recentlyViewedDealsProvider).when(
                  data: (recentDeals) {
                    if (recentDeals.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return RecentlyViewedSliver(deals: recentDeals);
                  },
                  loading: () =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                  error: (e, s) =>
                      const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
            // --- Loading shimmer on first load ---
            if (dealsAsync.isLoading && (dealsState?.deals.isEmpty ?? true))
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const DealCardSkeleton(),
                  childCount: 5,
                ),
              ),
            // --- Error on first load ---
            if (dealsAsync.hasError && (dealsState?.deals.isEmpty ?? true))
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load deals: ${dealsAsync.error}'),
                  ),
                ),
              ),
            DealsSliver(
              deals: dealsState?.deals ?? [],
              isEmpty: (dealsState?.deals.isEmpty ?? true) && !dealsAsync.isLoading,
              view: FeedView.list,
              onFavoriteTap: (deal) {},
              isLoadingMore: dealsAsync.isLoading && (dealsState?.deals.isNotEmpty ?? false),
            ),
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    if (_isBottom) {
      final filter = ref.read(dealsFilterProvider);
      ref.read(dealsNotifierProvider(filter.query, filter.sort).notifier).fetchNextPage();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger loading when we are 90% of the way to the bottom.
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query.trim();
    });
    // Improvement 6: ValueNotifier update — no full rebuild
    _showClear.value = query.isNotEmpty;
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _showClear.value = false;
  }
}
