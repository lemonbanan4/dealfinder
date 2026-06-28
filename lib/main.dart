import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'services/background_refresh_service.dart';
import 'services/notification/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await _openBoxes();

  await Supabase.initialize(
    url: 'https://sarlvquwjdufemyizjwj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhcmx2cXV3amR1ZmVteWl6andqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNDQ1NTgsImV4cCI6MjA5NzgyMDU1OH0.fcpQ-mRD-Rgi60oDLnmm3h24saZmn_c14En_vQEnU8Y',
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Completely disable App Check and Background Tasks on the Web to prevent crashes
    if (!kIsWeb) {
      if (!kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: const AndroidPlayIntegrityProvider(),
          providerApple: const AppleDeviceCheckProvider(),
        );
      }
      
      await FCMService.initialize();
      initializeBackgroundTasks();
    }
  } catch (e) {
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