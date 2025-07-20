// lib/firebase_options.dart - UPDATE ALL STORAGE BUCKETS
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

// firebase_options.dart - ADD measurementId for web
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAM-pLjWmgWkBBJbmOJ_da-VP7_0X73zD8',
  appId: '1:1020357822298:web:b51c742da1c68809cc1563',
  messagingSenderId: '1020357822298',
  projectId: 'fitoutfit-f47ae',
  authDomain: 'fitoutfit-f47ae.firebaseapp.com',
  storageBucket: 'fitoutfit-f47ae.firebasestorage.app',
  measurementId: 'G-VKTVP5F6L7', // ✅ ADD THIS IF MISSING
);

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAM-pLjWmgWkBBJbmOJ_da-VP7_0X73zD8',
    appId: '1:1020357822298:android:b455e8af1a958a58cc1563',
    messagingSenderId: '1020357822298',
    projectId: 'fitoutfit-f47ae',
    storageBucket: 'fitoutfit-f47ae.firebasestorage.app', // ✅ FIXED
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAM-pLjWmgWkBBJbmOJ_da-VP7_0X73zD8',
    appId: '1:1020357822298:ios:b455e8af1a958a58cc1563',
    messagingSenderId: '1020357822298',
    projectId: 'fitoutfit-f47ae',
    storageBucket: 'fitoutfit-f47ae.firebasestorage.app', // ✅ FIXED
    iosBundleId: 'com.example.fitoutfit',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAM-pLjWmgWkBBJbmOJ_da-VP7_0X73zD8',
    appId: '1:1020357822298:macos:b455e8af1a958a58cc1563',
    messagingSenderId: '1020357822298',
    projectId: 'fitoutfit-f47ae',
    storageBucket: 'fitoutfit-f47ae.firebasestorage.app', // ✅ FIXED
    iosBundleId: 'com.example.fitoutfit',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAM-pLjWmgWkBBJbmOJ_da-VP7_0X73zD8',
    appId: '1:1020357822298:windows:b455e8af1a958a58cc1563',
    messagingSenderId: '1020357822298',
    projectId: 'fitoutfit-f47ae',
    authDomain: 'fitoutfit-f47ae.firebaseapp.com',
    storageBucket: 'fitoutfit-f47ae.firebasestorage.app', // ✅ FIXED
  );
}
