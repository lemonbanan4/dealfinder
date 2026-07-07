import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants.dart';
import '../../../utils/error_formatting.dart';
import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/alert_config.dart';
import '../providers/alert_configs_provider.dart';

class EditAlertSheet extends ConsumerStatefulWidget {
  const EditAlertSheet({super.key, required this.config});

  final AlertConfig config;

  static Future<void> show(BuildContext context, AlertConfig config) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditAlertSheet(config: config),
    );
  }

  @override
  ConsumerState<EditAlertSheet> createState() => _EditAlertSheetState();
}

class _EditAlertSheetState extends ConsumerState<EditAlertSheet> {
  late final TextEditingController _priceCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // widget.config.targetPrice/currency is always SEK (the create flow
    // converts to SEK before saving — see price_alert_bottom_sheet.dart), so
    // pre-fill in the user's chosen display currency instead of raw SEK,
    // matching what the create sheet shows. Best-effort: if exchange rates
    // haven't loaded yet this falls back to the raw SEK value (rare in
    // practice, since rates are fetched once at app startup and cached).
    final settings = ref.read(appSettingsProvider);
    final converter = ref.read(currencyConverterProvider.notifier);
    final displayValue = converter.convert(
      widget.config.targetPrice,
      widget.config.currency,
      settings.displayCurrency,
    );
    _priceCtrl = TextEditingController(text: displayValue.round().toString());
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final enteredPrice =
          double.tryParse(_priceCtrl.text) ?? widget.config.targetPrice;
      // Convert back from the display currency shown above to SEK — every
      // alert's targetPrice is stored/interpreted as SEK app-wide (see
      // price_alert_bottom_sheet.dart), so saving the entered value
      // unconverted would silently corrupt the target by the exchange rate
      // whenever displayCurrency != SEK.
      final settings = ref.read(appSettingsProvider);
      final converter = ref.read(currencyConverterProvider.notifier);
      final targetPrice = converter.convert(
        enteredPrice,
        settings.displayCurrency,
        'SEK',
      );

      final updatedConfig = AlertConfig(
        id: widget.config.id,
        productId: widget.config.productId,
        productTitle: widget.config.productTitle,
        targetPrice: targetPrice,
        currency: widget.config.currency,
        createdAt: widget.config.createdAt, // Retain original creation date
      );

      // saveAlertConfig natively behaves as an "upsert", so it will safely override the old values!
      await ref.read(alertRepositoryProvider).saveAlertConfig(updatedConfig);

      // Best-effort: keep the backend scraper's price_alerts row in sync
      // too, otherwise its server-side email check keeps firing at the old
      // target price even though the app shows the new one. Routed through
      // the backend, which verifies the ID token and scopes the update to
      // that uid, rather than writing to Supabase directly with the anon key.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final idToken = await user.getIdToken();
          final response = await http.patch(
            Uri.parse(
              '${ApiUrls.apiUrl}/api/alerts/${updatedConfig.productId}',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({'target_price': targetPrice}),
          );
          if (response.statusCode >= 400) {
            throw Exception(
              'Backend rejected the update (${response.statusCode}): ${response.body}',
            );
          }
        } catch (e) {
          debugPrint('Failed to sync updated target to backend: $e');
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Target updated for ${widget.config.productTitle}!'),
            backgroundColor: const Color(0xFF00E676),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update alert: ${friendlyErrorMessage(e)}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final displayCurrency = ref.watch(appSettingsProvider).displayCurrency;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF12131A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A52),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Edit Target Price',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.config.productTitle,
            style: const TextStyle(color: Color(0xFF8A8AA0), fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00B4FF),
            ),
            decoration: InputDecoration(
              labelText: 'Target Price ($displayCurrency)',
              labelStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.edit_notifications_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00B4FF),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Update Alert',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
