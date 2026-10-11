import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/incident_model.dart';
import '../../services/incident_service.dart';
import '../../services/vehicle_service.dart';
import '../../theme/drunk_drive_colors.dart';

class ReportIncidentScreen extends StatefulWidget {
  final BookingModel booking;

  const ReportIncidentScreen({super.key, required this.booking});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final IncidentService _incidentService = IncidentService();
  final TextEditingController _descriptionController = TextEditingController();

  IncidentType? _selectedType;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitIncident() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an incident type.')),
      );
      return;
    }

    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe what happened.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    _incidentService.reportIncident(
      bookingId: widget.booking.id,
      reportedBy: VehicleService.currentUserId,
      type: _selectedType!,
      description: description,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: DrunkDriveColors.surface,
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: DrunkDriveColors.success),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Incident Reported',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: const Text(
            'Your incident report has been recorded.',
            style: TextStyle(color: DrunkDriveColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Done',
                style: TextStyle(color: DrunkDriveColors.accent),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context, true);
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
          'Report Incident',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Incident Type',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            ...IncidentType.values.map((type) {
              final isSelected = _selectedType == type;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DrunkDriveColors.accent.withValues(alpha: 0.12)
                          : DrunkDriveColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? DrunkDriveColors.accent
                            : DrunkDriveColors.surfaceBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? DrunkDriveColors.accent
                              : DrunkDriveColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            type.label,
                            style: TextStyle(
                              color: isSelected
                                  ? DrunkDriveColors.accent
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              minLines: 4,
              maxLines: 7,
              maxLength: 500,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe what happened...',
                hintStyle: const TextStyle(color: DrunkDriveColors.textMuted),
                filled: true,
                fillColor: DrunkDriveColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: DrunkDriveColors.surfaceBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: DrunkDriveColors.surfaceBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: DrunkDriveColors.accent),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitIncident,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DrunkDriveColors.background,
                        ),
                      )
                    : const Icon(Icons.report_rounded),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Incident Report',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDriveColors.accent,
                  foregroundColor: DrunkDriveColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
