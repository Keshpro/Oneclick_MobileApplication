import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oneclick/features/auth/screens/home_screen.dart';

import '../../../auth/screens/login_screen.dart';
import 'appointment_requests_screen.dart';
import 'doctor_patient_detail_screen.dart';
import 'doctor_profile_manage_screen.dart';
import 'doctor_schedule_manage_screen.dart';
import 'write_prescription_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  // HCI Color Palette: 60-30-10 Rule
  static const Color _primary = Color(0xff032744);
  static const Color _bg = Color(0xFFF4F6FB);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _emerald = Color(0xFF059669);
  static const Color _indigo = Color(0xFF4F46E5);

  User? get _currentDoctor => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _listenForDoctorNotifications();
  }

  // Real-time Listener for Doctor Pop-Up Alerts (New & Cancelled Bookings)
  void _listenForDoctorNotifications() {
    final uid = _currentDoctor?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] ?? '';
        final title = data['title'] ?? 'Notification';
        final message = data['message'] ?? '';

        // Mark as read immediately after pop-up display
        doc.reference.update({'isRead': true});

        if (!mounted) return;

        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  type == 'APPOINTMENT_CANCELLED'
                      ? Icons.cancel_outlined
                      : Icons.event_available_rounded,
                  color: type == 'APPOINTMENT_CANCELLED'
                      ? Colors.redAccent
                      : _emerald,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: const TextStyle(fontSize: 13, color: _textMuted),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == 'APPOINTMENT_CANCELLED'
                      ? Colors.redAccent
                      : _primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    });
  }

  // View All Notifications Modal Bottom Sheet
  void _showNotificationHistorySheet(String doctorUid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.50,
          maxChildSize: 0.90,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'System Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final batch = FirebaseFirestore.instance.batch();
                          final docs = await FirebaseFirestore.instance
                              .collection('notifications')
                              .where('userId', isEqualTo: doctorUid)
                              .get();
                          for (var d in docs.docs) {
                            batch.update(d.reference, {'isRead': true});
                          }
                          await batch.commit();
                        },
                        child: const Text(
                          'Mark All Read',
                          style: TextStyle(color: _emerald, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: _border),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('userId', isEqualTo: doctorUid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final notifDocs = snapshot.data?.docs ?? [];

                        if (notifDocs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No notifications found.',
                              style: TextStyle(color: _textMuted),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: notifDocs.length,
                          itemBuilder: (context, index) {
                            final doc = notifDocs[index];
                            final data = doc.data();
                            final title = data['title'] ?? 'Notification';
                            final message = data['message'] ?? '';
                            final isRead = data['isRead'] ?? false;
                            final type = data['type'] ?? '';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isRead ? _bg : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isRead ? _border : const Color(0xFFA7F3D0),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: type == 'APPOINTMENT_CANCELLED'
                                      ? Colors.redAccent.withOpacity(0.1)
                                      : _emerald.withOpacity(0.1),
                                  child: Icon(
                                    type == 'APPOINTMENT_CANCELLED'
                                        ? Icons.cancel_outlined
                                        : Icons.notifications_active_outlined,
                                    color: type == 'APPOINTMENT_CANCELLED'
                                        ? Colors.redAccent
                                        : _emerald,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  message,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _textMuted,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                  onPressed: () => doc.reference.delete(),
                                ),
                                onTap: () {
                                  if (!isRead) {
                                    doc.reference.update({'isRead': true});
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleAvailability(bool value, String doctorName) async {
    final uid = _currentDoctor?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('doctors').doc(uid).update({
        'isAvailable': value,
      });

      if (value) {
        final apptSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: uid)
            .get();

        final Set<String> notifiedPatients = {};

        for (var doc in apptSnapshot.docs) {
          final patientId = doc.data()['userId'] ?? doc.data()['patientId'];
          if (patientId != null && !notifiedPatients.contains(patientId)) {
            notifiedPatients.add(patientId);

            await FirebaseFirestore.instance.collection('notifications').add({
              'userId': patientId,
              'doctorId': uid,
              'doctorName': doctorName,
              'type': 'DOCTOR_ONLINE_POPUP',
              'title': '$doctorName is Now Online! 🟢',
              'message':
                  'The doctor you booked is currently online for consultation.',
              'isRead': false,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Status: Online for Patients' : 'Status: Offline',
          ),
          backgroundColor: value ? _emerald : _textMuted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
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

  void _openWritePrescription({Map<String, dynamic>? appointmentData}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WritePrescriptionScreen(
          appointmentData: appointmentData,
        ),
      ),
    );
  }

  void _showRescheduleDialog(String appointmentDocId, String patientUid, String currentEmail) {
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reschedule Booking', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'New Date (e.g. 2026-10-20)',
                prefixIcon: const Icon(Icons.calendar_today_rounded, color: _indigo),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'New Time (e.g. 10:30 AM)',
                prefixIcon: const Icon(Icons.access_time_rounded, color: _indigo),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newDate = dateController.text.trim();
              final newTime = timeController.text.trim();

              if (newDate.isNotEmpty && newTime.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(appointmentDocId)
                    .update({
                  'date': newDate,
                  'time': newTime,
                  'status': 'Rescheduled',
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                await FirebaseFirestore.instance.collection('notifications').add({
                  'userId': patientUid,
                  'userEmail': currentEmail,
                  'title': 'Appointment Rescheduled 📅',
                  'message': 'Your doctor updated your appointment to $newDate at $newTime.',
                  'isRead': false,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment Rescheduled & Patient Notified!'),
                    backgroundColor: _emerald,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Update & Notify', style: TextStyle(color: Colors.white)),
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
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Doctor Dashboard', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // AppBar Notifications Icon with Real-Time Unread Badge
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('userId', isEqualTo: uid)
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, notifSnapshot) {
              final unreadCount = notifSnapshot.data?.docs.length ?? 0;
              final hasUnread = unreadCount > 0;

              return Stack(
                children: [
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => _showNotificationHistorySheet(uid),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            tooltip: 'Charges & Schedule',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorScheduleManageScreen()),
            ),
            icon: const Icon(Icons.edit_calendar_rounded),
          ),
          IconButton(
            tooltip: 'Manage Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorProfileManageScreen()),
            ),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('doctors').doc(uid).snapshots(),
        builder: (context, doctorSnapshot) {
          if (doctorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctorData = doctorSnapshot.data?.data() ?? {};
          final doctorName = doctorData['name'] ?? 'Dr. Specialist';
          final providerDetails = doctorData['providerDetails'] as Map<String, dynamic>? ?? {};
          final specialty = providerDetails['specialization'] ?? 'General Practitioner';
          final isOnline = doctorData['isAvailable'] ?? true;
          final double consultationFee = (doctorData['consultationFee'] ?? 2500.0).toDouble();

          return Column(
            children: [
              // Header Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctorName,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                specialty,
                                style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _switchToPatientMode,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text('Patient Mode', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Availability Switch Status Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isOnline ? const Color(0xFF34D399) : Colors.transparent),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: isOnline ? const Color(0xFF34D399) : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isOnline ? 'Online for Patients' : 'Offline / On Break',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Switch(
                            value: isOnline,
                            activeColor: const Color(0xFF34D399),
                            onChanged: (val) => _toggleAvailability(val, doctorName),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // KPI Section
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: uid).snapshots(),
                builder: (context, apptSnapshot) {
                  final docs = apptSnapshot.data?.docs ?? [];
                  final totalBookings = docs.length;
                  final approvedDocs = docs.where((d) => (d.data()['status'] ?? '') == 'Approved').length;
                  final totalRevenue = approvedDocs * consultationFee;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Est. Revenue',
                            value: 'LKR ${totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.account_balance_wallet_outlined,
                            color: _emerald,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'Approved',
                            value: '$approvedDocs / $totalBookings',
                            icon: Icons.verified_user_outlined,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),

              // Quick Actions Nav Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickNavCard(
                        icon: Icons.calendar_month_rounded,
                        title: 'Requests',
                        subtitle: 'Review All',
                        color: const Color(0xFF0284C7),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentRequestsScreen())),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickNavCard(
                        icon: Icons.edit_note_rounded,
                        title: 'Prescribe',
                        subtitle: 'Write E-Script',
                        color: _indigo,
                        onTap: () => _openWritePrescription(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickNavCard(
                        icon: Icons.edit_calendar_rounded,
                        title: 'Schedule',
                        subtitle: 'Slots & Fees',
                        color: const Color(0xFFD97706),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorScheduleManageScreen())),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Consultations Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Patient Consultations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentRequestsScreen())),
                      child: const Text('See All', style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Patient Appointment Stream List
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: uid).snapshots(),
                  builder: (context, apptSnapshot) {
                    if (apptSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final apptDocs = apptSnapshot.data?.docs ?? [];

                    if (apptDocs.isEmpty) {
                      return const Center(
                        child: Text('No patient bookings assigned yet.', style: TextStyle(color: _textMuted, fontSize: 13)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: apptDocs.length,
                      itemBuilder: (context, index) {
                        final doc = apptDocs[index];
                        final appt = doc.data();
                        final patientEmail = appt['userEmail'] ?? 'Patient';
                        final patientName = appt['userName'] ?? patientEmail.split('@').first;
                        final patientUid = appt['userId'] ?? '';
                        final date = appt['date'] ?? 'N/A';
                        final time = appt['time'] ?? 'N/A';
                        final type = appt['type'] ?? 'In-person';
                        final status = appt['status'] ?? 'Upcoming';

                        final appointmentData = {
                          'id': doc.id,
                          'userId': patientUid,
                          'patientId': patientUid,
                          'patientName': patientName,
                          'userName': patientName,
                          'userEmail': patientEmail,
                          'date': date,
                          'time': time,
                        };

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _border),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorPatientDetailScreen(appointmentData: appointmentData),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: _indigo.withValues(alpha: 0.1),
                                    child: Text(
                                      patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                                      style: const TextStyle(color: _indigo, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _textPrimary)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getStatusBgColor(status),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(color: _getStatusTextColor(status), fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text('$date at $time • $type', style: const TextStyle(fontSize: 11, color: _textMuted)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Write Prescription',
                                    icon: const Icon(Icons.description_outlined, color: _indigo, size: 20),
                                    onPressed: () => _openWritePrescription(appointmentData: appointmentData),
                                  ),
                                  IconButton(
                                    tooltip: 'Reschedule',
                                    icon: const Icon(Icons.edit_calendar_rounded, color: _primary, size: 20),
                                    onPressed: () => _showRescheduleDialog(doc.id, patientUid, patientEmail),
                                  ),
                                ],
                              ),
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

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10, color: _textMuted, fontWeight: FontWeight.w600)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _textPrimary)),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: _textMuted)),
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