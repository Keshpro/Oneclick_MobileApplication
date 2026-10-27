import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oneclick/features/auth/screens/home_screen.dart';

import '../../../auth/screens/login_screen.dart';
import '../../patient/screens/patient_home_screen.dart';
import 'appointment_requests_screen.dart';
import 'doctor_profile_manage_screen.dart';
import 'doctor_schedule_manage_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  static const Color _primary = Color(0xff032744);

  User? get _currentDoctor => FirebaseAuth.instance.currentUser;

  Future<void> _toggleAvailability(bool value) async {
    final uid = _currentDoctor?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('doctors').doc(uid).update({
        'isAvailable': value,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'You are now Online & Available' : 'You are now Offline',
          ),
          backgroundColor: value ? Colors.green : Colors.grey.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _switchToPatientMode() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // Appointment Reschedule Dialog + Patient Notification Function
  void _showRescheduleDialog(
    String appointmentDocId,
    String patientUid,
    String currentEmail,
  ) {
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'New Date (e.g. 2026-10-20)',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'New Time (e.g. 10:30 AM)',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newDate = dateController.text.trim();
              final newTime = timeController.text.trim();

              if (newDate.isNotEmpty && newTime.isNotEmpty) {
                // 1. Update Appointment in Firestore
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(appointmentDocId)
                    .update({
                      'date': newDate,
                      'time': newTime,
                      'status': 'Rescheduled',
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                // 2. Send Real-time Notification to Patient
                await FirebaseFirestore.instance.collection('notifications').add({
                  'userId': patientUid,
                  'userEmail': currentEmail,
                  'title': 'Appointment Rescheduled 📅',
                  'message':
                      'Your doctor updated your appointment to $newDate at $newTime.',
                  'isRead': false,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Appointment Rescheduled & Patient Notified!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update & Notify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentDoctor?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('No doctor logged in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Charges & Schedule',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorScheduleManageScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit_calendar_rounded),
          ),
          IconButton(
            tooltip: 'Manage Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorProfileManageScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(uid)
            .snapshots(),
        builder: (context, doctorSnapshot) {
          if (doctorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctorData = doctorSnapshot.data?.data() ?? {};
          final doctorName = doctorData['name'] ?? 'Doctor';
          final providerDetails =
              doctorData['providerDetails'] as Map<String, dynamic>? ?? {};
          final specialty =
              providerDetails['specialization'] ?? 'General Physician';
          final isOnline = doctorData['isAvailable'] ?? true;
          final double consultationFee =
              (doctorData['consultationFee'] ?? 2500.0).toDouble();

          return Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                specialty,
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Patient Mode Switch Button
                        InkWell(
                          onTap: _switchToPatientMode,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.swap_horiz_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Customer Mode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Availability Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 5,
                                backgroundColor: isOnline
                                    ? Colors.greenAccent
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isOnline
                                    ? 'Online for Consultations'
                                    : 'Offline',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isOnline,
                            activeThumbColor: Colors.greenAccent,
                            onChanged: _toggleAvailability,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // KPI & Revenue Analytics Section
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('doctorId', isEqualTo: uid)
                    .snapshots(),
                builder: (context, apptSnapshot) {
                  final docs = apptSnapshot.data?.docs ?? [];
                  final totalBookings = docs.length;
                  final approvedDocs = docs
                      .where((d) => (d.data()['status'] ?? '') == 'Approved')
                      .length;
                  final totalRevenue = approvedDocs * consultationFee;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Est. Revenue',
                            value: 'LKR ${totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.account_balance_wallet_rounded,
                            color: const Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Approved',
                            value: '$approvedDocs / $totalBookings',
                            icon: Icons.check_circle_rounded,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Quick Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickNavCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Requests',
                        subtitle: 'View All',
                        color: const Color(0xFF0284C7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AppointmentRequestsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickNavCard(
                        icon: Icons.edit_calendar_rounded,
                        title: 'Schedule',
                        subtitle: 'Fee & Holidays',
                        color: const Color(0xFFD97706),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const DoctorScheduleManageScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Patient Appointments List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Patient Appointments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppointmentRequestsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Appointments Stream
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('doctorId', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, apptSnapshot) {
                    if (apptSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final apptDocs = apptSnapshot.data?.docs ?? [];

                    if (apptDocs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 45,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No appointments assigned yet.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      itemCount: apptDocs.length,
                      itemBuilder: (context, index) {
                        final doc = apptDocs[index];
                        final appt = doc.data();
                        final patientEmail = appt['userEmail'] ?? 'Patient';
                        final patientUid = appt['userId'] ?? '';
                        final date = appt['date'] ?? 'N/A';
                        final time = appt['time'] ?? 'N/A';
                        final type = appt['type'] ?? 'In-person';
                        final status = appt['status'] ?? 'Upcoming';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      patientEmail,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusBgColor(status),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: _getStatusTextColor(status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Date: $date at $time • $type',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Reschedule',
                                      icon: const Icon(
                                        Icons.edit_calendar,
                                        size: 18,
                                        color: _primary,
                                      ),
                                      onPressed: () => _showRescheduleDialog(
                                        doc.id,
                                        patientUid,
                                        patientEmail,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green.withValues(alpha: 0.1);
      case 'Rescheduled':
        return Colors.purple.withValues(alpha: 0.1);
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
      case 'Rescheduled':
        return Colors.purple;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
