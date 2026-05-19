import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants.dart';
import '../domain/deal.dart';
import '../domain/scraper_config.dart';

class DealRepository {
  Box<String> get _dealBox => Hive.box<String>(HiveBoxes.deals);
  Box<String> get _configBox => Hive.box<String>(HiveBoxes.scraperConfigs);

  List<Deal> getAll() {
    return _dealBox.values
        .map((v) => Deal.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
  }

  Future<void> saveAll(List<Deal> deals) async {
    final entries = {for (final d in deals) d.id: jsonEncode(d.toJson())};
    await _dealBox.putAll(entries);
  }

  Future<void> clear() => _dealBox.clear();

  // Scraper configs

  List<ScraperConfig> getConfigs() {
    return _configBox.values
        .map((v) =>
            ScraperConfig.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveConfig(ScraperConfig config) =>
      _configBox.put(config.id, jsonEncode(config.toJson()));

  Future<void> deleteConfig(String id) => _configBox.delete(id);
}
