import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Generated for project `nexa-talk-169ff`.
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
        return ios;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyARu4t5cdgay88j0lHXQU5dwelwaiszKHQ',
    appId: '1:506043633582:web:d788f2c054106bc3c6823f',
    messagingSenderId: '506043633582',
    projectId: 'nexa-talk-169ff',
    authDomain: 'nexa-talk-169ff.firebaseapp.com',
    storageBucket: 'nexa-talk-169ff.firebasestorage.app',
    measurementId: 'G-59ZY7E5577',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5bv1_5et5pGcs4tthHjXm4MF6kX2gT0A',
    appId: '1:506043633582:android:114ab6a385497723c6823f',
    messagingSenderId: '506043633582',
    projectId: 'nexa-talk-169ff',
    storageBucket: 'nexa-talk-169ff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArh33PhURy0LtYvJXsBR4fmGv_QuYLIpc',
    appId: '1:506043633582:ios:856e4cd19705bf37c6823f',
    messagingSenderId: '506043633582',
    projectId: 'nexa-talk-169ff',
    storageBucket: 'nexa-talk-169ff.firebasestorage.app',
    iosBundleId: 'com.nexatalk.nexatalk',
  );
}
