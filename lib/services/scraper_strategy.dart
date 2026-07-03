import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

abstract interface class ScraperStrategy {
  Future<String> fetchHtml(String url);
}

/// Direct HTTP fetch — used on mobile and desktop.
class NativeScraperStrategy implements ScraperStrategy {
  const NativeScraperStrategy(this._client);

  final http.Client _client;

  @override
  Future<String> fetchHtml(String url) async {
    final response = await _client
        .get(
          Uri.parse(url),
          headers: {
            'Accept': 'text/html,application/xhtml+xml',
            'User-Agent':
                'Mozilla/5.0 (compatible; DealFinderBot/1.0)',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode} fetching $url');
    }
    return response.body;
  }
}

/// Proxies fetch through the BFF — used on web where CORS blocks direct scraping.
///
/// BFF contract:
///   POST `<proxyBaseUrl>`/api/fetch
///   Body: `{ "url": "https://..." }`
///   Response: `{ "html": "<html>...</html>" }`
class ProxyScraperStrategy implements ScraperStrategy {
  const ProxyScraperStrategy(this._client, this._proxyBaseUrl);

  final http.Client _client;
  final String _proxyBaseUrl;

  @override
  Future<String> fetchHtml(String url) async {
    final response = await _client
        .post(
          Uri.parse('$_proxyBaseUrl/api/fetch'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'url': url}),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('BFF proxy returned ${response.statusCode} for $url');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['html'] as String;
  }
}

/// Returns the correct strategy for the current platform.
ScraperStrategy buildScraperStrategy({
  required http.Client client,
  String proxyBaseUrl = 'http://localhost:8080',
}) {
  if (kIsWeb) return ProxyScraperStrategy(client, proxyBaseUrl);
  return NativeScraperStrategy(client);
}
