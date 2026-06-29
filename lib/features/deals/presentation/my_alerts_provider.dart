import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import 'price_alert.dart';

part 'my_alerts_provider.g.dart';

@riverpod
class MyAlerts extends _$MyAlerts {
  @override
  Future<List<PriceAlert>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return [];

    final SupabaseClient supabase = Supabase.instance.client;
    final data = await supabase.rpc(
      'get_alerts_with_latest_prices',
      params: {'p_user_id': user.uid},
    );

    return (data as List).map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      if (json['deals'] is List && (json['deals'] as List).isNotEmpty) {
        final dealData = (json['deals'] as List).first as Map<String, dynamic>;
        json['latest_price'] = dealData['current_price'];
        json['currency'] = dealData['currency'];
      }
      return PriceAlert.fromJson(json);
    }).toList();
  }

  Future<void> deleteAlert(int alertId) async {
    final SupabaseClient supabase = Supabase.instance.client;
    await supabase.from('price_alerts').delete().eq('id', alertId);
    ref.invalidateSelf(); // Refresh the list after deletion
  }
}
