import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'cookie_consent_provider.g.dart';

enum CookieConsent { unknown, accepted, declined }

const _kCookieConsentKey = 'cookie_consent_status';

@Riverpod(keepAlive: true)
class CookieConsentNotifier extends _$CookieConsentNotifier {
  @override
  CookieConsent build() {
    // We don't load async here to avoid a flash of the banner on startup.
    // The initial state is unknown, and we'll update it in the AppShell.
    return CookieConsent.unknown;
  }

  void setConsent(CookieConsent consent) {
    state = consent;
    _saveConsent(consent);
  }

  Future<void> _saveConsent(CookieConsent consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCookieConsentKey, consent.name);
  }

  Future<void> loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kCookieConsentKey);
    state = CookieConsent.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => CookieConsent.unknown,
    );
  }
}
