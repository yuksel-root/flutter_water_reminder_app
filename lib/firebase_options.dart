import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }

    throw UnsupportedError(
      'Firebase options are not configured for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAHaytNnLL3GI7Pa930NxrDNmwzOxr6F8k',
    appId: '1:561937732713:android:369553c48aee82a21bbef8',
    messagingSenderId: '561937732713',
    projectId: 'tr-flutter-water-reminder',
    storageBucket: 'tr-flutter-water-reminder.firebasestorage.app',
  );
}
