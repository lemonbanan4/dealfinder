// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deal_by_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A single deal by its product id, for the crawlable `/products/:id` route
/// (see `ProductPage`) — unlike every other deal fetch in this app, this one
/// has no feed/catalog already in memory to look the id up in, since it's
/// meant to serve a cold page load (a shared link, a search result, a
/// browser refresh).
///
/// `/api/products?ids=` returns a bare array (see api.py) rather than the
/// `{items: [...]}` shape paginated/filtered endpoints use; `null` means the
/// id doesn't exist (removed deal, bad link) rather than a network failure,
/// which callers should still let surface as an error via [AsyncValue].

@ProviderFor(dealById)
final dealByIdProvider = DealByIdFamily._();

/// A single deal by its product id, for the crawlable `/products/:id` route
/// (see `ProductPage`) — unlike every other deal fetch in this app, this one
/// has no feed/catalog already in memory to look the id up in, since it's
/// meant to serve a cold page load (a shared link, a search result, a
/// browser refresh).
///
/// `/api/products?ids=` returns a bare array (see api.py) rather than the
/// `{items: [...]}` shape paginated/filtered endpoints use; `null` means the
/// id doesn't exist (removed deal, bad link) rather than a network failure,
/// which callers should still let surface as an error via [AsyncValue].

final class DealByIdProvider
    extends $FunctionalProvider<AsyncValue<Deal?>, Deal?, FutureOr<Deal?>>
    with $FutureModifier<Deal?>, $FutureProvider<Deal?> {
  /// A single deal by its product id, for the crawlable `/products/:id` route
  /// (see `ProductPage`) — unlike every other deal fetch in this app, this one
  /// has no feed/catalog already in memory to look the id up in, since it's
  /// meant to serve a cold page load (a shared link, a search result, a
  /// browser refresh).
  ///
  /// `/api/products?ids=` returns a bare array (see api.py) rather than the
  /// `{items: [...]}` shape paginated/filtered endpoints use; `null` means the
  /// id doesn't exist (removed deal, bad link) rather than a network failure,
  /// which callers should still let surface as an error via [AsyncValue].
  DealByIdProvider._({
    required DealByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dealByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dealByIdHash();

  @override
  String toString() {
    return r'dealByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Deal?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Deal?> create(Ref ref) {
    final argument = this.argument as String;
    return dealById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DealByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dealByIdHash() => r'7cbbe0b0740cc5fec1e26b7bcc95163bfc218ec0';

/// A single deal by its product id, for the crawlable `/products/:id` route
/// (see `ProductPage`) — unlike every other deal fetch in this app, this one
/// has no feed/catalog already in memory to look the id up in, since it's
/// meant to serve a cold page load (a shared link, a search result, a
/// browser refresh).
///
/// `/api/products?ids=` returns a bare array (see api.py) rather than the
/// `{items: [...]}` shape paginated/filtered endpoints use; `null` means the
/// id doesn't exist (removed deal, bad link) rather than a network failure,
/// which callers should still let surface as an error via [AsyncValue].

final class DealByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Deal?>, String> {
  DealByIdFamily._()
    : super(
        retry: null,
        name: r'dealByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single deal by its product id, for the crawlable `/products/:id` route
  /// (see `ProductPage`) — unlike every other deal fetch in this app, this one
  /// has no feed/catalog already in memory to look the id up in, since it's
  /// meant to serve a cold page load (a shared link, a search result, a
  /// browser refresh).
  ///
  /// `/api/products?ids=` returns a bare array (see api.py) rather than the
  /// `{items: [...]}` shape paginated/filtered endpoints use; `null` means the
  /// id doesn't exist (removed deal, bad link) rather than a network failure,
  /// which callers should still let surface as an error via [AsyncValue].

  DealByIdProvider call(String id) =>
      DealByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'dealByIdProvider';
}
