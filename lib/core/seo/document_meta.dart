/// Per-route `<title>`/meta-description/canonical updates for the HTML
/// document — Flutter doesn't manage these automatically per route, and
/// they matter here specifically for brand landing pages (see
/// `BrandLandingPage`), where a distinct, accurate title/description per
/// page is the whole point.
library;

/// Conditionally exported: the real implementation touches `window.document`
/// via `package:web` (web-only), so non-web builds get a no-op stub instead
/// of a compile error. `dart.library.js_interop` — rather than the older
/// `dart.library.html` — is the condition, matching this app's move away
/// from `dart:html` (see CLAUDE.md's web-compliance note); `package:web` is
/// built on `dart:js_interop`.
export 'document_meta_stub.dart'
    if (dart.library.js_interop) 'document_meta_web.dart';
