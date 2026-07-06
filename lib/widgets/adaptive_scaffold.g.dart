// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptive_scaffold.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppShellIndex)
final appShellIndexProvider = AppShellIndexProvider._();

final class AppShellIndexProvider
    extends $NotifierProvider<AppShellIndex, int> {
  AppShellIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appShellIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appShellIndexHash();

  @$internal
  @override
  AppShellIndex create() => AppShellIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$appShellIndexHash() => r'a7174948cca77e4ed00731c15e6d7ab197b65383';

abstract class _$AppShellIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
