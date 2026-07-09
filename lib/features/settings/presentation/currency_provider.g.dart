// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrencyConverter)
final currencyConverterProvider = CurrencyConverterProvider._();

final class CurrencyConverterProvider
    extends $AsyncNotifierProvider<CurrencyConverter, ExchangeRates?> {
  CurrencyConverterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyConverterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyConverterHash();

  @$internal
  @override
  CurrencyConverter create() => CurrencyConverter();
}

String _$currencyConverterHash() => r'839fe96df584c868061bd2b519afae22d00ec33a';

abstract class _$CurrencyConverter extends $AsyncNotifier<ExchangeRates?> {
  FutureOr<ExchangeRates?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExchangeRates?>, ExchangeRates?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExchangeRates?>, ExchangeRates?>,
              AsyncValue<ExchangeRates?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A convenience provider that returns a formatted price string.

@ProviderFor(formattedPrice)
final formattedPriceProvider = FormattedPriceFamily._();

/// A convenience provider that returns a formatted price string.

final class FormattedPriceProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// A convenience provider that returns a formatted price string.
  FormattedPriceProvider._({
    required FormattedPriceFamily super.from,
    required ({double price, String currency}) super.argument,
  }) : super(
         retry: null,
         name: r'formattedPriceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$formattedPriceHash();

  @override
  String toString() {
    return r'formattedPriceProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as ({double price, String currency});
    return formattedPrice(
      ref,
      price: argument.price,
      currency: argument.currency,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedPriceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$formattedPriceHash() => r'726806a8a53840bf32cc8f2ed9ef33b47518edd8';

/// A convenience provider that returns a formatted price string.

final class FormattedPriceFamily extends $Family
    with $FunctionalFamilyOverride<String, ({double price, String currency})> {
  FormattedPriceFamily._()
    : super(
        retry: null,
        name: r'formattedPriceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A convenience provider that returns a formatted price string.

  FormattedPriceProvider call({
    required double price,
    required String currency,
  }) => FormattedPriceProvider._(
    argument: (price: price, currency: currency),
    from: this,
  );

  @override
  String toString() => r'formattedPriceProvider';
}
