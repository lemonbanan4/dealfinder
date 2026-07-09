import 'package:http/http.dart' as http;

import 'constants.dart';

/// Thrown by [apiGet] when the backend responds with a non-2xx status —
/// carries enough context (path, status, body) for callers/logs to diagnose
/// without each call site re-implementing the same status check.
class ApiException implements Exception {
  ApiException(this.path, this.statusCode, this.body);

  final String path;
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException: GET $path failed ($statusCode): $body';
}

/// A single place for the "resolve against the backend, apply a timeout,
/// surface a clear error on failure" boilerplate that used to be
/// copy-pasted — with an inconsistent, sometimes-missing timeout — across
/// every provider that calls api.py. [path] is relative to [ApiUrls.apiUrl]
/// (e.g. `/api/stats`). Pass [headers] for authenticated calls (e.g. a
/// Firebase ID token bearer header).
Future<http.Response> apiGet(
  String path, {
  Map<String, String>? queryParameters,
  Map<String, String>? headers,
  Duration timeout = const Duration(seconds: 10),
}) async {
  final uri = Uri.parse(
    '${ApiUrls.apiUrl}$path',
  ).replace(queryParameters: queryParameters);
  final response = await http.get(uri, headers: headers).timeout(timeout);
  if (response.statusCode >= 400) {
    throw ApiException(path, response.statusCode, response.body);
  }
  return response;
}
