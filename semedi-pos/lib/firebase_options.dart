import 'package:firebase_core/firebase_core.dart';
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REDACTED_FIREBASE_KEY_ANDROID',
    appId: '1:898968076289:android:a0eaa57a16cbb3ba6ac000',
    messagingSenderId: '898968076289',
    projectId: 'semedi-8bad2',
    storageBucket: 'semedi-8bad2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REDACTED_FIREBASE_KEY_IOS',
    appId: '1:898968076289:ios:36ab1df8935a20516ac000',
    messagingSenderId: '898968076289',
    projectId: 'semedi-8bad2',
    storageBucket: 'semedi-8bad2.firebasestorage.app',
    iosBundleId: 'com.example.semedi',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "REDACTED_FIREBASE_KEY_WEB",
    authDomain: "semedi-8bad2.firebaseapp.com",
    projectId: "semedi-8bad2",
    storageBucket: "semedi-8bad2.firebasestorage.app",
    messagingSenderId: "898968076289",
    appId: "1:898968076289:web:d3234ffc61be24756ac000",
    measurementId: "G-GMWRB3WVXY",
  );
}
