// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trending_drops_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The biggest price drops over the last 24h (see `/api/deals/biggest-drops`
/// in api.py), used for the "Biggest Price Drops" shelf. The endpoint
/// returns the 24h-ago price under the same `retail_price` JSON key
/// /api/products uses for a product's list price, so it decodes straight
/// into [Deal] and its `discountPercent` getter reads as the size of the
/// drop with no extra plumbing.
///
/// When a category filter is active on the feed, this shelf follows it —
/// showing the biggest drops *within that category* rather than site-wide,
/// so picking "Audio" surfaces audio price drops instead of whatever's
/// dropped the most across the entire catalog.

@ProviderFor(trendingDrops)
final trendingDropsProvider = TrendingDropsProvider._();

/// The biggest price drops over the last 24h (see `/api/deals/biggest-drops`
/// in api.py), used for the "Biggest Price Drops" shelf. The endpoint
/// returns the 24h-ago price under the same `retail_price` JSON key
/// /api/products uses for a product's list price, so it decodes straight
/// into [Deal] and its `discountPercent` getter reads as the size of the
/// drop with no extra plumbing.
///
/// When a category filter is active on the feed, this shelf follows it —
/// showing the biggest drops *within that category* rather than site-wide,
/// so picking "Audio" surfaces audio price drops instead of whatever's
/// dropped the most across the entire catalog.

final class TrendingDropsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Deal>>,
          List<Deal>,
          FutureOr<List<Deal>>
        >
    with $FutureModifier<List<Deal>>, $FutureProvider<List<Deal>> {
  /// The biggest price drops over the last 24h (see `/api/deals/biggest-drops`
  /// in api.py), used for the "Biggest Price Drops" shelf. The endpoint
  /// returns the 24h-ago price under the same `retail_price` JSON key
  /// /api/products uses for a product's list price, so it decodes straight
  /// into [Deal] and its `discountPercent` getter reads as the size of the
  /// drop with no extra plumbing.
  ///
  /// When a category filter is active on the feed, this shelf follows it —
  /// showing the biggest drops *within that category* rather than site-wide,
  /// so picking "Audio" surfaces audio price drops instead of whatever's
  /// dropped the most across the entire catalog.
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

String _$trendingDropsHash() => r'8f07d1fc6cc5604d84435aac90084ed74edf1d99';
