import 'package:flutter/material.dart';
import '../../models/driver_application_model.dart';
import '../../services/driver_firestore_service.dart';
import '../../theme/drunk_drive_colors.dart';
class DriverApplicationScreen extends StatefulWidget {
  const DriverApplicationScreen({super.key});
  @override
  State<DriverApplicationScreen> createState() =>
      _DriverApplicationScreenState();
}
class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final DriverFirestoreService _driverService = DriverFirestoreService();

  DrunkDrivePalette get _palette => DrunkDrivePalette.of(context);
  final _formKey = GlobalKey<FormState>();
  DriverApplicationModel? _application;
  bool _isLoading = true;
  // Form controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenceNoController = TextEditingController();
  final _licenceTypeController = TextEditingController(
    text: 'Heavy Vehicle / Light Car',
  );
  final _licenceExpiryController = TextEditingController();
  final _expYearsController = TextEditingController(text: '3');
  final _docNumberController = TextEditingController();
  bool _canManual = true;
  bool _canAutomatic = true;
  String _selectedDocType = 'National Identity Card (NIC)';
  @override
  void initState() {
    super.initState();
    _loadApplication();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _licenceNoController.dispose();
    _licenceTypeController.dispose();
    _licenceExpiryController.dispose();
    _expYearsController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }
  Future<void> _loadApplication() async {
    try {
      final application = await _driverService.getMyApplication();
      if (!mounted) return;
      setState(() {
        _application = application;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load application: $error')),
      );
    }
  }
  Future<void> _onSubmitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final application = DriverApplicationModel(
      id: _driverService.currentUserId,
      userId: _driverService.currentUserId,
      fullName: _nameController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      licenceNumber: _licenceNoController.text.trim().toUpperCase(),
      licenceType: _licenceTypeController.text.trim(),
      licenceExpiry: _licenceExpiryController.text.trim(),
      drivingExperienceYears: int.tryParse(_expYearsController.text) ?? 1,
      canDriveManual: _canManual,
      canDriveAutomatic: _canAutomatic,
      documentType: _selectedDocType,
      documentNumber: _docNumberController.text.trim(),
      status: DriverApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );
    setState(() => _isLoading = true);
    try {
      await _driverService.submitApplication(application);
      if (!mounted) return;
      await _loadApplication();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to submit application: $error')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: AppBar(
        backgroundColor: _palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: _palette.textPrimary),
        title: Text(
          'Become a Driver',
          style: TextStyle(color: _palette.textPrimary, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: _palette.accent,
                ),
              )
            : _application != null
            ? _buildStatusView()
            : _buildApplicationForm(),
      ),
    );
  }
  Widget _buildStatusView() {
    final status = _application!.status;
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case DriverApplicationStatus.approved:
        statusColor = _palette.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case DriverApplicationStatus.rejected:
      case DriverApplicationStatus.suspended:
        statusColor = _palette.danger;
        statusIcon = Icons.cancel_rounded;
        break;
      case DriverApplicationStatus.moreInfoRequired:
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case DriverApplicationStatus.pending:
        statusColor = _palette.accent;
        statusIcon = Icons.hourglass_top_rounded;
        break;
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _palette.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: statusColor, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(statusIcon, color: statusColor, size: 48),
              const SizedBox(height: 12),
              Text(
                'Status: ${status.label}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                status == DriverApplicationStatus.pending
                    ? 'Your driver application has been submitted and is currently under review.'
                    : status == DriverApplicationStatus.approved
                    ? 'Congratulations! Your driver application has been verified and approved.'
                    : 'Your application status is: ${status.label}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _palette.textMuted,
                  fontSize: 13,
                ),
              ),
              if (_application!.adminNotes != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _palette.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _palette.surfaceBorder),
                  ),
                  child: Text(
                    'Notes: ${_application!.adminNotes}',
                    style: TextStyle(color: _palette.textPrimary, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _palette.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Summary',
                style: TextStyle(
                  color: _palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              _summaryRow('Full Name', _application!.fullName),
              _summaryRow('Phone', _application!.phone),
              _summaryRow('Licence No', _application!.licenceNumber),
              _summaryRow(
                'Experience',
                '${_application!.drivingExperienceYears} years',
              ),
              _summaryRow(
                'Document',
                '${_application!.documentType} (${_application!.documentNumber})',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (status == DriverApplicationStatus.rejected ||
            status == DriverApplicationStatus.moreInfoRequired)
          ElevatedButton(
            onPressed: () => setState(() => _application = null),
            style: ElevatedButton.styleFrom(
              backgroundColor: _palette.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Re-submit Application',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _palette.textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: _palette.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildApplicationForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              color: _palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(_nameController, 'Full Name', 'Enter your full name'),
          _buildTextField(_dobController, 'Date of Birth', 'YYYY-MM-DD'),
          _buildTextField(
            _phoneController,
            'Phone Number',
            '07X XXX XXXX',
            keyboardType: TextInputType.phone,
          ),
          _buildTextField(
            _addressController,
            'Address',
            'Current home address',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Text(
            'Driving Information',
            style: TextStyle(
              color: _palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _licenceNoController,
            'Driving Licence Number',
            'B1234567',
          ),
          _buildTextField(
            _licenceTypeController,
            'Licence Type',
            'e.g. Light Car / Heavy',
          ),
          _buildTextField(
            _licenceExpiryController,
            'Licence Expiry Date',
            'YYYY-MM-DD',
          ),
          _buildTextField(
            _expYearsController,
            'Experience (Years)',
            'Years of driving',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: Text(
              'Can drive Manual Transmission',
              style: TextStyle(color: _palette.textPrimary, fontSize: 14),
            ),
            value: _canManual,
            activeColor: _palette.accent,
            onChanged: (val) => setState(() => _canManual = val ?? true),
          ),
          CheckboxListTile(
            title: Text(
              'Can drive Automatic Transmission',
              style: TextStyle(color: _palette.textPrimary, fontSize: 14),
            ),
            value: _canAutomatic,
            activeColor: _palette.accent,
            onChanged: (val) => setState(() => _canAutomatic = val ?? true),
          ),
          const SizedBox(height: 20),
          Text(
            'Identity Verification Document',
            style: TextStyle(
              color: _palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedDocType,
            dropdownColor: _palette.surface,
            style: TextStyle(color: _palette.textPrimary),
            decoration: InputDecoration(
              labelText: 'Document Type',
              labelStyle: TextStyle(color: _palette.textMuted),
              filled: true,
              fillColor: _palette.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'National Identity Card (NIC)',
                child: Text('National Identity Card (NIC)'),
              ),
              DropdownMenuItem(value: 'Passport', child: Text('Passport')),
              DropdownMenuItem(
                value: 'Driving Licence',
                child: Text('Driving Licence'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedDocType = val);
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            _docNumberController,
            'Document Number',
            'Enter ID / Document number',
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onSubmitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _palette.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Submit Driver Application',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: _palette.textPrimary),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _palette.textMuted),
          hintText: hint,
          hintStyle: TextStyle(
            color: _palette.textMuted.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: _palette.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _palette.surfaceBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _palette.surfaceBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _palette.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
