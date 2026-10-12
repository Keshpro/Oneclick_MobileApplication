import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivityLogs extends StatelessWidget {
  const ActivityLogs({super.key});

  static const Color _primary = Color(0xff032744);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Activity Logs'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Fetch real-time logs from Firestore ordered by timestamp
        stream: FirebaseFirestore.instance
            .collection('activity_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading activity logs: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final logs = snapshot.data?.docs ?? [];

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No activity logs recorded yet.',
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
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final data = logs[index].data();
              final action = data['action'] ?? 'System Event';
              final details = data['details'] ?? 'No detailed description.';
              final performedBy = data['performedBy'] ?? 'Admin';
              final timestamp = data['timestamp'] as Timestamp?;

              String timeString = 'Just now';
              if (timestamp != null) {
                final date = timestamp.toDate();
                timeString =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
              }

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: _primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              details,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'By: $performedBy',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _primary,
                                  ),
                                ),
                                Text(
                                  timeString,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
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