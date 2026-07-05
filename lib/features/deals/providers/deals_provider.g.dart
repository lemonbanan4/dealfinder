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

String _$dealFeedNotifierHash() => r'e4b50cfce2d799cf45c45494dc24e25f86a7e797';

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
