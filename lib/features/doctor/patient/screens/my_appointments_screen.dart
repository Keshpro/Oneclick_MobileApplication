import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  static const Color _primary = Color(0xFF059669);
  static const Color _primaryDark = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  String _selectedTab = 'Upcoming';
  final List<String> _tabs = ['Upcoming', 'Completed', 'Cancelled'];

  Color _statusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return _primary;
      case 'Completed':
        return const Color(0xFF2563EB);
      case 'Cancelled':
        return const Color(0xFFDC2626);
      default:
        return _muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFFECFDF5);
      case 'Completed':
        return const Color(0xFFEFF6FF);
      case 'Cancelled':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Future<void> _cancelAppointmentInFirestore(Map<String, dynamic> appointment) async {
    final docId = appointment['docId'];
    if (docId == null) return;

    try {
      await FirebaseFirestore.instance.collection('appointments').doc(docId).update({
        'status': 'Cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': 'Appointment Cancelled',
        'details': 'Appointment #${appointment['id']} was cancelled.',
        'performedBy': FirebaseAuth.instance.currentUser?.email ?? 'Patient',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment cancelled successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel appointment: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showCancelConfirmation(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Cancel appointment?', style: TextStyle(color: _text, fontSize: 19, fontWeight: FontWeight.w800)),
          content: Text('Are you sure you want to cancel your appointment with ${appointment['doctorName'] ?? 'the doctor'}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep Appointment', style: TextStyle(color: _muted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _cancelAppointmentInFirestore(appointment);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text('My Appointments', style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _primaryDark, borderRadius: BorderRadius.circular(24)),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your appointments', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                        SizedBox(height: 6),
                        Text('View and manage your healthcare appointments.', style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.calendar_month_rounded, color: Color(0xFF6EE7B7), size: 38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 43,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final selected = _selectedTab == tab;

                return InkWell(
                  onTap: () => setState(() => _selectedTab = tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: selected ? _primary : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(tab, style: TextStyle(color: selected ? Colors.white : _muted, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 17),
          Expanded(
            child: currentUser == null
                ? const Center(child: Text('Please log in to view appointments'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('userId', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      final filtered = docs
                          .map((d) => d.data()..['docId'] = d.id)
                          .where((a) => a['status'] == _selectedTab)
                          .toList();

                      if (filtered.isEmpty) {
                        return Center(child: Text('No $_selectedTab appointments', style: const TextStyle(fontSize: 16, color: _muted)));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final appointment = filtered[index];
                          final status = appointment['status'] ?? 'Upcoming';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(appointment['doctorName'] ?? 'Doctor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: _statusBackground(status), borderRadius: BorderRadius.circular(12)),
                                        child: Text(status, style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${appointment['specialty']} • ${appointment['hospital']}', style: const TextStyle(color: _muted, fontSize: 12)),
                                  const Divider(height: 20),
                                  Text('Date: ${appointment['date']} (${appointment['day']})', style: const TextStyle(fontSize: 13)),
                                  Text('Time: ${appointment['time']}', style: const TextStyle(fontSize: 13)),
                                  if (status == 'Upcoming') ...[
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: OutlinedButton(
                                        onPressed: () => _showCancelConfirmation(appointment),
                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Cancel Appointment'),
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
          ),
        ],
      ),
    );
  }
}