import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../domain/price_alert.dart';

final alertsProvider = NotifierProvider<AlertsNotifier, List<PriceAlert>>(() {
  return AlertsNotifier();
});

class AlertsNotifier extends Notifier<List<PriceAlert>> {
  Box<String> get _box => Hive.box<String>(HiveBoxes.alerts);

  @override
  List<PriceAlert> build() {
    final alerts = <PriceAlert>[];
    for (final key in _box.keys) {
      final jsonStr = _box.get(key);
      if (jsonStr != null) {
        try {
          alerts.add(PriceAlert.fromJson(jsonDecode(jsonStr)));
        } catch (e) {
          // Ignore malformed data
        }
      }
    }

    // Sort by newest first
    alerts.sort((a, b) => b.time.compareTo(a.time));
    return alerts;
  }

  void deleteAlert(String id) {
    _box.delete(id);
    state = state.where((alert) => alert.id != id).toList();
  }

  /// Clears all alerts from storage and state.
  Future<void> clear() async {
    await _box.clear();
    state = [];
  }

  void markAllAsRead() {
    final updatedAlerts = state.map((alert) {
      if (alert.isRead) return alert;
      final updated = alert.copyWith(isRead: true);
      _box.put(updated.id, jsonEncode(updated.toJson()));
      return updated;
    }).toList();
    state = updatedAlerts;
  }

  // Utility method to add a new alert (useful for your background service)
  void addAlert(PriceAlert alert) {
    _box.put(alert.id, jsonEncode(alert.toJson()));
    state = [alert, ...state];
  }
}
