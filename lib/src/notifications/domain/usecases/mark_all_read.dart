import 'package:translate/src/notifications/domain/repositories/notification_repository.dart';

class MarkAllRead {
  final NotificationRepository repository;
  const MarkAllRead(this.repository);

  Future<void> call(String userId) => repository.markAllAsRead(userId);
}
