import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:translate/src/notifications/domain/entities/notification_entity.dart';
import 'package:translate/src/notifications/domain/repositories/notification_repository.dart';
import 'package:uuid/uuid.dart';

/// Top-level background message handler — must be a free function with
/// the `@pragma('vm:entry-point')` annotation so it runs in its own isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialised by the OS before this is called.
  debugPrint('[FCM background] ${message.notification?.title}');
}

/// Initialises FCM, local notifications, and wires all message listeners.
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore;
  final NotificationRepository _repository;

  static const _androidChannel = AndroidNotificationChannel(
    'gotranslate_high',
    'GoTranslate Notifications',
    description: 'Translation upvotes, badges, and community updates.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Broadcast stream that the AppShell / overlays listen to for in-app banners.
  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundMessageController.stream;

  NotificationService({
    required FirebaseFirestore firestore,
    required NotificationRepository repository,
  }) : _firestore = firestore,
       _repository = repository;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Call once after the user is authenticated.
  Future<void> initialize(String userId) async {
    await _requestPermissions();
    await _setupLocalNotifications();
    await _saveToken(userId);
    _listenToTokenRefresh(userId);
    _listenToForegroundMessages(userId);
    _listenToNotificationTaps(userId);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _requestPermissions() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    // Android 13+ runtime permission is handled by the plugin automatically.
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(settings: settings);

    // Create the Android notification channel (required for Android 8+)
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(_androidChannel);
    }
    // On iOS tell FCM to show banners even when the app is in foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _saveToken(String userId) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _listenToTokenRefresh(String userId) {
    _fcm.onTokenRefresh.listen((token) async {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  void _listenToForegroundMessages(String userId) {
    FirebaseMessaging.onMessage.listen((message) async {
      // 1. Emit to in-app overlay stream
      _foregroundMessageController.add(message);

      // 2. Show a local notification (Android only; iOS shows by default)
      if (!kIsWeb && Platform.isAndroid) {
        final notification = message.notification;
        final android = message.notification?.android;
        if (notification != null && android != null) {
          await _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
        }
      }

      // 3. Persist in Firestore
      await _persistMessage(userId, message);
    });
  }

  void _listenToNotificationTaps(String userId) {
    // App was in the background and user tapped the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _persistMessage(userId, message);
    });
  }

  Future<void> _persistMessage(String userId, RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    final entity = NotificationEntity(
      id: message.messageId ?? const Uuid().v4(),
      type: message.data['type'] as String? ?? 'system',
      title: notif.title ?? '',
      body: notif.body ?? '',
      isRead: false,
      createdAt: message.sentTime ?? DateTime.now(),
      targetId: message.data['targetId'] as String?,
    );

    await _repository.saveNotification(userId, entity);
  }

  void dispose() {
    _foregroundMessageController.close();
  }
}
