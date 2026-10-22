
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/quickfix_notification_service.dart';
import '../screens/quickfix_notifications_screen.dart';

class NotificationBell extends StatelessWidget {
  NotificationBell({super.key});

  final QuickFixNotificationService _service =
      QuickFixNotificationService();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<int>(
      stream: _service.getUnreadCount(uid),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return IconButton(
          tooltip: 'QuickFix Notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    QuickFixNotificationsScreen(),
              ),
            );
          },
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text(count > 99 ? '99+' : '$count'),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
