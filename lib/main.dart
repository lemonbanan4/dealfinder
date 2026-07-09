import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/constants.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure that Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // On web, Google Sign-In goes through Firebase's own popup/redirect flow
  // (see AuthRepository.signInWithGoogle), so the google_sign_in plugin only
  // needs initializing on native platforms. Its docs require this be called
  // exactly once, before any other method on the instance.
  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize();
  }

  // Repositories (settings, deals, alerts) read their Hive box
  // synchronously, so every box must be open before runApp builds the tree.
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<String>(HiveBoxes.alerts),
    Hive.openBox<String>(HiveBoxes.deals),
    Hive.openBox<String>(HiveBoxes.settings),
  ]);

  await Supabase.initialize(
    url: 'https://sarlvquwjdufemyizjwj.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhcmx2cXV3amR1ZmVteWl6andqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNDQ1NTgsImV4cCI6MjA5NzgyMDU1OH0.fcpQ-mRD-Rgi60oDLnmm3h24saZmn_c14En_vQEnU8Y',
  );
  // Wrap the entire app in a ProviderScope for Riverpod.
  runApp(const ProviderScope(child: PrisPulsApp()));
}
