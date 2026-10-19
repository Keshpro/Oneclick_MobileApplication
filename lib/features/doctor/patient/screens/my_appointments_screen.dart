import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primary = Color(0xFF059669);
  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentUser?.uid;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textPrimary,
        title: const Text(
          'My Appointments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                color: _primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: _textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
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
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please login to view appointments.'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('userId', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return _buildEmptyState('No appointments found.');
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentsList(docs, ['Approved']),
                      _buildAppointmentsList(docs, ['Upcoming', 'Rescheduled']),
                      _buildAppointmentsList(docs, ['Completed']),
                      _buildAppointmentsList(docs, ['Cancelled']),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAppointmentsList(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs,
      List<String> statuses) {
    final filteredDocs = allDocs.where((doc) {
      final status = doc.data()['status'] ?? 'Upcoming';
      return statuses.contains(status);
    }).toList();

    if (filteredDocs.isEmpty) {
      return _buildEmptyState('No appointments in this category.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        final doc = filteredDocs[index];
        final data = doc.data();
        final docId = doc.id;
        final doctorName = data['doctorName'] ?? 'Doctor';
        final specialty = data['specialty'] ?? 'Specialist';
        final date = data['date'] ?? 'N/A';
        final time = data['time'] ?? 'N/A';
        final type = data['type'] ?? 'In-person';
        final status = data['status'] ?? 'Upcoming';
        final hospital = data['hospital'] ?? 'General Clinic';
        final doctorUid = data['doctorId'] ?? '';
        final patientName = data['userName'] ?? 'Patient';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBg(status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusText(status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: _border),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: _textMuted),
                  const SizedBox(width: 8),
                  Text('$date at $time',
                      style: const TextStyle(
                          fontSize: 13,
                          color: _textPrimary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: _textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(hospital,
                        style: const TextStyle(fontSize: 12, color: _textMuted)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _textMuted),
                    ),
                  ),
                ],
              ),
              // Cancel Button for Active/Approved/Upcoming appointments
              if (status != 'Cancelled' && status != 'Completed') ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // 1. Update status to Cancelled
                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .doc(docId)
                          .update({'status': 'Cancelled'});

                      // 2. Notify Doctor
                      if (doctorUid.isNotEmpty) {
                        await FirebaseFirestore.instance.collection('notifications').add({
                          'userId': doctorUid,
                          'type': 'APPOINTMENT_CANCELLED',
                          'title': 'Appointment Cancelled ⚠️',
                          'message': '$patientName has cancelled the appointment scheduled for $date.',
                          'isRead': false,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                      }

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Appointment cancelled successfully.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.redAccent),
                    label: const Text('Cancel Appointment',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 55, color: _textMuted),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: _textMuted, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Approved':
      case 'Completed':
        return const Color(0xFFECFDF5);
      case 'Cancelled':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusText(String status) {
    switch (status) {
      case 'Approved':
      case 'Completed':
        return const Color(0xFF059669);
      case 'Cancelled':
        return Colors.redAccent;
      default:
        return const Color(0xFFD97706);
    }
  }
}