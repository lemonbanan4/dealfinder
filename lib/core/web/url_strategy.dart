/// Switches web navigation from hash-based (`/#/brands/dyson-sweden`) to
/// real path-based (`/brands/dyson-sweden`) URLs — required for brand
/// landing pages to be crawlable/linkable at all, since a URL fragment
/// never reaches the server, so neither a search crawler nor a Firebase
/// Hosting rewrite rule can ever see it.
library;

/// Conditionally exported, same reasoning as `core/seo/document_meta.dart`:
/// the real implementation (`package:flutter_web_plugins`) transitively
/// imports `dart:ui_web`, which doesn't exist outside a web compile target
/// — including the plain Dart VM `flutter test` runs under by default — so
/// importing it unconditionally in main.dart broke every test that even
/// just loads main.dart, regardless of the kIsWeb runtime guard around the
/// call site (Dart resolves imports at compile time, before any runtime
/// check ever executes).
export 'url_strategy_stub.dart'
    if (dart.library.js_interop) 'url_strategy_web.dart';
