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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS yet.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows yet.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux yet.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAR7wdZPCp_tDnoLRFZ8MGqdhh7zAoafsY',
    appId: '1:310545818725:web:6a90339f5bcd12f274128c',
    messagingSenderId: '310545818725',
    projectId: 'qrkod-549133f4',
    authDomain: 'qrkod-549133f4.firebaseapp.com',
    storageBucket: 'qrkod-549133f4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA39a2VJJt8XJfkLjQ3j4yxyhjWOIBu9vw',
    appId: '1:310545818725:android:a2003422ba23e93474128c',
    messagingSenderId: '310545818725',
    projectId: 'qrkod-549133f4',
    storageBucket: 'qrkod-549133f4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZuWY1g-VcJnKI0sX1ikhes6Mux78tYdw',
    appId: '1:310545818725:ios:6d7f8556f479b66c74128c',
    messagingSenderId: '310545818725',
    projectId: 'qrkod-549133f4',
    storageBucket: 'qrkod-549133f4.firebasestorage.app',
    iosBundleId: 'com.qrscanner.professional',
  );

}