import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareDeal({
    required String title,
    required String url,
  }) async {
    if (kIsWeb) {
      // On Web, copying to clipboard is the most reliable way to "share"
      await Clipboard.setData(ClipboardData(text: url));
    } else {
      // On Mobile, use the native share dialog
      await Share.share('Check out this deal: $title\n$url');
    }
  }
}
