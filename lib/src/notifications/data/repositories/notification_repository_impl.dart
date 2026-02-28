import 'package:translate/src/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:translate/src/notifications/domain/entities/notification_entity.dart';
import 'package:translate/src/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  const NotificationRepositoryImpl({
    required NotificationRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Stream<List<NotificationEntity>> getNotifications(String userId) =>
      _dataSource.getNotifications(userId);

  @override
  Future<void> markAsRead(String userId, String notificationId) =>
      _dataSource.markAsRead(userId, notificationId);

  @override
  Future<void> markAllAsRead(String userId) =>
      _dataSource.markAllAsRead(userId);

  @override
  Future<void> saveNotification(
    String userId,
    NotificationEntity notification,
  ) => _dataSource.saveNotification(userId, notification);
}
