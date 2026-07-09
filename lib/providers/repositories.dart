import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/alerts/data/alert_repository.dart';
import '../features/alerts/data/firestore_alert_repository.dart';
import '../features/deals/data/deal_repository.dart';
import '../features/deals/data/firestore_deal_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../services/affiliate_router.dart';

final dealRepositoryProvider = Provider<DealRepository>(
  (_) => DealRepository(),
  name: 'dealRepositoryProvider',
);

final alertRepositoryProvider = Provider<AlertRepository>(
  (_) => AlertRepository(),
  name: 'alertRepositoryProvider',
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => SettingsRepository(),
  name: 'settingsRepositoryProvider',
);

final firestoreAlertRepositoryProvider = Provider<FirestoreAlertRepository>(
  (_) => FirestoreAlertRepository(),
  name: 'firestoreAlertRepositoryProvider',
);

final firestoreDealRepositoryProvider = Provider<FirestoreDealRepository>(
  (_) => FirestoreDealRepository(),
  name: 'firestoreDealRepositoryProvider',
);

final affiliateRouterProvider = Provider<AffiliateRouter>(
  (_) => const AffiliateRouter(),
  name: 'affiliateRouterProvider',
);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
  name: 'sharedPreferencesProvider',
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
  name: 'firestoreProvider',
);
