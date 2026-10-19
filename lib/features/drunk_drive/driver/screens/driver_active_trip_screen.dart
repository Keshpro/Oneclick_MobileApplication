import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';

import '../../services/booking_firestore_service.dart';

import '../../theme/drunk_drive_colors.dart';
import 'report_incident_screen.dart';

class DriverActiveTripScreen extends StatefulWidget {
  final BookingModel booking;

  const DriverActiveTripScreen({super.key, required this.booking});

  @override
  State<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends State<DriverActiveTripScreen> {
  bool _isEnding = false;
  bool _isCompleted = false;

  Future<void> _onEndTrip() async {
    if (_isEnding || _isCompleted) return;

    setState(() => _isEnding = true);

    try {
      final updated = await BookingFirestoreService().endTrip(
        bookingId: widget.booking.id,
      );

      if (!mounted) return;

      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to complete this trip.')),
        );
        return;
      }

      setState(() => _isCompleted = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip completed successfully!')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error completing trip: $error')));
    } finally {
      if (mounted) {
        setState(() => _isEnding = false);
      }
    }
  }

  Future<void> _onReportIncident() async {
    final reported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportIncidentScreen(booking: widget.booking),
      ),
    );

    if (!mounted) return;

    if (reported == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident report submitted successfully.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Active Trip',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DrunkDriveColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    color: DrunkDriveColors.success,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    booking.status.label,
                    style: const TextStyle(
                      color: DrunkDriveColors.success,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DrunkDriveColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(
                    Icons.my_location_rounded,
                    DrunkDriveColors.success,
                    'Pickup',
                    booking.pickup.name,
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.location_on_rounded,
                    DrunkDriveColors.danger,
                    'Destination',
                    booking.destination.name,
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.directions_car_rounded,
                    DrunkDriveColors.accent,
                    'Vehicle',
                    '${booking.vehicle.displayName} • ${booking.vehicle.registrationNumber}',
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.route_rounded,
                    DrunkDriveColors.textMuted,
                    'Distance / ETA',
                    '${booking.distanceKm.toStringAsFixed(1)} km • ${booking.durationMinutes} min',
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.payments_rounded,
                    DrunkDriveColors.textMuted,
                    'Fare',
                    'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _onReportIncident,
              icon: const Icon(
                Icons.report_outlined,
                color: DrunkDriveColors.danger,
              ),
              label: const Text(
                'Report Incident',
                style: TextStyle(color: DrunkDriveColors.danger),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isEnding || _isCompleted) ? null : _onEndTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: DrunkDriveColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isEnding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'End Trip',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: DrunkDriveColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
