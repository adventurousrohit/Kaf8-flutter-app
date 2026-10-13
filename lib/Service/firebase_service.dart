import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'fcm_service.dart';

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Returns whether Firebase has been initialized successfully.
  static bool get isInitialized => _initialized;

  /// Initializes Firebase Core with [DefaultFirebaseOptions] and sets up FCM.
  static Future<void> init() async {
    if (_initialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('[FirebaseService] Core initialized successfully');
      }

      _initialized = true;

      // Initialize Push Notifications (FCM)
      await FcmService.init();
    } catch (e) {
      debugPrint('[FirebaseService] Initialization failed: $e');
    }
  }
}
