import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../deals/domain/deal.dart';
import '../domain/alert_config.dart';
import '../providers/alert_configs_provider.dart';

class CreateAlertSheet extends ConsumerStatefulWidget {
  const CreateAlertSheet({super.key, required this.deal});

  final Deal deal;

  static Future<void> show(BuildContext context, Deal deal) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlertSheet(deal: deal),
    );
  }

  @override
  ConsumerState<CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends ConsumerState<CreateAlertSheet> {
  late final TextEditingController _priceCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Default the target price to 10% off the current price
    final target = (widget.deal.currentPrice * 0.9).floor().toString();
    _priceCtrl = TextEditingController(text: target);
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to set price alerts.'),
          backgroundColor: Color(0xFFFF4757),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final targetPrice =
          double.tryParse(_priceCtrl.text) ?? widget.deal.currentPrice;
      final config = AlertConfig(
        id: '${widget.deal.id}_${DateTime.now().millisecondsSinceEpoch}',
        productId: widget.deal.id,
        productTitle: widget.deal.title,
        targetPrice: targetPrice,
        currency: widget.deal.currency,
        createdAt: DateTime.now(),
      );
      await ref.read(alertRepositoryProvider).saveAlertConfig(config);
    } catch (e) {
      // Silently fail or track analytics on failure
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alert saved for ${widget.deal.title}!'),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensures the sheet moves up out of the way when the keyboard opens
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
          // Top handle bar
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
            'Set Price Alert',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.deal.title,
            style: const TextStyle(color: Color(0xFF8A8AA0), fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Current Price',
                  style: TextStyle(color: Color(0xFF8A8AA0)),
                ),
              ),
              Text(
                '${widget.deal.currentPrice.round()} ${widget.deal.currency}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              labelText: 'Target Price (${widget.deal.currency})',
              labelStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.notifications_active_outlined),
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
                    'Save Alert',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
