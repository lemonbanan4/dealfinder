import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants.dart';
import 'features/deals/data/deal_repository.dart';
import 'features/deals/data/default_scraper_configs.dart';
import 'features/deals/data/firestore_deal_repository.dart';
import 'firebase_options.dart';
import 'tools/database_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await _openBoxes();
  _seedDefaultConfigs();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Populate Firestore with premium mock deals exactly once per project.
    // DatabaseSeeder is a no-op when the collection already has documents.
    final seeder = DatabaseSeeder(FirestoreDealRepository());
    await seeder.reseed();
  } catch (e) {
    // Firebase unavailable until `flutterfire configure` is run.
    // Auth and Firestore features will be disabled at runtime.
    debugPrint('[Firebase] init skipped: $e');
  }

  runApp(const ProviderScope(child: PrisPulsApp()));
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
