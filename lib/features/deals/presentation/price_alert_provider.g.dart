// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PriceAlertNotifier)
final priceAlertProvider = PriceAlertNotifierProvider._();

final class PriceAlertNotifierProvider
    extends $AsyncNotifierProvider<PriceAlertNotifier, void> {
  PriceAlertNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'priceAlertProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$priceAlertNotifierHash();

  @$internal
  @override
  PriceAlertNotifier create() => PriceAlertNotifier();
}

String _$priceAlertNotifierHash() =>
    r'7f4763a3b69c01abae5cd669e013e4d7061039fb';

abstract class _$PriceAlertNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
