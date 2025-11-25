import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Theme Constants
  final Color _primaryBlue = const Color(0xFF1E3A8A);
  final Color _amberAccent = Colors.amber;

  @override
  Widget build(BuildContext context) {
    // Mock Data for UI demonstration
    final List<Map<String, dynamic>> notifications = [
      {
        'type': 'badge',
        'title': 'New Badge Unlocked!',
        'message': 'You earned the "Dialect Master" badge for 50 contributions.',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'isRead': false,
      },
      {
        'type': 'upvote',
        'title': 'Translation Upvoted',
        'message': 'Your translation for "Marketplace" reached 100 upvotes.',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
      },
      {
        'type': 'system',
        'title': 'Community Challenge',
        'message': 'Join the "Acholi Proverbs" challenge this weekend!',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            onPressed: () {},
            tooltip: "Mark all as read",
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotificationCard(context, notif);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notif) {
    final bool isBadge = notif['type'] == 'badge';
    final bool isUpvote = notif['type'] == 'upvote';
    final bool isRead = notif['isRead'];

    IconData icon;
    Color iconColor;
    Color iconBg;

    if (isBadge) {
      icon = Icons.stars_rounded;
      iconColor = _amberAccent;
      iconBg = Colors.orange.shade50;
    } else if (isUpvote) {
      icon = Icons.thumb_up_rounded;
      iconColor = _primaryBlue;
      iconBg = Colors.indigo.shade50;
    } else {
      icon = Icons.notifications_active_rounded;
      iconColor = Colors.teal;
      iconBg = Colors.teal.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: isRead ? Border.all(color: Colors.transparent) : Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notif['title'],
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _amberAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['message'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeago.format(notif['time']),
                        style: TextStyle(
                          color: Colors.grey.shade400,
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
