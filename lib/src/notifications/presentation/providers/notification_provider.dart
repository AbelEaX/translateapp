import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:translate/src/notifications/domain/entities/notification_entity.dart';
import 'package:translate/src/notifications/domain/usecases/get_notifications.dart';
import 'package:translate/src/notifications/domain/usecases/mark_all_read.dart';
import 'package:translate/src/notifications/domain/usecases/mark_notification_read.dart';

class NotificationProvider extends ChangeNotifier {
  final GetNotifications _getNotifications;
  final MarkNotificationRead _markNotificationRead;
  final MarkAllRead _markAllRead;

  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<NotificationEntity>>? _subscription;
  String? _currentUserId;

  NotificationProvider({
    required GetNotifications getNotifications,
    required MarkNotificationRead markNotificationRead,
    required MarkAllRead markAllRead,
  }) : _getNotifications = getNotifications,
       _markNotificationRead = markNotificationRead,
       _markAllRead = markAllRead;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<NotificationEntity> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Subscribe to the real-time Firestore stream for [userId].
  /// Safe to call multiple times — cancels the previous subscription first.
  void subscribeForUser(String userId) {
    if (_currentUserId == userId) return; // already subscribed
    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _getNotifications(userId).listen(
      (notifs) {
        _notifications = notifs;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Unsubscribe when the user signs out.
  void unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    _currentUserId = null;
    _notifications = [];
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    if (_currentUserId == null) return;
    // Optimistically update UI
    _notifications = _notifications
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    notifyListeners();
    await _markNotificationRead(_currentUserId!, notificationId);
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
    await _markAllRead(_currentUserId!);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
