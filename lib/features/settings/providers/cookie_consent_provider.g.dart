// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookie_consent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CookieConsentNotifier)
final cookieConsentProvider = CookieConsentNotifierProvider._();

final class CookieConsentNotifierProvider
    extends $NotifierProvider<CookieConsentNotifier, CookieConsent> {
  CookieConsentNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cookieConsentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cookieConsentNotifierHash();

  @$internal
  @override
  CookieConsentNotifier create() => CookieConsentNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CookieConsent value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CookieConsent>(value),
    );
  }
}

String _$cookieConsentNotifierHash() =>
    r'20f30b28a27bc6798135ce0cf8bd1004a6126add';

abstract class _$CookieConsentNotifier extends $Notifier<CookieConsent> {
  CookieConsent build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CookieConsent, CookieConsent>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CookieConsent, CookieConsent>,
              CookieConsent,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
