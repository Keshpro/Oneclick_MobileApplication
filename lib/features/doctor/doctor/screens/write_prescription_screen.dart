import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WritePrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic>? appointmentData;

  const WritePrescriptionScreen({super.key, this.appointmentData});

  @override
  State<WritePrescriptionScreen> createState() =>
      _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  static const Color _primary = Color(0xFF4F46E5);
  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  bool _isSaving = false;
  final List<Map<String, String>> _medicines = [];

  final TextEditingController _medNameController = TextEditingController();
  final TextEditingController _medDosageController = TextEditingController();
  String _selectedFrequency = 'Once daily (After meal)';
  final TextEditingController _medDurationController = TextEditingController();

  final List<String> _frequencyOptions = [
    'Once daily (Morning)',
    'Once daily (Night)',
    'Once daily (After meal)',
    'Twice daily (1-0-1)',
    'Three times daily (1-1-1)',
    'Every 8 hours',
    'As needed (PRN)',
  ];

  User? get _currentDoctor => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.appointmentData != null) {
      _patientNameController.text =
          widget.appointmentData!['patientName'] ??
          widget.appointmentData!['userName'] ??
          '';
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _diagnosisController.dispose();
    _instructionsController.dispose();
    _medNameController.dispose();
    _medDosageController.dispose();
    _medDurationController.dispose();
    super.dispose();
  }

  void _addMedicineToList() {
    if (_medNameController.text.trim().isEmpty ||
        _medDosageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name and dosage.')),
      );
      return;
    }

    setState(() {
      _medicines.add({
        'name': _medNameController.text.trim(),
        'dosage': _medDosageController.text.trim(),
        'frequency': _selectedFrequency,
        'duration': _medDurationController.text.trim().isEmpty
            ? '5 Days'
            : _medDurationController.text.trim(),
      });

      _medNameController.clear();
      _medDosageController.clear();
      _medDurationController.clear();
    });
  }

  void _removeMedicine(int index) {
    setState(() => _medicines.removeAt(index));
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;

    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine.')),
      );
      return;
    }

    final doctorUid = _currentDoctor?.uid ?? '';
    final patientUid = widget.appointmentData?['patientId'] ??
        widget.appointmentData?['userId'] ??
        '';
    final appointmentId = widget.appointmentData?['id'] ?? '';

    setState(() => _isSaving = true);

    try {
      String doctorName = 'Dr. Specialist';
      if (doctorUid.isNotEmpty) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(doctorUid)
            .get();
        if (docSnapshot.exists) {
          doctorName = docSnapshot.data()?['name'] ?? 'Dr. Specialist';
        }
      }

      final prescriptionData = {
        'patientName': _patientNameController.text.trim(),
        'patientId': patientUid,
        'doctorId': doctorUid,
        'doctorName': doctorName,
        'appointmentId': appointmentId,
        'diagnosis': _diagnosisController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'medicines': _medicines,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().toString().split(' ')[0],
      };

      // 1. Save Prescription to Firestore
      await FirebaseFirestore.instance
          .collection('prescriptions')
          .add(prescriptionData);

      // 2. Mark Appointment Completed
      if (appointmentId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .update({
          'status': 'Completed',
          'hasPrescription': true,
        });
      }

      // 3. Send Notification to Patient
      if (patientUid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': patientUid,
          'title': 'New E-Prescription Issued 💊',
          'message': '$doctorName has issued a new prescription for your consultation.',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription issued & linked successfully!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send prescription: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _ink,
        title: const Text('Write E-Prescription', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  title: 'PATIENT & DIAGNOSIS',
                  icon: Icons.person_outlined,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _patientNameController,
                        readOnly: widget.appointmentData != null,
                        decoration: _inputDecoration('Patient Full Name'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: _inputDecoration('Diagnosis / Health Issue', hint: 'e.g. Fever & Viral Infection'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter diagnosis' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: 'ADD MEDICINES',
                  icon: Icons.medication_outlined,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _medNameController,
                              decoration: _inputDecoration('Medicine Name', hint: 'Paracetamol'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _medDosageController,
                              decoration: _inputDecoration('Dosage', hint: '500mg'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        decoration: _inputDecoration('Frequency'),
                        items: _frequencyOptions
                            .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFrequency = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _medDurationController,
                              decoration: _inputDecoration('Duration', hint: '5 Days'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _addMedicineToList,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_medicines.isNotEmpty) ...[
                  const Text('PRESCRIBED ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  ...List.generate(_medicines.length, (index) {
                    final med = _medicines[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.medication_outlined, color: _primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${med['name']} (${med['dosage']})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _ink)),
                                Text('${med['frequency']} • ${med['duration']}', style: const TextStyle(fontSize: 11, color: _muted)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                            onPressed: () => _removeMedicine(index),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
                _buildSectionCard(
                  title: 'SPECIAL INSTRUCTIONS',
                  icon: Icons.notes_outlined,
                  child: TextFormField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: _inputDecoration('Instructions for patient', hint: 'e.g. Rest well and take medications after meals.'),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _savePrescription,
                    icon: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                    label: Text(_isSaving ? 'Sending...' : 'Send E-Prescription', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: _border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 13, color: _muted),
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _primary, width: 1.5)),
    );
  }
}