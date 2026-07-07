// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Region)
final regionProvider = RegionProvider._();

final class RegionProvider extends $NotifierProvider<Region, String> {
  RegionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regionHash();

  @$internal
  @override
  Region create() => Region();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$regionHash() => r'3300cc7b5d40483db2bb780972513955f6e77c65';

abstract class _$Region extends $Notifier<String> {
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

@ProviderFor(FeedFiltersNotifier)
final feedFiltersProvider = FeedFiltersNotifierProvider._();

final class FeedFiltersNotifierProvider
    extends $NotifierProvider<FeedFiltersNotifier, FeedFilters> {
  FeedFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedFiltersNotifierHash();

  @$internal
  @override
  FeedFiltersNotifier create() => FeedFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedFilters>(value),
    );
  }
}

String _$feedFiltersNotifierHash() =>
    r'c50f275d83ed2ab00b6c7db2542e34ce6a81a9b3';

abstract class _$FeedFiltersNotifier extends $Notifier<FeedFilters> {
  FeedFilters build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FeedFilters, FeedFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FeedFilters, FeedFilters>,
              FeedFilters,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
