import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web; // Ab ye error nahi dega, direct web settings uthayega

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // --- AAPKI WEB CONFIGURATION ---
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUI1S4M-F0cpNya7hpgA3ofiShGgsKwqs',
    authDomain: 'peergradingapp.firebaseapp.com',
    projectId: 'peergradingapp',
    storageBucket: 'peergradingapp.firebasestorage.app',
    messagingSenderId: '691208521821',
    appId: '1:691208521821:web:6d5f209374c8c588f3e5b4',
    measurementId: 'G-KC4EC77WEP',
  );

  // --- AAPKI ANDROID CONFIGURATION ---
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDt3y1-9l58kipmaKAYOPDYJmxfrn8XypQ',
    appId: '1:691208521821:android:8db9ddecda2e850df3e5b4',
    messagingSenderId: '691208521821',
    projectId: 'peergradingapp',
    storageBucket: 'peergradingapp.firebasestorage.app',
  );
}