
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkerEditProfileScreen extends StatefulWidget {
  const WorkerEditProfileScreen({super.key});

  @override
  State<WorkerEditProfileScreen> createState() =>
      _WorkerEditProfileScreenState();
}

class _WorkerEditProfileScreenState
    extends State<WorkerEditProfileScreen> {
  static const Color primaryNavy = Color(0xFF1E293B);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isSaving = false;

  String _category = '';

  @override
  void initState() {
    super.initState();
    _loadWorkerProfile();
  }

  Future<void> _loadWorkerProfile() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('Worker not logged in');
      }

      final doc = await _firestore
          .collection('workers')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception('Worker profile not found');
      }

      final data = doc.data()!;

      final providerDetails =
          Map<String, dynamic>.from(
        data['providerDetails'] is Map
            ? data['providerDetails'] as Map
            : {},
      );

      if (!mounted) return;

      setState(() {
        _nameController.text =
            data['name']?.toString() ?? '';

        _phoneController.text =
            data['phone']?.toString() ?? '';

        _areaController.text =
            data['area']?.toString() ?? '';

        _category =
            data['category']?.toString() ?? '';

        _experienceController.text =
            (providerDetails['experienceYears'] ??
                    data['experience'] ??
                    '')
                .toString();

        _hourlyRateController.text =
            (providerDetails['hourlyRate'] ??
                    data['hourlyRate'] ??
                    '')
                .toString();

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final experience = int.parse(
        _experienceController.text.trim(),
      );

      final hourlyRate = double.parse(
        _hourlyRateController.text.trim(),
      );

      await _firestore
          .collection('workers')
          .doc(user.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'area': _areaController.text.trim(),
        'providerDetails.experienceYears':
            experience.toString(),
        'providerDetails.hourlyRate': hourlyRate,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryNavy),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryNavy,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label, icon),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Edit Worker Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: primaryNavy,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'My Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildField(
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                    ),

                    _buildField(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    _buildField(
                      label: 'Service Area',
                      icon: Icons.location_on_outlined,
                      controller: _areaController,
                    ),

                    _buildField(
                      label: 'Experience (Years)',
                      icon: Icons.work_outline,
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final years =
                            int.tryParse(value?.trim() ?? '');

                        if (years == null || years < 0) {
                          return 'Enter valid experience';
                        }

                        return null;
                      },
                    ),

                    _buildField(
                      label: 'Hourly Rate (LKR)',
                      icon: Icons.payments_outlined,
                      controller: _hourlyRateController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final rate = double.tryParse(
                          value?.trim() ?? '',
                        );

                        if (rate == null ||
                            !rate.isFinite ||
                            rate <= 0) {
                          return 'Enter a valid hourly rate';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed:
                            _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving
                              ? 'Saving...'
                              : 'Save Changes',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryNavy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
