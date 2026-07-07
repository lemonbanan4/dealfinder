// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtered_deals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$filteredDealsHash() => r'0379aefa476585fdfc467b549b5e743b454ba31c';

/// Client-side pagination over [filteredDealsProvider] — used whenever a
/// search/category/favorites filter is active, since category matching is a
/// client-only heuristic (see `product_category.dart`) the API can't apply,
/// so the server can't paginate a filtered result set for us.

@ProviderFor(filteredDealsPage)
final filteredDealsPageProvider = FilteredDealsPageProvider._();

/// Client-side pagination over [filteredDealsProvider] — used whenever a
/// search/category/favorites filter is active, since category matching is a
/// client-only heuristic (see `product_category.dart`) the API can't apply,
/// so the server can't paginate a filtered result set for us.

final class FilteredDealsPageProvider
    extends
        $FunctionalProvider<
          FilteredDealsPage,
          FilteredDealsPage,
          FilteredDealsPage
        >
    with $Provider<FilteredDealsPage> {
  /// Client-side pagination over [filteredDealsProvider] — used whenever a
  /// search/category/favorites filter is active, since category matching is a
  /// client-only heuristic (see `product_category.dart`) the API can't apply,
  /// so the server can't paginate a filtered result set for us.
  FilteredDealsPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredDealsPageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredDealsPageHash();

  @$internal
  @override
  $ProviderElement<FilteredDealsPage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FilteredDealsPage create(Ref ref) {
    return filteredDealsPage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilteredDealsPage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilteredDealsPage>(value),
    );
  }
}

String _$filteredDealsPageHash() => r'4c748b51430496a843feca620b2860d53d5a5cf3';
