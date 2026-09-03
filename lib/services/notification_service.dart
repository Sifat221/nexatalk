import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handling if required by the operating system
}

/// Firebase Cloud Messaging (FCM) Notification Service.
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initializes FCM permissions, token retrieval, token refresh listeners,
  /// foreground message listener, and background message handler.
  Future<void> init(String? userId, {String? webVapidKey}) async {
    try {
      // 1. Request user permission for push notifications
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isAuthorized) return;

      // 2. Retrieve FCM device token
      if (kIsWeb) {
        if (webVapidKey != null && webVapidKey.isNotEmpty) {
          _fcmToken = await _fcm.getToken(vapidKey: webVapidKey);
        } else {
          // Web Push requires VAPID key from Firebase Console
          if (kDebugMode) {
            print('FCM Web Push requires a VAPID key configured in Firebase Console.');
          }
        }
      } else {
        _fcmToken = await _fcm.getToken();
      }

      if (_fcmToken != null && userId != null) {
        await registerDeviceToken(userId, _fcmToken!);
      }

      // 3. Listen to token refreshes
      _fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (userId != null) {
          registerDeviceToken(userId, newToken);
        }
      });

      // 4. Register background handler (Mobile platforms)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

      // 5. Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Received foreground notification: ${message.notification?.title} - ${message.notification?.body}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService init error (graceful fallback): $e');
      }
    }
  }

  /// Saves FCM token to user document in Firestore.
  Future<void> registerDeviceToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
