// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trending_drops_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The 3 products with the biggest price drop over the last 24h (see
/// `/api/deals/biggest-drops` in api.py), used for the "Biggest Price Drops"
/// shelf. The endpoint returns the 24h-ago price under the same
/// `retail_price` JSON key /api/products uses for a product's list price, so
/// it decodes straight into [Deal] and its `discountPercent` getter reads as
/// the size of the drop with no extra plumbing.

@ProviderFor(trendingDrops)
final trendingDropsProvider = TrendingDropsProvider._();

/// The 3 products with the biggest price drop over the last 24h (see
/// `/api/deals/biggest-drops` in api.py), used for the "Biggest Price Drops"
/// shelf. The endpoint returns the 24h-ago price under the same
/// `retail_price` JSON key /api/products uses for a product's list price, so
/// it decodes straight into [Deal] and its `discountPercent` getter reads as
/// the size of the drop with no extra plumbing.

final class TrendingDropsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Deal>>,
          List<Deal>,
          FutureOr<List<Deal>>
        >
    with $FutureModifier<List<Deal>>, $FutureProvider<List<Deal>> {
  /// The 3 products with the biggest price drop over the last 24h (see
  /// `/api/deals/biggest-drops` in api.py), used for the "Biggest Price Drops"
  /// shelf. The endpoint returns the 24h-ago price under the same
  /// `retail_price` JSON key /api/products uses for a product's list price, so
  /// it decodes straight into [Deal] and its `discountPercent` getter reads as
  /// the size of the drop with no extra plumbing.
  TrendingDropsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trendingDropsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trendingDropsHash();

  @$internal
  @override
  $FutureProviderElement<List<Deal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Deal>> create(Ref ref) {
    return trendingDrops(ref);
  }
}

String _$trendingDropsHash() => r'c0c9d2c9eaec35f058312888e69af1363a6e7064';
