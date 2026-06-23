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

String _$dealFeedNotifierHash() => r'91eb04ccb315049bf3733476b32eaabd18f43501';

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
