import 'package:flutter/foundation.dart';

abstract final class HiveBoxes {
  static const deals = 'deals';
  static const alerts = 'alerts';
  static const settings = 'settings';
}

abstract final class ApiUrls {
  // Use a proper production URL here.
  // Once you deploy to Render, swap this:
  static const String apiUrl = kReleaseMode
      ? 'https://dealfinder-swr5.onrender.com'
      : 'http://127.0.0.1:8000';
}
