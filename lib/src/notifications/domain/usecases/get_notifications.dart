import 'package:translate/src/notifications/domain/entities/notification_entity.dart';
import 'package:translate/src/notifications/domain/repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;
  const GetNotifications(this.repository);

  Stream<List<NotificationEntity>> call(String userId) =>
      repository.getNotifications(userId);
}
