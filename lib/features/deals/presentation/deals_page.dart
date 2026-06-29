import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/deal.dart';
import '../data/deals_repository.dart';
import 'feed_page.dart';
import 'deal_slivers.dart';

const _dealsPerPage = 20;

@immutable
class DealsState {
  const DealsState({
    this.deals = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
  });

  final List<Deal> deals;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;
  final bool hasMore;

  DealsState copyWith({
    List<Deal>? deals,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
    bool? hasMore,
  }) {
    return DealsState(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class DealsNotifier extends Notifier<DealsState> {
  @override
  DealsState build() {
    // Fetch the first page of deals when the provider is initialized.
    _fetchDeals();
    return const DealsState(isLoading: true);
  }

  Future<void> _fetchDeals({bool isRefresh = false}) async {
    final dealsRepository = ref.read(dealsRepositoryProvider);
    try {
      final deals = await dealsRepository.fetchDeals(page: 1);
      state = DealsState(deals: deals, hasMore: deals.length == _dealsPerPage);
    } catch (e, stack) {
      state = DealsState(error: e);
      debugPrintStack(stackTrace: stack, label: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    // Avoid fetching more if we are already loading or have no more deals.
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final dealsRepository = ref.read(dealsRepositoryProvider);
    try {
      final page = (state.deals.length / _dealsPerPage).floor() + 1;
      final newDeals = await dealsRepository.fetchDeals(page: page);
      state = state.copyWith(
        deals: [...state.deals, ...newDeals],
        hasMore: newDeals.length == _dealsPerPage,
        isLoadingMore: false,
      );
    } catch (e, stack) {
      // In case of an error, stop trying to load more.
      state = state.copyWith(error: e, hasMore: false, isLoadingMore: false);
      debugPrintStack(stackTrace: stack, label: e.toString());
    }
  }

  Future<void> refresh() async {
    state = const DealsState(isLoading: true);
    await _fetchDeals(isRefresh: true);
  }
}

final dealsProvider = NotifierProvider.autoDispose<DealsNotifier, DealsState>(
  DealsNotifier.new,
);

/// A full-page example demonstrating how to use DealsSliver with a provider.
class DealsPage extends ConsumerStatefulWidget {
  const DealsPage({super.key});

  @override
  ConsumerState<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends ConsumerState<DealsPage> {
  // Local state to manage the view type (grid/list)
  FeedView _feedView = FeedView.list;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(dealsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a listener to show a SnackBar on errors during pagination.
      body: Scaffold(
        appBar: AppBar(
          title: const Text('Today\'s Deals'),
          actions: [
            // Toggle button for grid/list view
            IconButton(
              icon: Icon(
                _feedView == FeedView.list ? Icons.grid_view : Icons.view_list,
              ),
              onPressed: () {
                setState(() {
                  _feedView = _feedView == FeedView.list
                      ? FeedView.grid
                      : FeedView.list;
                });
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(dealsProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            // Add a physics that allows scrolling when the list is short
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Use a SliverPadding for consistent spacing.
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: Consumer(
                  builder: (context, ref, child) {
                    final dealsState = ref.watch(dealsProvider);

                    if (dealsState.isLoading && dealsState.deals.isEmpty) {
                      return DealsSliver(
                        deals: const [],
                        onFavoriteTap: (_) {},
                        view: _feedView,
                        isLoading: true,
                      );
                    }

                    if (dealsState.error != null && dealsState.deals.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 60,
                            ),
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Could not fetch deals.'),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.read(dealsProvider.notifier).refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return DealsSliver(
                      deals: dealsState.deals,
                      onFavoriteTap: (deal) {
                        debugPrint('Tapped favorite on ${deal.title}');
                      },
                      view: _feedView,
                      isLoadingMore: dealsState.isLoadingMore,
                      hasPaginationError:
                          dealsState.error != null &&
                          dealsState.deals.isNotEmpty,
                      onRetry: () =>
                          ref.read(dealsProvider.notifier).fetchNextPage(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
