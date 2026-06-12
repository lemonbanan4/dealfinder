import 'package:flutter_riverpod/flutter_riverpod.dart';

class _UnreadAlertsNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void updateCount(int count) => state = count;
}

final unreadAlertsProvider = NotifierProvider<_UnreadAlertsNotifier, int>(
  _UnreadAlertsNotifier.new,
);
