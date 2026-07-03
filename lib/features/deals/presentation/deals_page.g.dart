// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deals_page.dart';

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

String _$searchQueryHash() => r'9f97403b5659152608c0dbc158267442c72403bc';

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

@ProviderFor(SortOrder)
final sortOrderProvider = SortOrderProvider._();

final class SortOrderProvider extends $NotifierProvider<SortOrder, DealSort> {
  SortOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortOrderHash();

  @$internal
  @override
  SortOrder create() => SortOrder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DealSort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DealSort>(value),
    );
  }
}

String _$sortOrderHash() => r'47ddc81b1f2c1203f110abd6faa3186f99c78cc4';

abstract class _$SortOrder extends $Notifier<DealSort> {
  DealSort build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DealSort, DealSort>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DealSort, DealSort>,
              DealSort,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Category)
final categoryProvider = CategoryProvider._();

final class CategoryProvider extends $NotifierProvider<Category, String> {
  CategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryHash();

  @$internal
  @override
  Category create() => Category();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$categoryHash() => r'f7528853c91f5cf67c982ca8aa7529ba756b8423';

abstract class _$Category extends $Notifier<String> {
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

@ProviderFor(dealsFilter)
final dealsFilterProvider = DealsFilterProvider._();

final class DealsFilterProvider
    extends
        $FunctionalProvider<
          ({String category, String query, DealSort sort}),
          ({String category, String query, DealSort sort}),
          ({String category, String query, DealSort sort})
        >
    with $Provider<({String category, String query, DealSort sort})> {
  DealsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealsFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealsFilterHash();

  @$internal
  @override
  $ProviderElement<({String category, String query, DealSort sort})>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ({String category, String query, DealSort sort}) create(Ref ref) {
    return dealsFilter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({String category, String query, DealSort sort}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({String category, String query, DealSort sort})>(
            value,
          ),
    );
  }
}

String _$dealsFilterHash() => r'427a6b33c4401088aedafe0565ac90ac55cca6f0';
