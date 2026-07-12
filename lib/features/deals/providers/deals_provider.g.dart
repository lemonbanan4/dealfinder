// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DealFeedNotifier)
final dealFeedProvider = DealFeedNotifierProvider._();

final class DealFeedNotifierProvider
    extends $AsyncNotifierProvider<DealFeedNotifier, List<Deal>> {
  DealFeedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dealFeedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dealFeedNotifierHash();

  @$internal
  @override
  DealFeedNotifier create() => DealFeedNotifier();
}

String _$dealFeedNotifierHash() => r'c331aec3ba5097a7f85aa674f079e3258fbfcdb8';

abstract class _$DealFeedNotifier extends $AsyncNotifier<List<Deal>> {
  FutureOr<List<Deal>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Deal>>, List<Deal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Deal>>, List<Deal>>,
              AsyncValue<List<Deal>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Deals discounted >= 25% off their own retail_price, sorted deepest first
/// (see `/api/deals/top-discounts` in api.py). Fetched directly rather than
/// derived from [dealFeedProvider]'s full catalog — that full-catalog fetch
/// is a 20MB+ response as the product count has grown, and this shelf only
/// ever needed a small, already-filtered slice of it.

@ProviderFor(topDeals)
final topDealsProvider = TopDealsProvider._();

/// Deals discounted >= 25% off their own retail_price, sorted deepest first
/// (see `/api/deals/top-discounts` in api.py). Fetched directly rather than
/// derived from [dealFeedProvider]'s full catalog — that full-catalog fetch
/// is a 20MB+ response as the product count has grown, and this shelf only
/// ever needed a small, already-filtered slice of it.

final class TopDealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Deal>>,
          List<Deal>,
          FutureOr<List<Deal>>
        >
    with $FutureModifier<List<Deal>>, $FutureProvider<List<Deal>> {
  /// Deals discounted >= 25% off their own retail_price, sorted deepest first
  /// (see `/api/deals/top-discounts` in api.py). Fetched directly rather than
  /// derived from [dealFeedProvider]'s full catalog — that full-catalog fetch
  /// is a 20MB+ response as the product count has grown, and this shelf only
  /// ever needed a small, already-filtered slice of it.
  TopDealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topDealsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topDealsHash();

  @$internal
  @override
  $FutureProviderElement<List<Deal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Deal>> create(Ref ref) {
    return topDeals(ref);
  }
}

String _$topDealsHash() => r'051adaadeadd84fa5539722ccf00052e18debbd3';

@ProviderFor(priceHistoryProvider)
final priceHistoryProviderProvider = PriceHistoryProviderFamily._();

final class PriceHistoryProviderProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FlSpot>>,
          List<FlSpot>,
          FutureOr<List<FlSpot>>
        >
    with $FutureModifier<List<FlSpot>>, $FutureProvider<List<FlSpot>> {
  PriceHistoryProviderProvider._({
    required PriceHistoryProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'priceHistoryProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$priceHistoryProviderHash();

  @override
  String toString() {
    return r'priceHistoryProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FlSpot>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FlSpot>> create(Ref ref) {
    final argument = this.argument as String;
    return priceHistoryProvider(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PriceHistoryProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$priceHistoryProviderHash() =>
    r'18f4bd2a7008ae7a27aefe7fdec4121a8173f5d5';

final class PriceHistoryProviderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FlSpot>>, String> {
  PriceHistoryProviderFamily._()
    : super(
        retry: null,
        name: r'priceHistoryProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PriceHistoryProviderProvider call(String productId) =>
      PriceHistoryProviderProvider._(argument: productId, from: this);

  @override
  String toString() => r'priceHistoryProviderProvider';
}
