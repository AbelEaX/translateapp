import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translate/src/notifications/data/models/notification_model.dart';
import 'package:translate/src/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> saveNotification(String userId, NotificationEntity notification);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  const NotificationRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _notifCol(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _notifCol(userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => NotificationModel.fromFirestore(d)).toList(),
        );
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _notifCol(userId).doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final unread = await _notifCol(
      userId,
    ).where('isRead', isEqualTo: false).get();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> saveNotification(
    String userId,
    NotificationEntity notification,
  ) async {
    final model = NotificationModel.fromEntity(notification);
    await _notifCol(userId).doc(notification.id).set(model.toFirestore());
  }
}
