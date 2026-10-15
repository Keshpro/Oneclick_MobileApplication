import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  static const Color _navy = Color(0xFF1E293B);

  // Firestore Timestamp එක readable Date/Time බවට පත් කරන helper function එක
  String _formatTimestamp(dynamic timestampField, String fallbackDate, String fallbackTime) {
    if (timestampField is Timestamp) {
      final dateTime = timestampField.toDate();
      final dateStr = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
      final hourStr = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final timeStr = "${hourStr.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm";
      return "$dateStr at $timeStr";
    }
    
    if (fallbackDate != 'N/A' && fallbackTime != 'N/A') {
      return "$fallbackDate at $fallbackTime";
    }
    
    return fallbackDate != 'N/A' ? fallbackDate : 'Recent';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Work Appointments'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to view your bookings.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Fetch bookings for current customer sorted by createdAt
              stream: FirebaseFirestore.instance
                  .collection('work_appointments')
                  .where('customerId', isEqualTo: currentUser.uid)
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
                        'Error fetching data: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No active bookings found.',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final booking = docs[index].data();
                    final workerName = booking['workerName'] ?? 'Technician';
                    final category = booking['category'] ?? 'Quick Fix';
                    final date = booking['date']?.toString() ?? 'N/A';
                    final time = booking['time']?.toString() ?? 'N/A';
                    final status = booking['status']?.toString() ?? 'Pending';
                    final createdAt = booking['createdAt'];
                    final address = booking['address']?.toString() ?? '';

                    final formattedDateTime = _formatTimestamp(createdAt, date, time);

                    Color statusColor = Colors.orange;
                    if (status.toLowerCase() == 'accepted' || status.toLowerCase() == 'approved') {
                      statusColor = Colors.green;
                    } else if (status.toLowerCase() == 'rejected' || status.toLowerCase() == 'cancelled') {
                      statusColor = Colors.red;
                    } else if (status.toLowerCase() == 'completed') {
                      statusColor = Colors.blue;
                    }

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  workerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Service: $category',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5B4DFF)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.event_outlined,
                                    size: 16, color: Color(0xFF64748B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    formattedDateTime,
                                    style: const TextStyle(
                                        fontSize: 12.5, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            if (address.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: const TextStyle(
                                          fontSize: 12.5, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (booking['issue'] != null &&
                                booking['issue'].toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Issue: ${booking['issue']}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF334155)),
                                ),
                              ),
                            ],
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