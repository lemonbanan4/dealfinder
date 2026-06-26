import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/price_alerts_provider.dart';

/// Shows a modal bottom sheet for the user to create a price alert.
void showPriceAlertModal({
  required BuildContext context,
  required WidgetRef ref,
  required String productId,
  required String title,
  required String url,
  required double currentPrice,
  required String currency,
}) {
  final controller = TextEditingController(
    text: currentPrice.toStringAsFixed(0),
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF12131A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Set Price Alert',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Alert me when "$title" drops below:',
              style: const TextStyle(color: Color(0xFF5A5A78), fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: 'Target Price',
                      labelStyle: TextStyle(color: Color(0xFF5A5A78)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF252638)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00B4FF)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  currency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final target = double.tryParse(controller.text);
                if (target == null || target <= 0) return;

                final success = await ref
                    .read(priceAlertsProvider.notifier)
                    .createAlert(
                      productId: productId,
                      productTitle: title,
                      productUrl: url,
                      targetPrice: target,
                      currency: currency,
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Alert successfully set!'
                            : 'Failed to set alert. Are you logged in?',
                      ),
                      backgroundColor: success
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text(
                'Create Alert',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    },
  );
}
