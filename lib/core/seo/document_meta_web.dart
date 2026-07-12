import 'dart:convert';

import 'package:web/web.dart' as web;

void setDocumentTitle(String title) {
  web.document.title = title;
}

void setMetaDescription(String description) {
  final meta = web.document.querySelector('meta[name="description"]');
  meta?.setAttribute('content', description);
}

void setCanonicalUrl(String url) {
  final link = web.document.querySelector('link[rel="canonical"]');
  link?.setAttribute('href', url);
}

/// Sets a `<meta property="...">` tag, creating it if index.html's static
/// `<head>` doesn't already declare one — unlike title/description/canonical
/// above, the product-page tags below (price, hreflang, JSON-LD) have no
/// static placeholder to update since they only apply to a subset of routes.
void _setOrCreateMetaProperty(String property, String content) {
  var meta =
      web.document.querySelector('meta[property="$property"]')
          as web.HTMLMetaElement?;
  if (meta == null) {
    meta = web.document.createElement('meta') as web.HTMLMetaElement
      ..setAttribute('property', property);
    web.document.head?.append(meta);
  }
  meta.setAttribute('content', content);
}

/// OG/Product price tags, read by link-preview crawlers (Facebook, Pinterest,
/// etc.) and by some shopping crawlers alongside the Product JSON-LD below.
void setOgPrice({required String amount, required String currency}) {
  _setOrCreateMetaProperty('og:type', 'product');
  _setOrCreateMetaProperty('product:price:amount', amount);
  _setOrCreateMetaProperty('product:price:currency', currency);
}

/// `<link rel="alternate" hreflang="...">` tags, keyed by hreflang value
/// (e.g. "sv-SE", "nb-NO", "x-default"). Pointing multiple hreflang values
/// at the same URL is Google's documented pattern for a single URL that
/// serves multiple locale audiences equally — see
/// https://developers.google.com/search/docs/specialty/international/localized-versions
/// ("one URL for many languages/regions") — which is this app's actual
/// situation today (one product URL, no separate sv/nb copies), rather than
/// true per-locale URLs.
void setHreflangAlternates(Map<String, String> hreflangToUrl) {
  for (final entry in hreflangToUrl.entries) {
    var link =
        web.document.querySelector('link[hreflang="${entry.key}"]')
            as web.HTMLLinkElement?;
    if (link == null) {
      link = web.document.createElement('link') as web.HTMLLinkElement
        ..rel = 'alternate'
        ..setAttribute('hreflang', entry.key);
      web.document.head?.append(link);
    }
    link.href = entry.value;
  }
}

/// Creates or replaces a `<script type="application/ld+json">` tag holding
/// structured data (e.g. Product schema) for the current page. [id] scopes
/// the tag so different pages don't stomp each other's data and so it can
/// be removed via [clearStructuredData] when navigating away. Sets
/// `textContent` (never `innerHTML`), so this can't be an XSS vector even
/// with untrusted string fields (product title, etc.) inside [json].
void setStructuredData(String id, Map<String, Object?> json) {
  var script =
      web.document.querySelector('script#$id') as web.HTMLScriptElement?;
  if (script == null) {
    script = web.document.createElement('script') as web.HTMLScriptElement
      ..type = 'application/ld+json'
      ..id = id;
    web.document.head?.append(script);
  }
  script.textContent = jsonEncode(json);
}

/// Removes a structured-data tag previously set via [setStructuredData] —
/// call this from a page's dispose so a product's JSON-LD doesn't linger
/// (and misdescribe the page) after navigating elsewhere.
void clearStructuredData(String id) {
  web.document.querySelector('script#$id')?.remove();
}
