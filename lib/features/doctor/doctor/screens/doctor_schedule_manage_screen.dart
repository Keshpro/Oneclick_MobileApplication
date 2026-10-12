import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorScheduleManageScreen extends StatefulWidget {
  const DoctorScheduleManageScreen({super.key});

  @override
  State<DoctorScheduleManageScreen> createState() =>
      _DoctorScheduleManageScreenState();
}

class _DoctorScheduleManageScreenState
    extends State<DoctorScheduleManageScreen> {
  static const Color _primary = Color(0xff032744);

  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _leaveReasonController = TextEditingController();

  DateTime? _selectedLeaveDate;
  bool _isLoading = false;

  User? get _currentDoctor => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  @override
  void dispose() {
    _feeController.dispose();
    _leaveReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorData() async {
    final uid = _currentDoctor?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('doctors').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      if (mounted) {
        setState(() {
          _feeController.text =
              (doc.data()?['consultationFee'] ?? '2500').toString();
        });
      }
    }
  }

  Future<void> _updateDoctorFee() async {
    final uid = _currentDoctor?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('doctors').doc(uid).update({
        'consultationFee': double.tryParse(_feeController.text.trim()) ?? 0.0,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation fee updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating fee: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markHoliday() async {
    final uid = _currentDoctor?.uid;
    if (uid == null || _selectedLeaveDate == null) return;

    final formattedDate =
        "${_selectedLeaveDate!.year}-${_selectedLeaveDate!.month.toString().padLeft(2, '0')}-${_selectedLeaveDate!.day.toString().padLeft(2, '0')}";

    try {
      setState(() => _isLoading = true);

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(uid)
          .collection('vacations')
          .doc(formattedDate)
          .set({
        'date': formattedDate,
        'reason': _leaveReasonController.text.trim().isEmpty
            ? 'Doctor Unavailable (On Leave)'
            : _leaveReasonController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _leaveReasonController.clear();
      setState(() => _selectedLeaveDate = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Holiday marked and date locked for bookings!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark holiday: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentDoctor?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('No doctor logged in')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Charges & Vacations'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Consultation Fee Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consultation Fee (LKR)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.payments_outlined,
                            color: _primary),
                        hintText: 'Enter fee (e.g. 2500)',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _updateDoctorFee,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Fee Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2. Vacation / Holiday Locking Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mark Vacation / Lock Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedLeaveDate == null
                                  ? 'No Date Picked'
                                  : "${_selectedLeaveDate!.year}-${_selectedLeaveDate!.month.toString().padLeft(2, '0')}-${_selectedLeaveDate!.day.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _selectedLeaveDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_month, color: _primary),
                          label: const Text('Pick Date'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _leaveReasonController,
                      decoration: InputDecoration(
                        hintText: 'Reason (e.g. Personal Leave)',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_selectedLeaveDate == null || _isLoading)
                            ? null
                            : _markHoliday,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Lock Date for Patients',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Locked Holiday Dates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),

            // 3. Holidays List Stream
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(uid)
                  .collection('vacations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Text(
                    'No upcoming holiday dates locked.',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      child: ListTile(
                        leading:
                            const Icon(Icons.lock_clock, color: Colors.red),
                        title: Text(
                          'Date: ${data['date']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Reason: ${data['reason']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.grey),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('doctors')
                                .doc(uid)
                                .collection('vacations')
                                .doc(docs[index].id)
                                .delete();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}