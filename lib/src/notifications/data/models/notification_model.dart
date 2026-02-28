import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:translate/src/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
    super.targetId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] as String? ?? 'system',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetId: data['targetId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (targetId != null) 'targetId': targetId,
    };
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      targetId: entity.targetId,
    );
  }
}
