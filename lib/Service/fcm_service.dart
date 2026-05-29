import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

// Must be top-level for FCM background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by FCM as system notifications.
  // No action needed here unless you want custom processing.
}

class FcmService {
  FcmService._();

  static bool _initialized = false;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'kaf8_channel',
    'KAF8 Notifications',
    description: 'Order updates and delivery alerts',
    importance: Importance.high,
    playSound: true,
  );

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission (iOS prompt; Android 13+ prompt)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      // Initialize local notifications for foreground display
      await _initLocalNotifications();

      // Get FCM token and send to backend
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _uploadToken(token);

      // Refresh token when it changes
      FirebaseMessaging.instance.onTokenRefresh.listen(_uploadToken);

      // Show notification banner when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForeground);

      // Ensure foreground notifications are shown on iOS too
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('[FCM] init skipped: $e');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Create the high-importance channel on Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<void> _uploadToken(String token) async {
    try {
      await ApiService.updateFcmToken(token);
      debugPrint('[FCM] token uploaded to backend');
    } catch (e) {
      debugPrint('[FCM] token upload failed: $e');
    }
  }

  /// Call this immediately after a successful login so the FCM token
  /// is uploaded with a valid auth token. Safe to call multiple times.
  static Future<void> uploadCurrentToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('[FCM] uploadCurrentToken skipped: Firebase not initialized');
        return;
      }
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM] current token: ${token != null ? token.substring(0, 20) + "..." : "null"}');
      if (token != null) await _uploadToken(token);
    } catch (e) {
      debugPrint('[FCM] uploadCurrentToken failed: $e');
    }
  }

  static void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final title = notification.title ?? 'KAF8';
    final body = notification.body ?? '';

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    debugPrint('[FCM] foreground shown: $title — $body');
  }

  static Future<bool> isNotificationPermissionDenied() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.denied;
    } catch (_) {
      return false;
    }
  }
}
