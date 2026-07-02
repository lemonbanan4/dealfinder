import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/deals/presentation/home_page.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure that Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://sarlvquwjdufemyizjwj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNhcmx2cXV3amR1ZmVteWl6andqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyNDQ1NTgsImV4cCI6MjA5NzgyMDU1OH0.fcpQ-mRD-Rgi60oDLnmm3h24saZmn_c14En_vQEnU8Y',
  );
  // Wrap the entire app in a ProviderScope for Riverpod.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DealFinder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
