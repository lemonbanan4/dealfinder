import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../features/alerts/data/alert_repository.dart';
import '../features/currency/data/currency_repository.dart';
import '../features/currency/data/ecb_client.dart';
import '../features/deals/data/deal_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../services/currency_service.dart';

final httpClientProvider = Provider<http.Client>(
  (ref) {
    final client = http.Client();
    ref.onDispose(client.close);
    return client;
  },
  name: 'httpClientProvider',
);

final dealRepositoryProvider = Provider<DealRepository>(
  (_) => DealRepository(),
  name: 'dealRepositoryProvider',
);

final alertRepositoryProvider = Provider<AlertRepository>(
  (_) => AlertRepository(),
  name: 'alertRepositoryProvider',
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => SettingsRepository(),
  name: 'settingsRepositoryProvider',
);

final currencyRepositoryProvider = Provider<CurrencyRepository>(
  (_) => CurrencyRepository(),
  name: 'currencyRepositoryProvider',
);

final ecbClientProvider = Provider<EcbClient>(
  (ref) => EcbClient(ref.watch(httpClientProvider)),
  name: 'ecbClientProvider',
);

final currencyServiceProvider = Provider<CurrencyService>(
  (ref) => CurrencyService(
    ref.watch(currencyRepositoryProvider),
    ref.watch(ecbClientProvider),
  ),
  name: 'currencyServiceProvider',
);
