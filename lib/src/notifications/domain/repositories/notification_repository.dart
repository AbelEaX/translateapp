import 'package:translate/src/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Real-time stream of notifications for [userId], newest first.
  Stream<List<NotificationEntity>> getNotifications(String userId);

  /// Marks a single notification as read.
  Future<void> markAsRead(String userId, String notificationId);

  /// Marks every notification for [userId] as read.
  Future<void> markAllAsRead(String userId);

  /// Persists a new notification for [userId] (called by the FCM handler).
  Future<void> saveNotification(String userId, NotificationEntity notification);
}
