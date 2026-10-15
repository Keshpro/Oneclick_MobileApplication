import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkerRegistrationScreen extends StatefulWidget {
  const WorkerRegistrationScreen({super.key});

  @override
  State<WorkerRegistrationScreen> createState() =>
      _WorkerRegistrationScreenState();
}

class _WorkerRegistrationScreenState extends State<WorkerRegistrationScreen> {
  static const Color _primary = Color(0xFF1E293B);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _experienceController = TextEditingController();

  String _selectedCategory = 'Electrician';
  bool _isLoading = false;

  final List<String> _categories = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Cleaning',
    'AC Repair',
    'Appliances',
    'Gardening',
    'Locksmith',
    'Masonry',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _submitWorkerRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to register as a worker.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save Worker Data in 'technicians' collection
      await FirebaseFirestore.instance.collection('technicians').doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': user.email ?? 'N/A',
        'phone': _phoneController.text.trim(),
        'category': _selectedCategory,
        'hourlyRate': _hourlyRateController.text.trim(),
        'experience': _experienceController.text.trim(),
        'rating': '5.0',
        'status': 'pending', // Pending Admin approval
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted! Pending admin approval.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Become a OneClick Worker'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join as a Skilled Technician',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Provide your details to register as a service provider on OneClick and earn extra income.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 14),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 14),

              // Service Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration('Select Service Category', Icons.work_outline),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Hourly Rate
              TextFormField(
                controller: _hourlyRateController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Expected Hourly Rate (LKR)', Icons.payments_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Enter hourly rate' : null,
              ),
              const SizedBox(height: 14),

              // Experience
              TextFormField(
                controller: _experienceController,
                decoration: _inputDecoration('Experience (e.g., 3+ Years)', Icons.history_edu_outlined),
                validator: (v) => v == null || v.isEmpty ? 'Enter experience' : null,
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitWorkerRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Worker Application',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _primary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}