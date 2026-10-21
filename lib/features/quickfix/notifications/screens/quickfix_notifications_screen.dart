
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/quickfix_notification_service.dart';

class QuickFixNotificationsScreen extends StatelessWidget {
  QuickFixNotificationsScreen({super.key});

  final QuickFixNotificationService _service =
      QuickFixNotificationService();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('QuickFix Notifications'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: uid == null
          ? const Center(
              child: Text('Please login to view notifications'),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _service.getNotifications(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load notifications'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final notifications = snapshot.data!.docs.toList();

                notifications.sort((a, b) {
                  final aTime =
                      a.data()['createdAt'] as Timestamp?;
                  final bTime =
                      b.data()['createdAt'] as Timestamp?;

                  return (bTime?.millisecondsSinceEpoch ?? 0)
                      .compareTo(
                    aTime?.millisecondsSinceEpoch ?? 0,
                  );
                });

                if (notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 65,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text('No notifications yet'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final doc = notifications[index];
                    final data = doc.data();

                    final isRead = data['isRead'] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isRead
                          ? Colors.white
                          : const Color(0xFFEFF6FF),
                      child: ListTile(
                        leading: Icon(
                          isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                          color: const Color(0xFF1E293B),
                        ),
                        title: Text(
                          (data['title'] ?? 'Notification')
                              .toString(),
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          (data['message'] ?? '').toString(),
                        ),
                        trailing: isRead
                            ? null
                            : const Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.blue,
                              ),
                        onTap: () async {
                          if (!isRead) {
                            try {
                              await _service.markAsRead(doc.id);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not mark as read: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
