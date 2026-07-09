// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_viewed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecentlyViewedNotifier)
final recentlyViewedProvider = RecentlyViewedNotifierProvider._();

final class RecentlyViewedNotifierProvider
    extends $NotifierProvider<RecentlyViewedNotifier, List<String>> {
  RecentlyViewedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyViewedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyViewedNotifierHash();

  @$internal
  @override
  RecentlyViewedNotifier create() => RecentlyViewedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$recentlyViewedNotifierHash() =>
    r'197e35d63232264af8c8b5890c54f4d7c0f21178';

abstract class _$RecentlyViewedNotifier extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Resolves recently-viewed deal IDs to their [Deal] objects, most recent
/// first. Fetches just those ~10 products by id (`/api/products?ids=...`)
/// rather than depending on [dealFeedProvider]'s full-catalog fetch — that
/// full-catalog fetch is a 20MB+ response as the product count has grown,
/// and resolving a handful of ids never needed the rest of it.

@ProviderFor(recentDeals)
final recentDealsProvider = RecentDealsProvider._();

/// Resolves recently-viewed deal IDs to their [Deal] objects, most recent
/// first. Fetches just those ~10 products by id (`/api/products?ids=...`)
/// rather than depending on [dealFeedProvider]'s full-catalog fetch — that
/// full-catalog fetch is a 20MB+ response as the product count has grown,
/// and resolving a handful of ids never needed the rest of it.

final class RecentDealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Deal>>,
          List<Deal>,
          FutureOr<List<Deal>>
        >
    with $FutureModifier<List<Deal>>, $FutureProvider<List<Deal>> {
  /// Resolves recently-viewed deal IDs to their [Deal] objects, most recent
  /// first. Fetches just those ~10 products by id (`/api/products?ids=...`)
  /// rather than depending on [dealFeedProvider]'s full-catalog fetch — that
  /// full-catalog fetch is a 20MB+ response as the product count has grown,
  /// and resolving a handful of ids never needed the rest of it.
  RecentDealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentDealsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentDealsHash();

  @$internal
  @override
  $FutureProviderElement<List<Deal>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Deal>> create(Ref ref) {
    return recentDeals(ref);
  }
}

String _$recentDealsHash() => r'3a230d2f778e62d8d4679a3ed7eb446e02904b6e';
