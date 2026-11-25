
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState
    extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primary = Color(0xFF059669);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  String? _cancellingId;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _status(Map<String, dynamic> data) {
    return data['status']?.toString() ?? '';
  }

  bool _isUnpaidDraft(Map<String, dynamic> data) {
    return _status(data).toLowerCase() ==
        'awaiting_payment';
  }

  // Legacy Approved bookings are preserved for compatibility.
  // New confirmed bookings must originate from verified payments.
  bool _matchesTab(
    Map<String, dynamic> data,
    int tab,
  ) {
    if (_isUnpaidDraft(data)) return false;

    final status = _status(data).toLowerCase();

    switch (tab) {
      case 0:
        return status == 'approved' ||
            status == 'confirmed';

      case 1:
        return status == 'upcoming' ||
            status == 'rescheduled';

      case 2:
        return status == 'completed';

      case 3:
        return status == 'cancelled';

      default:
        return false;
    }
  }

  String _displayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'approved':
        return 'Approved';
      case 'upcoming':
        return 'Upcoming';
      case 'rescheduled':
        return 'Rescheduled';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
      case 'completed':
        return primary;

      case 'cancelled':
        return const Color(0xFFDC2626);

      default:
        return const Color(0xFFD97706);
    }
  }

  Future<void> _cancelAppointment(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    if (_cancellingId != null) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment? '
          'Any payment refund must be handled separately '
          'according to the service refund policy.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Keep Appointment'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text(
              'Cancel Appointment',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cancellingId = doc.id);

    try {
      final data = doc.data();

      if (data['userId'] != user.uid) {
        throw StateError(
          'Appointment does not belong to this user.',
        );
      }

      // For paid bookings, cancellation/refund
      // should be handled by a trusted backend.
      final paid = data['paymentStatus'] == 'paid' ||
          (data['paymentId'] != null &&
              data['paymentId']
                  .toString()
                  .isNotEmpty);

      if (paid) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Paid appointments require the cancellation '
              'and refund workflow. Please contact support.',
            ),
          ),
        );
        return;
      }

      // Legacy unpaid bookings only.
      await doc.reference.update({
        'status': 'Cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doctorId =
          data['doctorId']?.toString() ?? '';

      if (doctorId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('notifications')
              .add({
            'userId': doctorId,
            'type': 'APPOINTMENT_CANCELLED',
            'title': 'Appointment Cancelled',
            'message':
                '${data['userName'] ?? 'Patient'} '
                'cancelled an appointment.',
            'isRead': false,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          // Appointment update already succeeded.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to cancel appointment.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cancellingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: dark,
        elevation: 0,
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              16, 0, 16, 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: muted,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'Approved'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
                Tab(text: 'Cancelled'),
              ],
            ),
          ),
        ),
      ),
      body: uid == null
          ? _emptyState('Please log in to view appointments.')
          : StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('userId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _emptyState(
                    'Unable to load appointments. '
                    'Please check Firestore permissions.',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primary,
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    4,
                    (tab) {
                      final filtered = docs.where((doc) {
                        return _matchesTab(
                          doc.data(),
                          tab,
                        );
                      }).toList();

                      return _appointmentsList(filtered);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _appointmentsList(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) {
      return _emptyState(
        'No appointments in this category.',
      );
    }

    docs.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      final aDate = aTime is Timestamp
          ? aTime.toDate()
          : DateTime(1970);

      final bDate = bTime is Timestamp
          ? bTime.toDate()
          : DateTime(1970);

      return bDate.compareTo(aDate);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();

        final doctorName =
            data['doctorName']?.toString() ?? 'Doctor';

        final specialty =
            data['specialty']?.toString() ??
                'Specialist';

        final date =
            data['date']?.toString() ?? '-';

        final time =
            data['time']?.toString() ?? '-';

        final type =
            data['type']?.toString() ?? 'In-person';

        final hospital =
            data['hospital']?.toString() ?? '-';

        final status =
            _displayStatus(_status(data));

        final active =
            status != 'Cancelled' &&
            status != 'Completed';

        final paid = data['paymentStatus'] == 'paid' ||
            (data['paymentId'] != null &&
                data['paymentId']
                    .toString()
                    .isNotEmpty);

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFECFDF5),
                    child: Icon(
                      Icons.medical_services_rounded,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: const TextStyle(
                            color: dark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: const TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status)
                          .withValues(alpha: .10),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _statusColor(status),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: border),
              const SizedBox(height: 12),

              _detailRow(
                Icons.calendar_month_outlined,
                '$date at $time',
              ),

              const SizedBox(height: 11),

              _detailRow(
                Icons.location_on_outlined,
                hospital,
              ),

              const SizedBox(height: 11),

              _detailRow(
                Icons.health_and_safety_outlined,
                type,
              ),

              if (paid) ...[
                const SizedBox(height: 11),
                _detailRow(
                  Icons.verified_rounded,
                  'Payment recorded',
                  color: primary,
                ),
              ],

              if (active && !paid) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _cancellingId == doc.id
                        ? null
                        : () => _cancelAppointment(doc),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 17,
                    ),
                    label: const Text(
                      'Cancel Appointment',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String text, {
    Color color = muted,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: muted,
              size: 56,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
