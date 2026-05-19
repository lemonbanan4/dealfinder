import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants.dart';
import '../domain/price_alert.dart';

class AlertRepository {
  Box<String> get _box => Hive.box<String>(HiveBoxes.alerts);

  List<PriceAlert> getAll() {
    return _box.values
        .map((v) => PriceAlert.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> save(PriceAlert alert) =>
      _box.put(alert.id, jsonEncode(alert.toJson()));

  Future<void> delete(String id) => _box.delete(id);

  Future<void> saveAll(List<PriceAlert> alerts) async {
    final entries = {for (final a in alerts) a.id: jsonEncode(a.toJson())};
    await _box.putAll(entries);
  }
}
