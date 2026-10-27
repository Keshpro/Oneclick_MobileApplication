import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorProfileManageScreen extends StatefulWidget {
  const DoctorProfileManageScreen({super.key});

  @override
  State<DoctorProfileManageScreen> createState() =>
      _DoctorProfileManageScreenState();
}

class _DoctorProfileManageScreenState extends State<DoctorProfileManageScreen> {
  static const Color _primary = Color(0xff032744);
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _hospitalController;
  late TextEditingController _experienceController;

  String? _selectedCategory;
  bool _isSaving = false;

  final List<String> _doctorCategories = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Gynecologist',
    'Dentist',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _hospitalController = TextEditingController();
    _experienceController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hospitalController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  User? get _currentDoctor => FirebaseAuth.instance.currentUser;

  Future<void> _updateProfile(String uid) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('doctors').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'providerDetails.specialization': _selectedCategory,
        'providerDetails.hospital': _hospitalController.text.trim(),
        'providerDetails.experienceYears': _experienceController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Activity Log එකතු කිරීම
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': 'Doctor Profile Updated',
        'details': '${_nameController.text.trim()} updated profile details.',
        'performedBy': _currentDoctor?.email ?? 'Doctor',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _currentDoctor?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Doctor Profile'),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('No logged in doctor found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Manage Doctor Profile'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Failed to load profile details.'),
            );
          }

          final data = snapshot.data!.data() ?? {};
          final providerDetails =
              data['providerDetails'] as Map<String, dynamic>? ?? {};

          // Initial controller values set කිරීම
          if (_nameController.text.isEmpty) {
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _hospitalController.text = providerDetails['hospital'] ?? '';
            _experienceController.text =
                (providerDetails['experienceYears'] ?? '').toString();

            final spec = providerDetails['specialization'] ?? '';
            if (_doctorCategories.contains(spec)) {
              _selectedCategory = spec;
            } else if (_doctorCategories.isNotEmpty) {
              _selectedCategory = _doctorCategories.first;
            }
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Profile Header Card
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 55,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data['name'] ?? 'Doctor Name',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            data['email'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(
                              (data['status'] ?? 'pending').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            backgroundColor: data['status'] == 'active'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Text(
                      'Personal & Professional Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField('Full Name', _nameController, Icons.person),
                    _buildTextField('Phone Number', _phoneController, Icons.phone,
                        keyboardType: TextInputType.phone),

                    // Category Dropdown
                    const Text('Medical Category / Specialization',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.medical_services,
                            color: _primary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _doctorCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                        'Hospital / Clinic', _hospitalController, Icons.local_hospital),
                    _buildTextField('Experience (Years)', _experienceController,
                        Icons.work_history,
                        keyboardType: TextInputType.number),

                    const SizedBox(height: 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isSaving ? null : () => _updateProfile(uid),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          _isSaving ? 'Updating...' : 'Save Profile Changes',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (val) =>
                (val == null || val.trim().isEmpty) ? 'Enter $label' : null,
          ),
        ],
      ),
    );
  }
}