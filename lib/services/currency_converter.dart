abstract final class CurrencyConverter {
  // Approximate mid-market rates to EUR as of mid-2026.
  // Refresh these periodically — sorting accuracy degrades if rates drift >10%.
  static const Map<String, double> _toEurRate = {
    'EUR': 1.0,
    'SEK': 0.0877,
    'NOK': 0.0855,
    'USD': 0.92,
    'GBP': 1.17,
  };

  /// Converts [amount] in [currencyCode] to EUR.
  /// Falls back to 1.0 rate for unknown currencies so sorting degrades
  /// gracefully rather than crashing.
  static double toEur(double amount, String currencyCode) {
    final rate = _toEurRate[currencyCode.toUpperCase()] ?? 1.0;
    return amount * rate;
  }
}
