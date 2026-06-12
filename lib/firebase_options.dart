// ⚠️  STUB — replace with real output from: flutterfire configure
//
// Steps:
//   1. Create a project at https://console.firebase.google.com
//   2. Install FlutterFire CLI:  dart pub global activate flutterfire_cli
//   3. In this directory run:    flutterfire configure
//   4. That command overwrites this file with real values.
//
// Until configured, Firebase.initializeApp() will throw at runtime.
// The app will still compile and the UI will render, but cloud features
// (auth, Firestore) will not function.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'Unsupported platform: $defaultTargetPlatform — run flutterfire configure.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBpBx77l6KITM-AMWr0UsjJC8kGv_Aae3g',
    appId: '1:838381255973:web:099c08af628ae516946ecc',
    messagingSenderId: '838381255973',
    projectId: 'dealfinderpro-bc5be',
    authDomain: 'dealfinderpro-bc5be.firebaseapp.com',
    storageBucket: 'dealfinderpro-bc5be.firebasestorage.app',
    measurementId: 'G-RNH6VSHHKF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYcGVC3dVfeMvQr-TDPTETlN94ghJGW74',
    appId: '1:838381255973:android:72e3adae21cd9358946ecc',
    messagingSenderId: '838381255973',
    projectId: 'dealfinderpro-bc5be',
    storageBucket: 'dealfinderpro-bc5be.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDR8nE4E66lYQoomthjMlQCEI1qUVDip6o',
    appId: '1:838381255973:ios:0591742b5144bb5f946ecc',
    messagingSenderId: '838381255973',
    projectId: 'dealfinderpro-bc5be',
    storageBucket: 'dealfinderpro-bc5be.firebasestorage.app',
    iosBundleId: 'com.dealfinder.dealfinderPro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );
}