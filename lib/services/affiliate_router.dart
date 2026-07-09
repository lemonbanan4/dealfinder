import 'package:url_launcher/url_launcher.dart';

/// Appends affiliate tracking tags before opening a deal URL in the system
/// browser. Add real tag IDs once Adtraction / Awin accounts are approved.
class AffiliateRouter {
  const AffiliateRouter();

  // ── Replace these with real values from your affiliate dashboards ──────────
  static const _adtractionId = 'YOUR_ADTRACTION_PROGRAM_ID';
  static const _awinId = 'YOUR_AWIN_MERCHANT_ID';

  // Partner domain lists — extend as new merchants are on-boarded.
  static const _adtractionHosts = [
    'elgiganten.no',
    'power.no',
    'komplett.no',
    'elkjop.no',
  ];
  static const _awinHosts = ['dustinhome.no', 'proshop.no', 'webhallen.com'];

  /// Resolves affiliate URL and launches external browser.
  void launch(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return;
    launchUrl(_applyTags(uri), mode: LaunchMode.externalApplication);
  }

  Uri _applyTags(Uri uri) {
    final host = uri.host;

    if (_adtractionHosts.any(host.endsWith)) {
      return uri.replace(
        queryParameters: {
          ...uri.queryParametersAll.map((k, v) => MapEntry(k, v.first)),
          'at_gd': _adtractionId,
        },
      );
    }

    if (_awinHosts.any(host.endsWith)) {
      return Uri.parse(
        'https://www.awin1.com/cread.php?awinmid=$_awinId'
        '&ued=${Uri.encodeComponent(uri.toString())}',
      );
    }

    return uri;
  }
}
