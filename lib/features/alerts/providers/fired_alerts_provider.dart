import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import 'unread_alerts_provider.dart';

const _pollInterval = Duration(seconds: 60);

/// Polls the backend's `/api/alerts/fired` endpoint — backed by the same
/// `price_alerts` table `scraper.py`'s `check_and_fire_price_alerts()` flips
/// `is_active` to false on when a tracked price drops — for alerts that have
/// fired for the signed-in user, and drives [unreadAlertsProvider] off of
/// however many the user hasn't seen yet — "seen" is tracked locally, since
/// nothing server-side records per-alert acknowledgement.
///
/// This goes through the backend (with a verified Firebase ID token) rather
/// than querying Supabase directly: `price_alerts` holds other users' email
/// addresses, and the app never authenticates with Supabase itself (only
/// Firebase), so there's no `auth.uid()` for Supabase RLS to scope a SELECT
/// to — a client-side query would either be blocked entirely or, if opened
/// up, readable by anyone holding the public anon key.
class FiredAlertsNotifier extends Notifier<void> {
  Timer? _timer;

  @override
  void build() {
    ref.onDispose(() => _timer?.cancel());
  }

  void start() {
    _timer?.cancel();
    unawaited(_poll());
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  Future<Set<String>> _fetchFiredAlertIds() async {
    final idToken = await fb.FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await apiGet(
      '/api/alerts/fired',
      headers: {'Authorization': 'Bearer $idToken'},
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List;
    return items.map((row) => row['id'].toString()).toSet();
  }

  Future<void> _poll() async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      ref.read(unreadAlertsProvider.notifier).updateCount(0);
      return;
    }
    try {
      final firedIds = await _fetchFiredAlertIds();
      final prefs = await SharedPreferences.getInstance();
      final seenIds =
          (prefs.getStringList(_seenIdsKey(user.id)) ?? const []).toSet();
      final unseenCount = firedIds.difference(seenIds).length;
      ref.read(unreadAlertsProvider.notifier).updateCount(unseenCount);
    } catch (_) {
      // Best-effort: leave the previous count as-is on a transient failure
      // (e.g. offline, or the backend is momentarily unreachable).
    }
  }

  /// Marks every currently-fired alert as seen — call when the user opens
  /// the Alerts tab, so the pulsing bell / unread badge clears.
  Future<void> markAllSeen() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    try {
      final firedIds = await _fetchFiredAlertIds();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_seenIdsKey(user.id), firedIds.toList());
    } catch (_) {
      // Best-effort; if this fails the badge will just reappear on the next
      // poll instead of staying cleared.
    }
    ref.read(unreadAlertsProvider.notifier).updateCount(0);
  }

  String _seenIdsKey(String userId) => 'seen_fired_alert_ids_$userId';
}

final firedAlertsProvider = NotifierProvider<FiredAlertsNotifier, void>(
  FiredAlertsNotifier.new,
);
