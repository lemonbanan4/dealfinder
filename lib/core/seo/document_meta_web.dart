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
