import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants.dart';
import 'features/deals/data/deal_repository.dart';
import 'features/deals/data/default_scraper_configs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _openBoxes();
  _seedDefaultConfigs();
  runApp(const ProviderScope(child: DealFinderApp()));
}

Future<void> _openBoxes() async {
  await Future.wait([
    Hive.openBox<String>(HiveBoxes.deals),
    Hive.openBox<String>(HiveBoxes.alerts),
    Hive.openBox<String>(HiveBoxes.settings),
    Hive.openBox<String>(HiveBoxes.currencyRates),
    Hive.openBox<String>(HiveBoxes.scraperConfigs),
  ]);
}

void _seedDefaultConfigs() {
  final repo = DealRepository();
  if (repo.getConfigs().isNotEmpty) return;
  for (final config in defaultScraperConfigs) {
    repo.saveConfig(config);
  }
}
