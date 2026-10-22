import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientPrescriptionsScreen extends StatefulWidget {
  const PatientPrescriptionsScreen({super.key});

  @override
  State<PatientPrescriptionsScreen> createState() =>
      _PatientPrescriptionsScreenState();
}

class _PatientPrescriptionsScreenState
    extends State<PatientPrescriptionsScreen> {
  static const Color bg = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color purple = Color(0xFF4F46E5);
  static const Color purple2 = Color(0xFF9333EA);

  String selectedFilter = 'All';
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final uid = _currentUser?.uid;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        title: const Text(
          'My Prescriptions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
      ),
      body: SafeArea(
        child: uid == null
            ? const Center(child: Text('Please login to view prescriptions.'))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildFilterChips(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('prescriptions')
                          .where('patientId', isEqualTo: uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data?.docs ?? [];

                        final filteredList = docs.where((doc) {
                          final data = doc.data();
                          final status = data['status'] ?? 'Active';
                          if (selectedFilter == 'Active') {
                            return status == 'Active';
                          }
                          if (selectedFilter == 'Completed') {
                            return status != 'Active';
                          }
                          return true;
                        }).toList();

                        if (filteredList.isEmpty) {
                          return const Center(
                            child: Text(
                              'No prescriptions found.',
                              style: TextStyle(color: muted),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final rxData = filteredList[index].data();
                            return _buildPrescriptionCard(rxData);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: ['All', 'Active', 'Completed'].map((filter) {
        final isSelected = selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(filter),
            selected: isSelected,
            selectedColor: const Color(0xFFE0E7FE),
            labelStyle: TextStyle(
              color: isSelected ? purple : muted,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> rx) {
    final status = rx['status'] ?? 'Active';
    final isActive = status == 'Active';
    final doctorName = rx['doctorName'] ?? 'Doctor';
    final date = rx['date'] ?? 'N/A';
    final diagnosis = rx['diagnosis'] ?? 'General Consultation';
    final medicines = (rx['medicines'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFF0F3FF)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: isActive ? purple : muted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Past',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF166534)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    size: 16, color: purple2),
                const SizedBox(width: 6),
                const Text(
                  'Diagnosis: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: muted,
                  ),
                ),
                Expanded(
                  child: Text(
                    diagnosis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'MEDICINES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: muted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            ...medicines.map((med) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEFF2F7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.medication_outlined,
                          size: 20, color: purple),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${med['name'] ?? ''} (${med['dosage'] ?? ''})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: ink,
                              ),
                            ),
                            Text(
                              '${med['frequency'] ?? ''} • ${med['duration'] ?? ''}',
                              style:
                                  const TextStyle(fontSize: 11, color: muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}