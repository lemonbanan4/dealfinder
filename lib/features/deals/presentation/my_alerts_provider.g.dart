// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_alerts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MyAlerts)
final myAlertsProvider = MyAlertsProvider._();

final class MyAlertsProvider
    extends $AsyncNotifierProvider<MyAlerts, List<PriceAlert>> {
  MyAlertsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myAlertsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myAlertsHash();

  @$internal
  @override
  MyAlerts create() => MyAlerts();
}

String _$myAlertsHash() => r'acd3f66ae8034f3b742c0b2c2d91596ba68feda5';

abstract class _$MyAlerts extends $AsyncNotifier<List<PriceAlert>> {
  FutureOr<List<PriceAlert>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PriceAlert>>, List<PriceAlert>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PriceAlert>>, List<PriceAlert>>,
              AsyncValue<List<PriceAlert>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
