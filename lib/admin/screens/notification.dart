
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const Color teal = Color(0xFF0D9488);
  static const Color dark = Color(0xFF102D38);
  static const Color bg = Color(0xFFF5F8FA);

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  String _text(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) return 'Date unavailable';

    final date = value.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (!difference.isNegative) {
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      }
      if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      }
      if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      }
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _notificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'doctor':
      case 'appointment':
        return Icons.medical_services_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'grocery':
      case 'groceries':
        return Icons.shopping_basket_rounded;
      case 'driver':
      case 'drunk_drive':
        return Icons.directions_car_rounded;
      case 'quickfix':
        return Icons.handyman_rounded;
      case 'payment':
        return Icons.payments_rounded;
      case 'security':
        return Icons.security_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Future<void> _markRead(
    String uid,
    String notificationId,
  ) async {
    await _collection(uid).doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> _markAllRead(
    String uid,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final unread = docs.where(
      (doc) => doc.data()['isRead'] != true,
    ).toList();

    if (unread.isEmpty) return;

    // Firestore batches have a write limit.
    for (var start = 0; start < unread.length; start += 400) {
      final end = start + 400 < unread.length
          ? start + 400
          : unread.length;

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in unread.sublist(start, end)) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    }
  }

  void _showDetails(
    BuildContext context,
    String title,
    String body,
    String date,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: teal,
                  size: 34,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(sheetContext),
                    style: FilledButton.styleFrom(
                      backgroundColor: teal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 72,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Stay updated with OneClick',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: user == null
          ? const Center(
              child: Text('Please sign in to view notifications.'),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _collection(user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _emptyState(
                    Icons.error_outline_rounded,
                    'Unable to load notifications',
                    'Check your connection and Firestore permissions.',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: teal),
                  );
                }

                final docs = snapshot.data!.docs;

                final unreadCount = docs
                    .where((doc) => doc.data()['isRead'] != true)
                    .length;

                if (docs.isEmpty) {
                  return _emptyState(
                    Icons.notifications_none_rounded,
                    'You are all caught up!',
                    'Your notifications will appear here.',
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20, 20, 20, 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              unreadCount == 0
                                  ? 'All notifications read'
                                  : '$unreadCount unread notifications',
                              style: const TextStyle(
                                color: dark,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (unreadCount > 0)
                            TextButton(
                              onPressed: () async {
                                try {
                                  await _markAllRead(user.uid, docs);
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Unable to mark all as read',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Mark all read',
                                style: TextStyle(color: teal),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          20, 4, 20, 30,
                        ),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 11),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();

                          final title = _text(
                            data['title'],
                            'OneClick Notification',
                          );

                          final body = _text(
                            data['body'] ?? data['message'],
                            'You have a new update.',
                          );

                          final type = _text(
                            data['type'],
                            'general',
                          );

                          final isRead = data['isRead'] == true;

                          final date = _formatDate(
                            data['createdAt'],
                          );

                          return Material(
                            color: isRead
                                ? Colors.white
                                : const Color(0xFFE9F7F5),
                            borderRadius: BorderRadius.circular(19),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(19),
                              onTap: () async {
                                if (!isRead) {
                                  try {
                                    await _markRead(
                                      user.uid,
                                      doc.id,
                                    );
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unable to mark as read',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }

                                if (!context.mounted) return;

                                _showDetails(
                                  context,
                                  title,
                                  body,
                                  date,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(19),
                                  border: Border.all(
                                    color: isRead
                                        ? const Color(0xFFE7EDEF)
                                        : teal.withValues(alpha: .22),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: teal.withValues(
                                          alpha: .10,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _notificationIcon(type),
                                        color: teal,
                                        size: 23,
                                      ),
                                    ),
                                    const SizedBox(width: 13),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              color: dark,
                                              fontSize: 14,
                                              fontWeight: isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            body,
                                            maxLines: 3,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              height: 1.5,
                                            ),
                                          ),
                                          const SizedBox(height: 9),
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 9,
                                        height: 9,
                                        decoration: const BoxDecoration(
                                          color: teal,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _emptyState(
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: teal, size: 65),
            const SizedBox(height: 17),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: dark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
