import 'dart:async';

import 'package:dealfinder_pro/features/deals/presentation/deals_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/deal.dart';
import '../data/deals_repository.dart';

part 'deals_notifier.g.dart';

/// Defines the available sorting options for the deals list.
enum DealSort { relevance, priceAsc, priceDesc }

/// Represents the state of the deals list, including the list of deals,
/// whether more deals are available, and the current page.
class DealsState {
  const DealsState({this.deals = const [], this.hasMore = true, this.page = 1});

  final List<Deal> deals;
  final bool hasMore;
  final int page;

  DealsState copyWith({List<Deal>? deals, bool? hasMore, int? page}) {
    return DealsState(
      deals: deals ?? this.deals,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }

  // Improvement 2: proper equality so Riverpod skips redundant rebuilds
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DealsState &&
          runtimeType == other.runtimeType &&
          hasMore == other.hasMore &&
          page == other.page &&
          deals.length == other.deals.length;

  @override
  int get hashCode => Object.hash(deals.length, hasMore, page);
}

@riverpod
class DealsNotifier extends _$DealsNotifier {
  @override
  Future<DealsState> build(String query, DealSort sort) async {
    final category = ref.watch(categoryProvider);
    final deals = await ref
        .watch(dealsRepositoryProvider)
        .fetchDeals(page: 1, query: query, sort: sort, category: category);
    return DealsState(deals: deals, page: 1, hasMore: deals.length == 20);
  }

  Future<void> fetchNextPage() async {
    // Bug 4 fix: guard against null state.value (when state is error or loading)
    if (state.isLoading || !(state.value?.hasMore ?? false)) return;

    state = const AsyncLoading<DealsState>().copyWithPrevious(state);

    final category = ref.read(categoryProvider);
    final currentValue = state.value;
    if (currentValue == null) return;

    final nextPage = currentValue.page + 1;
    final newDeals = await ref
        .read(dealsRepositoryProvider)
        .fetchDeals(
          page: nextPage,
          query: query,
          sort: sort,
          category: category,
        );

    state = AsyncData(
      currentValue.copyWith(
        deals: [...currentValue.deals, ...newDeals],
        page: nextPage,
        hasMore: newDeals.length == 20,
      ),
    );
  }
}
