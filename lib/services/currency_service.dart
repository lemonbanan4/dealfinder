import '../features/currency/data/currency_repository.dart';
import '../features/currency/data/ecb_client.dart';
import '../features/currency/domain/exchange_rates.dart';

class CurrencyService {
  const CurrencyService(this._repo, this._client);

  final CurrencyRepository _repo;
  final EcbClient _client;

  Future<ExchangeRates> getRates() async {
    final cached = _repo.getCached();
    if (cached != null && _repo.isFresh(cached)) return cached;

    final fresh = await _client.fetchRates();
    await _repo.save(fresh);
    return fresh;
  }

  /// Convert [amountEur] to [targetCurrency] using [rates].
  double convert(double amountEur, String targetCurrency, ExchangeRates rates) {
    if (targetCurrency == 'EUR') return amountEur;
    final rate = rates.rates[targetCurrency];
    if (rate == null) return amountEur;
    return amountEur * rate;
  }

  /// Parse a raw price string like "1 299,00 kr" or "€12.99" into a double.
  double? parsePrice(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\d.,]'), '').trim();
    if (cleaned.isEmpty) return null;
    // Handle "1.299,00" (European) vs "1,299.00" (US) formatting
    final hasCommaDecimal = cleaned.contains(',') &&
        (!cleaned.contains('.') ||
            cleaned.lastIndexOf(',') > cleaned.lastIndexOf('.'));
    final normalised = hasCommaDecimal
        ? cleaned.replaceAll('.', '').replaceAll(',', '.')
        : cleaned.replaceAll(',', '');
    return double.tryParse(normalised);
  }
}
