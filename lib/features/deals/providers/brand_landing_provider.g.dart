// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_landing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deals for one brand landing page's store feed (see
/// `/api/deals/by-store` in api.py and `BrandLanding` in
/// `domain/brand_landing.dart`). Keyed by the exact `feed_region` value,
/// not the page slug, so it's a plain exact-match fetch with no guessing.

@ProviderFor(brandLandingDeals)
final brandLandingDealsProvider = BrandLandingDealsFamily._();

/// Deals for one brand landing page's store feed (see
/// `/api/deals/by-store` in api.py and `BrandLanding` in
/// `domain/brand_landing.dart`). Keyed by the exact `feed_region` value,
/// not the page slug, so it's a plain exact-match fetch with no guessing.

final class BrandLandingDealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Deal>>,
          List<Deal>,
          FutureOr<List<Deal>>
        >
    with $FutureModifier<List<Deal>>, $FutureProvider<List<Deal>> {
  /// Deals for one brand landing page's store feed (see
  /// `/api/deals/by-store` in api.py and `BrandLanding` in
  /// `domain/brand_landing.dart`). Keyed by the exact `feed_region` value,
  /// not the page slug, so it's a plain exact-match fetch with no guessing.
  BrandLandingDealsProvider._({
    required BrandLandingDealsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'brandLandingDealsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$brandLandingDealsHash();

  @override
  String toString() {
    return r'brandLandingDealsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Deal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Deal>> create(Ref ref) {
    final argument = this.argument as String;
    return brandLandingDeals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BrandLandingDealsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$brandLandingDealsHash() => r'60df7b3dc6aae760a44417b0b3c7f60138a973af';

/// Deals for one brand landing page's store feed (see
/// `/api/deals/by-store` in api.py and `BrandLanding` in
/// `domain/brand_landing.dart`). Keyed by the exact `feed_region` value,
/// not the page slug, so it's a plain exact-match fetch with no guessing.

final class BrandLandingDealsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Deal>>, String> {
  BrandLandingDealsFamily._()
    : super(
        retry: null,
        name: r'brandLandingDealsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Deals for one brand landing page's store feed (see
  /// `/api/deals/by-store` in api.py and `BrandLanding` in
  /// `domain/brand_landing.dart`). Keyed by the exact `feed_region` value,
  /// not the page slug, so it's a plain exact-match fetch with no guessing.

  BrandLandingDealsProvider call(String storeFeed) =>
      BrandLandingDealsProvider._(argument: storeFeed, from: this);

  @override
  String toString() => r'brandLandingDealsProvider';
}
