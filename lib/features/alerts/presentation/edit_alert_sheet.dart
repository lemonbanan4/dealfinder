import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../utils/error_formatting.dart';
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
    _priceCtrl = TextEditingController(
      text: widget.config.targetPrice.round().toString(),
    );
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final targetPrice =
          double.tryParse(_priceCtrl.text) ?? widget.config.targetPrice;

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

      // Best-effort: keep the backend scraper's Supabase row in sync too,
      // otherwise its server-side email check keeps firing at the old
      // target price even though the app shows the new one.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await Supabase.instance.client
              .from('price_alerts')
              .update({'target_price': targetPrice})
              .eq('product_id', updatedConfig.productId)
              .eq('user_id', user.uid);
        } catch (e) {
          debugPrint('Failed to sync updated target to Supabase: $e');
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
              labelText: 'Target Price (SEK)',
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
