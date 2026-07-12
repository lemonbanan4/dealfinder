/// Non-web fallback — there's no HTML document to update.
void setDocumentTitle(String title) {}

void setMetaDescription(String description) {}

void setCanonicalUrl(String url) {}

void setOgPrice({required String amount, required String currency}) {}

void setHreflangAlternates(Map<String, String> hreflangToUrl) {}

void setStructuredData(String id, Map<String, Object?> json) {}

void clearStructuredData(String id) {}
