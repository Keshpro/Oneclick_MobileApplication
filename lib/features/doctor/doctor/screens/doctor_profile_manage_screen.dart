import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoctorProfileManageScreen extends StatefulWidget {
  const DoctorProfileManageScreen({super.key});

  @override
  State<DoctorProfileManageScreen> createState() =>
      _DoctorProfileManageScreenState();
}

class _DoctorProfileManageScreenState extends State<DoctorProfileManageScreen> {
  static const Color _green = Color(0xFF059669);
  static const Color _darkGreen = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _blue = Color(0xFF0284C7);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _orange = Color(0xFFD97706);
  static const Color _red = Color(0xFFDC2626);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _experienceController = TextEditingController();

  final List<String> _doctorCategories = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Gynecologist',
    'Dentist',
  ];

  String? _selectedCategory;
  bool _isSaving = false;
  bool _initialized = false;
  bool _hasChanges = false;

  User? get _doctor => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    for (final controller in [
      _nameController,
      _phoneController,
      _hospitalController,
      _experienceController,
    ]) {
      controller.addListener(_markChanged);
    }
  }

  void _markChanged() {
    if (_initialized && !_hasChanges && mounted) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _hospitalController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _initializeFields(Map<String, dynamic> data) {
    if (_initialized) return;

    final provider = data['providerDetails'] is Map
        ? Map<String, dynamic>.from(data['providerDetails'] as Map)
        : <String, dynamic>{};

    _nameController.text = (data['name'] ?? '').toString();

    _phoneController.text = (data['phone'] ?? '').toString();

    _hospitalController.text = (provider['hospital'] ?? '').toString();

    _experienceController.text = (provider['experienceYears'] ?? '').toString();

    final specialization = (provider['specialization'] ?? '').toString();

    if (specialization.isNotEmpty &&
        !_doctorCategories.contains(specialization)) {
      _doctorCategories.add(specialization);
    }

    _selectedCategory = specialization.isNotEmpty
        ? specialization
        : _doctorCategories.first;

    _initialized = true;
    _hasChanges = false;
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? _red : _darkGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveProfile(String uid) async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: _green),
            SizedBox(width: 10),
            Expanded(child: Text('Save Profile Changes?')),
          ],
        ),
        content: const Text(
          'Your updated personal and professional '
          'details will be saved to your doctor profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final doctorRef = firestore.collection('doctors').doc(uid);

      batch.update(doctorRef, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'providerDetails.specialization': _selectedCategory,
        'providerDetails.hospital': _hospitalController.text.trim(),
        'providerDetails.experienceYears': _experienceController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final logRef = firestore.collection('activity_logs').doc();

      batch.set(logRef, {
        'action': 'Doctor Profile Updated',
        'details': '${_nameController.text.trim()} updated profile details.',
        'performedBy': _doctor?.email ?? 'Doctor',
        'doctorId': uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;

      setState(() => _hasChanges = false);

      _message('Profile updated successfully!');
    } catch (e) {
      _message('Failed to update profile: $e', error: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_hasChanges) return true;

    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved profile changes. '
          'Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return leave == true;
  }

  @override
  Widget build(BuildContext context) {
    final uid = _doctor?.uid;

    return PopScope(
      canPop: !_hasChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _isSaving) return;

        final leave = await _confirmLeave();

        if (leave && mounted) {
          setState(() => _hasChanges = false);

          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: _text,
          elevation: 0,
          toolbarHeight: 68,
          titleSpacing: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              Text(
                'Doctor workspace',
                style: TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.manage_accounts_rounded,
                color: _green,
                size: 24,
              ),
            ),
          ],
        ),
        body: uid == null
            ? _emptyState(
                'Doctor account required',
                'Please sign in to manage your profile.',
              )
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _emptyState(
                      'Unable to load profile',
                      'Check your connection and permissions.',
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: _green),
                    );
                  }

                  if (!snapshot.data!.exists) {
                    return _emptyState(
                      'Profile not found',
                      'Your doctor profile is unavailable.',
                    );
                  }

                  final data = snapshot.data!.data() ?? <String, dynamic>{};

                  _initializeFields(data);

                  final provider = data['providerDetails'] is Map
                      ? Map<String, dynamic>.from(
                          data['providerDetails'] as Map,
                        )
                      : <String, dynamic>{};

                  final name = (data['name'] ?? 'Doctor').toString();

                  final email = (data['email'] ?? _doctor?.email ?? '')
                      .toString();

                  final status = (data['status'] ?? 'pending').toString();

                  final specialization =
                      (provider['specialization'] ?? 'General Physician')
                          .toString();

                  return SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 35),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _profileHeader(name, email, status, specialization),
                            const SizedBox(height: 25),
                            _sectionTitle(
                              'Personal Information',
                              'Keep your contact details updated',
                            ),
                            const SizedBox(height: 13),
                            _personalCard(),
                            const SizedBox(height: 25),
                            _sectionTitle(
                              'Professional Information',
                              'Your medical practice details',
                            ),
                            const SizedBox(height: 13),
                            _professionalCard(),
                            const SizedBox(height: 24),
                            _accountInfoCard(email, status),
                            const SizedBox(height: 24),
                            _saveButton(uid),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _profileHeader(
    String name,
    String email,
    String status,
    String specialization,
  ) {
    final active = status.toLowerCase() == 'active';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkGreen, _green],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            width: 83,
            height: 83,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            specialization,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                  color: active
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFDE68A),
                  size: 18,
                ),
                const SizedBox(width: 7),
                Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _personalCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _textField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person_rounded,
            color: _green,
            hint: 'Enter your full name',
            maxLength: 100,
          ),
          const SizedBox(height: 15),
          _textField(
            label: 'Phone Number',
            controller: _phoneController,
            icon: Icons.phone_rounded,
            color: _blue,
            hint: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            maxLength: 20,
          ),
        ],
      ),
    );
  }

  Widget _professionalCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Medical Category / Specialization'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            isExpanded: true,
            decoration: _inputDecoration(
              Icons.medical_services_rounded,
              _purple,
            ),
            items: _doctorCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _isSaving
                ? null
                : (value) {
                    setState(() {
                      _selectedCategory = value;
                      _hasChanges = true;
                    });
                  },
            validator: (value) => value == null || value.isEmpty
                ? 'Please select a specialization'
                : null,
          ),
          const SizedBox(height: 18),
          _textField(
            label: 'Hospital / Clinic',
            controller: _hospitalController,
            icon: Icons.local_hospital_rounded,
            color: _blue,
            hint: 'Enter hospital or clinic name',
            maxLength: 150,
          ),
          const SizedBox(height: 15),
          _textField(
            label: 'Experience (Years)',
            controller: _experienceController,
            icon: Icons.work_history_rounded,
            color: _orange,
            hint: 'e.g. 5',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 2,
            validator: (value) {
              final years = int.tryParse(value?.trim() ?? '');

              if (years == null || years < 0 || years > 70) {
                return 'Enter valid experience (0–70 years)';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _accountInfoCard(String email, String status) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.security_rounded, _purple),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Account Information',
                  style: TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _infoRow(Icons.email_outlined, 'Email Address', email),
          const Divider(height: 24, color: _border),
          _infoRow(
            Icons.verified_user_outlined,
            'Account Status',
            status.toUpperCase(),
          ),
          const SizedBox(height: 12),
          const Text(
            'Email address and account approval status '
            'are managed separately and cannot be edited here.',
            style: TextStyle(color: _muted, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _saveButton(String uid) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isSaving || !_hasChanges
                ? null
                : () => _saveProfile(uid),
            icon: _isSaving
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              _isSaving ? 'Saving Changes...' : 'Save Profile Changes',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _green.withValues(alpha: 0.45),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        if (_hasChanges) ...[
          const SizedBox(height: 11),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, color: _orange, size: 15),
              SizedBox(width: 6),
              Text(
                'You have unsaved changes',
                style: TextStyle(
                  color: _orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          enabled: !_isSaving,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: _inputDecoration(
            icon,
            color,
          ).copyWith(hintText: hint, counterText: ''),
          validator:
              validator ??
              (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(IconData icon, Color color) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _text,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _blue, size: 20),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_rounded, color: _orange, size: 40),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
