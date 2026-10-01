import 'package:flutter/material.dart';

import '../../models/driver_application_model.dart';
import '../../services/driver_service.dart';
import '../../theme/drunk_drive_colors.dart';

class DriverApplicationScreen extends StatefulWidget {
  const DriverApplicationScreen({super.key});

  @override
  State<DriverApplicationScreen> createState() => _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final DriverService _driverService = DriverService();
  final _formKey = GlobalKey<FormState>();

  DriverApplicationModel? _application;
  bool _isLoading = true;

  // Form Controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _licenceNoController = TextEditingController();
  final _licenceTypeController = TextEditingController(text: 'Heavy Vehicle / Light Car');
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

  void _loadApplication() {
    setState(() {
      _application = _driverService.getMyApplication();
      _isLoading = false;
    });
  }

  void _onSubmitForm() {
    if (!_formKey.currentState!.validate()) return;

    final app = _driverService.submitApplication(
      fullName: _nameController.text,
      dateOfBirth: _dobController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      licenceNumber: _licenceNoController.text,
      licenceType: _licenceTypeController.text,
      licenceExpiry: _licenceExpiryController.text,
      drivingExperienceYears: int.tryParse(_expYearsController.text) ?? 1,
      canDriveManual: _canManual,
      canDriveAutomatic: _canAutomatic,
      documentType: _selectedDocType,
      documentNumber: _docNumberController.text,
    );

    setState(() {
      _application = app;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application submitted successfully!')),
    );
  }

  void _simulateStatus(DriverApplicationStatus status) {
    if (_application == null) return;
    _driverService.debugUpdateStatus(
      _application!.id,
      status,
      notes: status == DriverApplicationStatus.rejected
          ? 'Licence document was unclear. Please upload a legible photo.'
          : null,
    );
    _loadApplication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Become a Driver',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: DrunkDriveColors.accent))
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
        statusColor = DrunkDriveColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case DriverApplicationStatus.rejected:
      case DriverApplicationStatus.suspended:
        statusColor = DrunkDriveColors.danger;
        statusIcon = Icons.cancel_rounded;
        break;
      case DriverApplicationStatus.moreInfoRequired:
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case DriverApplicationStatus.pending:
        statusColor = DrunkDriveColors.accent;
        statusIcon = Icons.hourglass_top_rounded;
        break;
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: DrunkDriveColors.surface,
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
                style: const TextStyle(color: DrunkDriveColors.textMuted, fontSize: 13),
              ),
              if (_application!.adminNotes != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DrunkDriveColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Notes: ${_application!.adminNotes}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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
            color: DrunkDriveColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Application Summary',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 12),
              _summaryRow('Full Name', _application!.fullName),
              _summaryRow('Phone', _application!.phone),
              _summaryRow('Licence No', _application!.licenceNumber),
              _summaryRow('Experience', '${_application!.drivingExperienceYears} years'),
              _summaryRow('Document', '${_application!.documentType} (${_application!.documentNumber})'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (status == DriverApplicationStatus.rejected || status == DriverApplicationStatus.moreInfoRequired)
          ElevatedButton(
            onPressed: () => setState(() => _application = null),
            style: ElevatedButton.styleFrom(
              backgroundColor: DrunkDriveColors.accent,
              foregroundColor: DrunkDriveColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Re-submit Application', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        const SizedBox(height: 30),
        // Prototype / Demo controls to simulate Admin review actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DrunkDriveColors.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DrunkDriveColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROTOTYPE DEMO: Simulate Admin Approval',
                style: TextStyle(color: DrunkDriveColors.accent, fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _simulateStatus(DriverApplicationStatus.approved),
                    child: const Text('Set Approved', style: TextStyle(color: DrunkDriveColors.success, fontSize: 12)),
                  ),
                  OutlinedButton(
                    onPressed: () => _simulateStatus(DriverApplicationStatus.rejected),
                    child: const Text('Set Rejected', style: TextStyle(color: DrunkDriveColors.danger, fontSize: 12)),
                  ),
                  OutlinedButton(
                    onPressed: () => _simulateStatus(DriverApplicationStatus.pending),
                    child: const Text('Set Pending', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            ],
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
          Text(label, style: const TextStyle(color: DrunkDriveColors.textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
          const Text(
            'Personal Information',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildTextField(_nameController, 'Full Name', 'Enter your full name'),
          _buildTextField(_dobController, 'Date of Birth', 'YYYY-MM-DD'),
          _buildTextField(_phoneController, 'Phone Number', '07X XXX XXXX', keyboardType: TextInputType.phone),
          _buildTextField(_addressController, 'Address', 'Current home address', maxLines: 2),
          const SizedBox(height: 20),
          const Text(
            'Driving Information',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildTextField(_licenceNoController, 'Driving Licence Number', 'B1234567'),
          _buildTextField(_licenceTypeController, 'Licence Type', 'e.g. Light Car / Heavy'),
          _buildTextField(_licenceExpiryController, 'Licence Expiry Date', 'YYYY-MM-DD'),
          _buildTextField(_expYearsController, 'Experience (Years)', 'Years of driving', keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Can drive Manual Transmission', style: TextStyle(color: Colors.white, fontSize: 14)),
            value: _canManual,
            activeColor: DrunkDriveColors.accent,
            onChanged: (val) => setState(() => _canManual = val ?? true),
          ),
          CheckboxListTile(
            title: const Text('Can drive Automatic Transmission', style: TextStyle(color: Colors.white, fontSize: 14)),
            value: _canAutomatic,
            activeColor: DrunkDriveColors.accent,
            onChanged: (val) => setState(() => _canAutomatic = val ?? true),
          ),
          const SizedBox(height: 20),
          const Text(
            'Identity Verification Document',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedDocType,
            dropdownColor: DrunkDriveColors.surface,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Document Type',
              labelStyle: const TextStyle(color: DrunkDriveColors.textMuted),
              filled: true,
              fillColor: DrunkDriveColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: const [
              DropdownMenuItem(value: 'National Identity Card (NIC)', child: Text('National Identity Card (NIC)')),
              DropdownMenuItem(value: 'Passport', child: Text('Passport')),
              DropdownMenuItem(value: 'Driving Licence', child: Text('Driving Licence')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedDocType = val);
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(_docNumberController, 'Document Number', 'Enter ID / Document number'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onSubmitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: DrunkDriveColors.accent,
              foregroundColor: DrunkDriveColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Submit Driver Application', style: TextStyle(fontWeight: FontWeight.w800)),
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
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: DrunkDriveColors.textMuted),
          hintText: hint,
          hintStyle: TextStyle(color: DrunkDriveColors.textMuted.withValues(alpha: 0.5)),
          filled: true,
          fillColor: DrunkDriveColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
