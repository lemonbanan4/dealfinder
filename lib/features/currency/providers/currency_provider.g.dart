// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExchangeRatesNotifier)
final exchangeRatesProvider = ExchangeRatesNotifierProvider._();

final class ExchangeRatesNotifierProvider
    extends $AsyncNotifierProvider<ExchangeRatesNotifier, ExchangeRates> {
  ExchangeRatesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exchangeRatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exchangeRatesNotifierHash();

  @$internal
  @override
  ExchangeRatesNotifier create() => ExchangeRatesNotifier();
}

String _$exchangeRatesNotifierHash() =>
    r'937787e41b4e75c9dda770eb7639884945461e26';

abstract class _$ExchangeRatesNotifier extends $AsyncNotifier<ExchangeRates> {
  FutureOr<ExchangeRates> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExchangeRates>, ExchangeRates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExchangeRates>, ExchangeRates>,
              AsyncValue<ExchangeRates>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
