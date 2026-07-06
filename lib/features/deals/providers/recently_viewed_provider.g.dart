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
/// first. A real top-level provider — not one built fresh inside a widget's
/// `build()` (the previous approach), which registers a brand-new, never-
/// disposed provider instance in the container on every rebuild.

@ProviderFor(recentDeals)
final recentDealsProvider = RecentDealsProvider._();

/// Resolves recently-viewed deal IDs to their [Deal] objects, most recent
/// first. A real top-level provider — not one built fresh inside a widget's
/// `build()` (the previous approach), which registers a brand-new, never-
/// disposed provider instance in the container on every rebuild.

final class RecentDealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Deal>>,
          AsyncValue<List<Deal>>,
          AsyncValue<List<Deal>>
        >
    with $Provider<AsyncValue<List<Deal>>> {
  /// Resolves recently-viewed deal IDs to their [Deal] objects, most recent
  /// first. A real top-level provider — not one built fresh inside a widget's
  /// `build()` (the previous approach), which registers a brand-new, never-
  /// disposed provider instance in the container on every rebuild.
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
  $ProviderElement<AsyncValue<List<Deal>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Deal>> create(Ref ref) {
    return recentDeals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Deal>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Deal>>>(value),
    );
  }
}

String _$recentDealsHash() => r'ad46ef356735030ce657dc76033b2a01c730c0d4';
