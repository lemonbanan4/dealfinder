import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/providers/cookie_consent_provider.dart';
import '../theme/glass_colors.dart';

class CookieConsentBanner extends ConsumerWidget {
  const CookieConsentBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show the banner on the web platform.
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    final consentStatus = ref.watch(cookieConsentProvider);

    // Only show the banner if the user hasn't made a choice yet.
    if (consentStatus != CookieConsent.unknown) {
      return const SizedBox.shrink();
    }

    const text = Text(
      'This website uses cookies to enhance the user experience and for analytics. By continuing to use this site, you agree to our use of cookies.',
      style: TextStyle(color: Color(0xFF8A8AA0), fontSize: 13),
    );

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            ref
                .read(cookieConsentProvider.notifier)
                .setConsent(CookieConsent.declined);
          },
          child: const Text(
            'Decline',
            style: TextStyle(color: Color(0xFF8A8AA0)),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: GlassColors.orange500,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            ref
                .read(cookieConsentProvider.notifier)
                .setConsent(CookieConsent.accepted);
          },
          child: const Text('Accept'),
        ),
      ],
    );

    return Material(
      color: const Color(0xFF1A1B2A),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF252638))),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // A fixed Row(Expanded(flex:3)/Expanded(flex:2)) squeezes
            // "Decline"/"Accept" into ~120px combined on a phone-width
            // screen, clipping the Accept button — stack vertically
            // instead once there isn't room for both side by side.
            if (constraints.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  text,
                  const SizedBox(height: 12),
                  buttons,
                ],
              );
            }
            return Row(
              children: [
                const Expanded(flex: 3, child: text),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: buttons),
              ],
            );
          },
        ),
      ),
    );
  }
}
