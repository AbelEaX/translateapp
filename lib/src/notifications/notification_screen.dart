import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:translate/src/notifications/domain/entities/notification_entity.dart';
import 'package:translate/src/notifications/presentation/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final hasUnread = provider.unreadCount > 0;
              return IconButton(
                icon: Icon(
                  Icons.done_all_rounded,
                  color: hasUnread
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimary.withValues(alpha: 0.4),
                ),
                onPressed: hasUnread ? provider.markAllAsRead : null,
                tooltip: 'Mark all as read',
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load notifications',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'New notifications will appear here.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notif = provider.notifications[index];
              return _NotificationCard(
                notification: notif,
                onTap: () => provider.markAsRead(notif.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRead = notification.isRead;

    late final IconData icon;
    late final Color iconBg;
    late final Color iconColor;

    switch (notification.type) {
      case 'upvote':
        icon = Icons.thumb_up_rounded;
        iconBg = cs.primaryContainer;
        iconColor = cs.onPrimaryContainer;
      case 'comment':
        icon = Icons.chat_bubble_rounded;
        iconBg = cs.secondaryContainer;
        iconColor = cs.onSecondaryContainer;
      case 'badge':
        icon = Icons.stars_rounded;
        iconBg = cs.tertiaryContainer;
        iconColor = cs.onTertiaryContainer;
      default: // 'system'
        icon = Icons.notifications_active_rounded;
        iconBg = cs.surfaceContainerHighest;
        iconColor = cs.onSurfaceVariant;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? theme.cardColor : cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? cs.outlineVariant : cs.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                fontSize: 15,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
