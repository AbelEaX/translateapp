import 'package:translate/src/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationRead {
  final NotificationRepository repository;
  const MarkNotificationRead(this.repository);

  Future<void> call(String userId, String notificationId) =>
      repository.markAsRead(userId, notificationId);
}
