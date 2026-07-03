import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'deals_notifier.dart';
import '../../settings/presentation/deal_card_skeleton.dart';
import 'recently_viewed_sliver.dart';
import 'deal_slivers.dart';
import 'feed_page.dart';

part 'deals_page.g.dart';

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';
  void update(String value) => state = value;
}

@riverpod
class SortOrder extends _$SortOrder {
  @override
  DealSort build() => DealSort.relevance;
  void update(DealSort value) => state = value;
}

@riverpod
class Category extends _$Category {
  @override
  String build() => 'All';
  void update(String value) => state = value;
}

@riverpod
({String query, DealSort sort, String category}) dealsFilter(Ref ref) {
  return (
    query: ref.watch(searchQueryProvider),
    sort: ref.watch(sortOrderProvider),
    category: ref.watch(categoryProvider),
  );
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
    final dealsAsync = ref.watch(dealsProvider(filter.query, filter.sort));
    final dealsState = dealsAsync.value;
    final category = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Deals'),
        actions: [
          PopupMenuButton<DealSort>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              ref.read(sortOrderProvider.notifier).update(sort);
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
                          ref.read(categoryProvider.notifier).update(cat);
                          // Improvement 7: scroll selected chip into view
                          if (_chipScrollController.hasClients) {
                            _chipScrollController.animateTo(
                              index * 100.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
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
          ref.invalidate(dealsProvider(filter.query, filter.sort));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // --- Recently Viewed Section ---
            const RecentlyViewedSliver(),
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
      ref.read(dealsProvider(filter.query, filter.sort).notifier).fetchNextPage();
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
      ref.read(searchQueryProvider.notifier).update(query.trim());
    });
    // Improvement 6: ValueNotifier update — no full rebuild
    _showClear.value = query.isNotEmpty;
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).update('');
    _showClear.value = false;
  }
}
