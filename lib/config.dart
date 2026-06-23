import 'package:flutter/foundation.dart';

class AppConfig {
  // Switch this URL when you deploy your API
  static const String apiUrl = kReleaseMode
      ? 'https://api.prispuls.com'
      : 'http://127.0.0.1:8000';
}
