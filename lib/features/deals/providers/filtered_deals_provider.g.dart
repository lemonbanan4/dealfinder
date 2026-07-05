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

String _$filteredDealsHash() => r'099ebde9eb588e8699fbdef0c086552e136b9c6a';
