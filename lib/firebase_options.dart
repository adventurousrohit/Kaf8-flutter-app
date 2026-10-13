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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace with your project's Web Firebase configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR-WEB-API-KEY',
    appId: 'YOUR-WEB-APP-ID',
    messagingSenderId: 'YOUR-MESSAGING-SENDER-ID',
    projectId: 'kaf8-delivery',
    authDomain: 'kaf8-delivery.firebaseapp.com',
    storageBucket: 'kaf8-delivery.appspot.com',
  );

  // TODO: Replace with your project's Android Firebase configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: 'YOUR-ANDROID-APP-ID',
    messagingSenderId: 'YOUR-MESSAGING-SENDER-ID',
    projectId: 'kaf8-delivery',
    storageBucket: 'kaf8-delivery.appspot.com',
  );

  // TODO: Replace with your project's iOS Firebase configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: 'YOUR-IOS-APP-ID',
    messagingSenderId: 'YOUR-MESSAGING-SENDER-ID',
    projectId: 'kaf8-delivery',
    storageBucket: 'kaf8-delivery.appspot.com',
    iosBundleId: 'com.kaf8.delivery',
  );
}
