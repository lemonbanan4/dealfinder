import '../features/alerts/domain/price_alert.dart';
import '../features/currency/domain/exchange_rates.dart';
import '../features/deals/domain/deal.dart';
import 'currency_service.dart';

class TriggeredAlert {
  const TriggeredAlert({
    required this.alert,
    required this.deal,
    required this.displayPrice,
  });

  final PriceAlert alert;
  final Deal deal;
  final double displayPrice;
}

class AlertEvaluationService {
  const AlertEvaluationService(this._currency);

  final CurrencyService _currency;

  /// Returns one [TriggeredAlert] per alert whose threshold has just been crossed.
  List<TriggeredAlert> evaluate({
    required List<Deal> deals,
    required List<PriceAlert> alerts,
    required ExchangeRates rates,
  }) {
    final results = <TriggeredAlert>[];

    for (final alert in alerts) {
      if (alert.isTriggered) continue;

      final matches = _matchingDeals(alert, deals);
      for (final deal in matches) {
        final price = _currency.convert(
          deal.priceEur,
          alert.displayCurrency,
          rates,
        );
        if (price <= alert.targetPrice) {
          results.add(
            TriggeredAlert(alert: alert, deal: deal, displayPrice: price),
          );
          break; // one notification per alert, cheapest matching deal
        }
      }
    }

    return results;
  }

  List<Deal> _matchingDeals(PriceAlert alert, List<Deal> deals) {
    if (alert.dealId != null) {
      return deals.where((d) => d.id == alert.dealId).toList();
    }
    if (alert.searchQuery != null) {
      final q = alert.searchQuery!.toLowerCase();
      return deals.where((d) => d.title.toLowerCase().contains(q)).toList();
    }
    // No filter — check all deals (alert covers any deal below threshold)
    return deals;
  }
}
