// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deals_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DealsNotifier)
final dealsProvider = DealsNotifierFamily._();

final class DealsNotifierProvider
    extends $AsyncNotifierProvider<DealsNotifier, DealsState> {
  DealsNotifierProvider._({
    required DealsNotifierFamily super.from,
    required (String, DealSort) super.argument,
  }) : super(
         retry: null,
         name: r'dealsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dealsNotifierHash();

  @override
  String toString() {
    return r'dealsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  DealsNotifier create() => DealsNotifier();

  @override
  bool operator ==(Object other) {
    return other is DealsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dealsNotifierHash() => r'ada8385d6ae8b7c07b24794198fcc42f48fad252';

final class DealsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          DealsNotifier,
          AsyncValue<DealsState>,
          DealsState,
          FutureOr<DealsState>,
          (String, DealSort)
        > {
  DealsNotifierFamily._()
    : super(
        retry: null,
        name: r'dealsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DealsNotifierProvider call(String query, DealSort sort) =>
      DealsNotifierProvider._(argument: (query, sort), from: this);

  @override
  String toString() => r'dealsProvider';
}

abstract class _$DealsNotifier extends $AsyncNotifier<DealsState> {
  late final _$args = ref.$arg as (String, DealSort);
  String get query => _$args.$1;
  DealSort get sort => _$args.$2;

  FutureOr<DealsState> build(String query, DealSort sort);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DealsState>, DealsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DealsState>, DealsState>,
              AsyncValue<DealsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
