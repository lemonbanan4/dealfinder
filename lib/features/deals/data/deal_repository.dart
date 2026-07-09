import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants.dart';
import '../domain/deal.dart';

class DealRepository {
  Box<String> get _dealBox => Hive.box<String>(HiveBoxes.deals);

  List<Deal> getAll() {
    return _dealBox.values
        .map((v) => Deal.fromJson(jsonDecode(v) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Deal> deals) async {
    final entries = {for (final d in deals) d.id: jsonEncode(d.toJson())};
    await _dealBox.putAll(entries);
  }

  Future<void> clear() => _dealBox.clear();
}
