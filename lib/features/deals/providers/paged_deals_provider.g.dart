// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_deals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The feed grid's current 1-indexed page. Resets to 1 whenever the region
/// or any filter changes — a new search/category/region should always start
/// from the top, since a page number from the old result set may no longer
/// exist (or mean something different) in the new one.

@ProviderFor(FeedPageIndex)
final feedPageIndexProvider = FeedPageIndexProvider._();

/// The feed grid's current 1-indexed page. Resets to 1 whenever the region
/// or any filter changes — a new search/category/region should always start
/// from the top, since a page number from the old result set may no longer
/// exist (or mean something different) in the new one.
final class FeedPageIndexProvider
    extends $NotifierProvider<FeedPageIndex, int> {
  /// The feed grid's current 1-indexed page. Resets to 1 whenever the region
  /// or any filter changes — a new search/category/region should always start
  /// from the top, since a page number from the old result set may no longer
  /// exist (or mean something different) in the new one.
  FeedPageIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedPageIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedPageIndexHash();

  @$internal
  @override
  FeedPageIndex create() => FeedPageIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$feedPageIndexHash() => r'2d30b9cd66798328185bc1e882b32be101a07e05';

/// The feed grid's current 1-indexed page. Resets to 1 whenever the region
/// or any filter changes — a new search/category/region should always start
/// from the top, since a page number from the old result set may no longer
/// exist (or mean something different) in the new one.

abstract class _$FeedPageIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Server-side paginated fetch of a single grid page, used for the default
/// browse state (no active search/category/favorites filter — see
/// `_isPagedBrowseMode` in feed_page.dart). Filtered views instead paginate
/// client-side over the full, already-fetched catalog (`dealFeedProvider`),
/// since category/favorites matching is client-only logic the API doesn't
/// know how to apply.

@ProviderFor(pagedDeals)
final pagedDealsProvider = PagedDealsProvider._();

/// Server-side paginated fetch of a single grid page, used for the default
/// browse state (no active search/category/favorites filter — see
/// `_isPagedBrowseMode` in feed_page.dart). Filtered views instead paginate
/// client-side over the full, already-fetched catalog (`dealFeedProvider`),
/// since category/favorites matching is client-only logic the API doesn't
/// know how to apply.

final class PagedDealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PagedDealsResult>,
          PagedDealsResult,
          FutureOr<PagedDealsResult>
        >
    with $FutureModifier<PagedDealsResult>, $FutureProvider<PagedDealsResult> {
  /// Server-side paginated fetch of a single grid page, used for the default
  /// browse state (no active search/category/favorites filter — see
  /// `_isPagedBrowseMode` in feed_page.dart). Filtered views instead paginate
  /// client-side over the full, already-fetched catalog (`dealFeedProvider`),
  /// since category/favorites matching is client-only logic the API doesn't
  /// know how to apply.
  PagedDealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pagedDealsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pagedDealsHash();

  @$internal
  @override
  $FutureProviderElement<PagedDealsResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PagedDealsResult> create(Ref ref) {
    return pagedDeals(ref);
  }
}

String _$pagedDealsHash() => r'c2c7d02eb229328f6048fce3f5c17cf7249fac63';
