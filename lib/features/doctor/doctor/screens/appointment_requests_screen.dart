import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppointmentRequestsScreen extends StatefulWidget {
  const AppointmentRequestsScreen({super.key});

  @override
  State<AppointmentRequestsScreen> createState() =>
      _AppointmentRequestsScreenState();
}

class _AppointmentRequestsScreenState
    extends State<AppointmentRequestsScreen> {
  static const Color _primary = Color(0xff032744);

  User? get _currentDoctor => FirebaseAuth.instance.currentUser;

  Future<void> _updateAppointmentStatus(
    String docId,
    String appointmentId,
    String newStatus,
    String patientEmail,
  ) async {
    try {
      // 1. Update appointment status in Firestore
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Add entry to activity logs
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': 'Appointment $newStatus',
        'details':
            'Appointment $appointmentId for $patientEmail was set to $newStatus.',
        'performedBy': _currentDoctor?.email ?? 'Doctor',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment $newStatus successfully'),
          backgroundColor:
              newStatus == 'Approved' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentDoctor?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Requests'),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No logged-in doctor found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Appointment Requests'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Fetch appointments strictly belonging to THIS logged-in doctor
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading requests: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No appointment requests found.',
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
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final docId = doc.id;

              final apptId = data['id'] ?? 'N/A';
              final patientEmail = data['userEmail'] ?? 'Patient';
              final date = data['date'] ?? 'N/A';
              final time = data['time'] ?? 'N/A';
              final type = data['type'] ?? 'In-person';
              final status = data['status'] ?? 'Upcoming';
              final reason = data['reason'] ?? 'No reason specified';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: _primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patientEmail,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'Booking #$apptId',
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusBgColor(status),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _getStatusTextColor(status),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$date at $time',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (reason.toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Note: $reason',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (status == 'Upcoming' || status == 'Pending') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateAppointmentStatus(
                                  docId,
                                  apptId,
                                  'Cancelled',
                                  patientEmail,
                                ),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                ),
                                label: const Text('Decline'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateAppointmentStatus(
                                  docId,
                                  apptId,
                                  'Approved',
                                  patientEmail,
                                ),
                                icon: const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                ),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green.withValues(alpha: 0.1);
      case 'Upcoming':
        return Colors.blue.withValues(alpha: 0.1);
      case 'Cancelled':
        return Colors.red.withValues(alpha: 0.1);
      default:
        return Colors.orange.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Upcoming':
        return Colors.blue;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}