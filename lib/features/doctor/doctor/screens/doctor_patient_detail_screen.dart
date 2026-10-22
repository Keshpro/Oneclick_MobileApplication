import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'write_prescription_screen.dart';

class DoctorPatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const DoctorPatientDetailScreen({
    super.key,
    required this.appointmentData,
  });

  static const Color _primary = Color(0xFF032744);
  static const Color _accent = Color(0xFF4F46E5);
  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _surface = Colors.white;
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final patientName = appointmentData['userName'] ??
        appointmentData['patientName'] ??
        'Patient';
    final patientEmail = appointmentData['userEmail'] ?? '';
    final patientId = appointmentData['userId'] ?? appointmentData['patientId'] ?? '';
    final appointmentId = appointmentData['id'] ?? '';
    final apptDate = appointmentData['date'] ?? 'N/A';
    final apptTime = appointmentData['time'] ?? 'N/A';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Patient Medical Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(
                        patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            patientEmail,
                            style: const TextStyle(fontSize: 12, color: _muted),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Appointment: $apptDate at $apptTime',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Action Button: Write Prescription
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WritePrescriptionScreen(
                          appointmentData: {
                            'id': appointmentId,
                            'patientId': patientId,
                            'patientName': patientName,
                            'userEmail': patientEmail,
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 22),
                  label: const Text(
                    'Write New E-Prescription',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Past Prescriptions History Stream
              const Text(
                'PREVIOUS PRESCRIPTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('prescriptions')
                    .where('patientId', isEqualTo: patientId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: const Center(
                        child: Text(
                          'No prior prescriptions found for this patient.',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((doc) {
                      final rx = doc.data();
                      final diagnosis = rx['diagnosis'] ?? 'No Diagnosis';
                      final date = rx['date'] ?? 'N/A';
                      final medicines = (rx['medicines'] as List?) ?? [];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Diagnosis: $diagnosis',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _text,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: const TextStyle(
                                      fontSize: 11, color: _muted),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Text(
                              'Medicines: ${medicines.map((m) => m['name']).join(', ')}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}