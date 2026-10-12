import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  Future<void> _updateUserStatus(
    String docId,
    String name,
    String newStatus,
  ) async {
    try {
      // 1. Update user status in 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'status': newStatus,
        'approvedAt': newStatus == 'active' ? FieldValue.serverTimestamp() : null,
      });

      // 2. Add entry to activity logs
      final actionTitle =
          newStatus == 'active' ? 'User Approved' : 'User Rejected';
      final details = '$name (User) status changed to $newStatus.';

      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': actionTitle,
        'details': details,
        'performedBy': 'Admin',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name has been $newStatus'),
          backgroundColor: newStatus == 'active' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Pending Users'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading pending users: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No pending users found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final docId = doc.id;

              final name = data['name'] ?? 'Unknown Name';
              final email = data['email'] ?? 'No Email';
              final type = (data['role'] ?? 'Customer').toString();
              final Timestamp? createdAt = data['createdAt'] as Timestamp?;

              String formattedDate = 'Recent';
              if (createdAt != null) {
                final date = createdAt.toDate();
                formattedDate =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xff032744).withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xff032744),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email),
                        const SizedBox(height: 2),
                        Text(
                          'Type: $type',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Date: $formattedDate',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'approve') {
                        _updateUserStatus(docId, name, 'active');
                      } else if (value == 'reject') {
                        _updateUserStatus(docId, name, 'rejected');
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'approve',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Approve', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reject',
                        child: Row(
                          children: [
                            Icon(Icons.close, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Reject', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}