// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scraper_configs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScraperConfigsNotifier)
final scraperConfigsProvider = ScraperConfigsNotifierProvider._();

final class ScraperConfigsNotifierProvider
    extends $NotifierProvider<ScraperConfigsNotifier, List<ScraperConfig>> {
  ScraperConfigsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scraperConfigsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scraperConfigsNotifierHash();

  @$internal
  @override
  ScraperConfigsNotifier create() => ScraperConfigsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ScraperConfig> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ScraperConfig>>(value),
    );
  }
}

String _$scraperConfigsNotifierHash() =>
    r'6996e2a2b685c4f669b42e21db7eadfbe3d1f483';

abstract class _$ScraperConfigsNotifier extends $Notifier<List<ScraperConfig>> {
  List<ScraperConfig> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<ScraperConfig>, List<ScraperConfig>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ScraperConfig>, List<ScraperConfig>>,
              List<ScraperConfig>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
