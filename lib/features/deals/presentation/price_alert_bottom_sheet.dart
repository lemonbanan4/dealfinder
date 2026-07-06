import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/currency_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../auth/presentation/login_page.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../utils/error_formatting.dart';
import '../domain/deal.dart';
import 'price_alert_provider.dart';

/// A bottom sheet for creating or updating a price alert for a specific deal.
///
/// It handles user authentication, input validation, and provides feedback
/// to the user upon success or failure.
class PriceAlertBottomSheet extends ConsumerStatefulWidget {
  const PriceAlertBottomSheet({super.key, required this.deal});

  final Deal deal;

  @override
  ConsumerState<PriceAlertBottomSheet> createState() =>
      _PriceAlertBottomSheetState();
}

class _PriceAlertBottomSheetState extends ConsumerState<PriceAlertBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _savePriceAlert() async {
    if (!(_formKey.currentState?.validate() ?? false) || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final enteredPrice = double.parse(_priceController.text);
      // The field above is entered in the user's display currency, but
      // AlertConfig.targetPrice — and the backend's price comparison in
      // scraper.py, which checks the raw (always-SEK) product price against
      // it with no conversion — assume the stored value is in SEK. Convert
      // back to SEK here so a target set in e.g. NOK doesn't get compared
      // (or later re-displayed) as if it were already SEK.
      final settings = ref.read(appSettingsProvider);
      final currencyConverter = ref.read(currencyConverterProvider.notifier);
      final targetPrice = currencyConverter.convert(
        enteredPrice,
        settings.displayCurrency,
        'SEK',
      );
      await ref
          .read(priceAlertProvider.notifier)
          .createAlert(
            productId: widget.deal.id,
            productTitle: widget.deal.title,
            targetPrice: targetPrice,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Price alert has been set!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyErrorMessage(e)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final settings = ref.watch(appSettingsProvider);
    final currencyConverter = ref.watch(currencyConverterProvider.notifier);
    final displayPrice = currencyConverter.convert(
      widget.deal.currentPrice,
      widget.deal.currency,
      settings.displayCurrency,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Price Alert',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.deal.title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Notify me when price is below',
                hintText: 'e.g., ${displayPrice.toStringAsFixed(0)}',
                prefixText: '${settings.displayCurrency} ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price.';
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return 'Please enter a valid number.';
                }
                if (price <= 0) {
                  return 'Price must be greater than zero.';
                }
                if (price >= displayPrice) {
                  return 'Alert price must be below the current price.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            if (user == null)
              Center(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In to Set Alert'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close bottom sheet
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.notifications_active_outlined),
                  label: _isLoading
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Alert'),
                  onPressed: _isLoading ? null : _savePriceAlert,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
