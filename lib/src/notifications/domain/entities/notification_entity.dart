/// Pure Dart domain entity — no Firebase imports.
class NotificationEntity {
  final String id;
  final String type; // 'upvote' | 'comment' | 'badge' | 'system'
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? targetId; // translationId, communityId, etc.

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.targetId,
  });

  NotificationEntity copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    String? targetId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      targetId: targetId ?? this.targetId,
    );
  }
}
