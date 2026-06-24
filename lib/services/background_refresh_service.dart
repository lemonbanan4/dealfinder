import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';
import '../features/alerts/domain/alert_config.dart';
import '../features/alerts/domain/price_alert.dart';
import '../features/alerts/providers/alerts_provider.dart';
import '../features/deals/domain/deal.dart';
import '../firebase_options.dart';
import '../providers/repositories.dart';
import 'notification/native_notification_service.dart';

class AlertEvaluationService {
  static Future<List<Deal>> evaluate(List<Deal> deals) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final configsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('alert_configs');

    final snapshot = await configsRef.get();
    final configs = snapshot.docs
        .map((doc) => AlertConfig.fromMap(doc.data()))
        .toList();

    final dealsMap = {for (final d in deals) d.id: d};
    final droppedDeals = <Deal>[];

    for (final config in configs) {
      final liveDeal = dealsMap[config.productId];
      if (liveDeal != null && liveDeal.currentPrice <= config.targetPrice) {
        droppedDeals.add(liveDeal);
        await configsRef.doc(config.id).delete();
      }
    }
    return droppedDeals;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  if (!kIsWeb) {
    Workmanager().executeTask((task, inputData) async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        await Hive.initFlutter();
        await Future.wait([
          Hive.openBox<String>(HiveBoxes.alerts),
          Hive.openBox<String>(HiveBoxes.deals),
          Hive.openBox<String>(HiveBoxes.scraperConfigs),
          Hive.openBox<String>(HiveBoxes.currencyRates),
          Hive.openBox<String>(HiveBoxes.settings),
        ]);

        final container = ProviderContainer();

        final scraperService = container.read(scraperServiceProvider);
        final dealRepo = container.read(dealRepositoryProvider);
        final configs = dealRepo
            .getConfigs()
            .where((c) => c.isEnabled)
            .toList();

        final allDeals = <Deal>[];
        for (final config in configs) {
          try {
            final deals = await scraperService.scrape(config);
            allDeals.addAll(deals);
          } catch (_) {}
        }

        // Persist scraped deals so the feed is fresh when the user opens the app.
        if (allDeals.isNotEmpty) {
          await dealRepo.saveAll(allDeals);
          if (FirebaseAuth.instance.currentUser != null) {
            await container
                .read(firestoreDealRepositoryProvider)
                .upsertDeals(allDeals);
          }
        }

        final droppedDeals = await AlertEvaluationService.evaluate(allDeals);

        await PlatformNotificationService().initialize();

        for (final deal in droppedDeals) {
          const title = 'Price Drop Alert!';
          final message =
              '${deal.title} is now only ${deal.currentPrice.round()} ${deal.currency}!';

          await PlatformNotificationService().showPriceAlert(
            id: deal.id.hashCode,
            title: title,
            body: message,
            payload: deal.url,
          );

          final newAlert = PriceAlert(
            id: '${DateTime.now().millisecondsSinceEpoch}_${deal.id}',
            title: title,
            message: message,
            time: DateTime.now(),
            isRead: false,
          );
          container.read(alertsProvider.notifier).addAlert(newAlert);
        }

        if (!kIsWeb && await FlutterAppBadger.isAppBadgeSupported()) {
          FlutterAppBadger.updateBadgeCount(droppedDeals.length);
        }

        container.dispose();
        return Future.value(true);
      } catch (_) {
        return Future.value(false);
      }
    });
  }
}

void initializeBackgroundTasks() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  Workmanager().registerPeriodicTask(
    'price_alert_task',
    'checkPriceDrops',
    frequency: const Duration(hours: 12),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
