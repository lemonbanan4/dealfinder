import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/repositories.dart';
import '../domain/exchange_rates.dart';

part 'currency_provider.g.dart';

@Riverpod(keepAlive: true)
class ExchangeRatesNotifier extends _$ExchangeRatesNotifier {
  @override
  Future<ExchangeRates> build() =>
      ref.read(currencyServiceProvider).getRates();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(currencyServiceProvider).getRates(),
    );
  }
}
