// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'790bd96a8a13bb944767c7bf06a5378cfc78a54d';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Region)
final regionProvider = RegionProvider._();

final class RegionProvider extends $NotifierProvider<Region, String> {
  RegionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regionHash();

  @$internal
  @override
  Region create() => Region();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$regionHash() => r'fcce81a0ff582c3d50cb4d79dcf4345909d1c772';

abstract class _$Region extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FeedFiltersNotifier)
final feedFiltersProvider = FeedFiltersNotifierProvider._();

final class FeedFiltersNotifierProvider
    extends $NotifierProvider<FeedFiltersNotifier, FeedFilters> {
  FeedFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedFiltersNotifierHash();

  @$internal
  @override
  FeedFiltersNotifier create() => FeedFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedFilters>(value),
    );
  }
}

String _$feedFiltersNotifierHash() =>
    r'c50f275d83ed2ab00b6c7db2542e34ce6a81a9b3';

abstract class _$FeedFiltersNotifier extends $Notifier<FeedFilters> {
  FeedFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FeedFilters, FeedFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedFilters, FeedFilters>,
              FeedFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FeedViewMode)
final feedViewModeProvider = FeedViewModeProvider._();

final class FeedViewModeProvider extends $NotifierProvider<FeedViewMode, bool> {
  FeedViewModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedViewModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedViewModeHash();

  @$internal
  @override
  FeedViewMode create() => FeedViewMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$feedViewModeHash() => r'4608d08f102608db00c4c0abf908ffecfbcc020a';

abstract class _$FeedViewMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FavoritesNotifier)
final favoritesProvider = FavoritesNotifierProvider._();

final class FavoritesNotifierProvider
    extends $AsyncNotifierProvider<FavoritesNotifier, Set<String>> {
  FavoritesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesNotifierHash();

  @$internal
  @override
  FavoritesNotifier create() => FavoritesNotifier();
}

String _$favoritesNotifierHash() => r'27cf9a66299633e8cb94467d7a15a00882474b11';

abstract class _$FavoritesNotifier extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredDeals)
final filteredDealsProvider = FilteredDealsProvider._();

final class FilteredDealsProvider
    extends $FunctionalProvider<List<Deal>, List<Deal>, List<Deal>>
    with $Provider<List<Deal>> {
  FilteredDealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredDealsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredDealsHash();

  @$internal
  @override
  $ProviderElement<List<Deal>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Deal> create(Ref ref) {
    return filteredDeals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Deal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Deal>>(value),
    );
  }
}

String _$filteredDealsHash() => r'88964e8ecdcda5b62cc2f7092f24fdf850bfb4b4';
