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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing trip: $error')),
      );
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
        const SnackBar(content: Text('Incident report submitted successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final colors = DrunkDrivePalette.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Active Trip',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_filled_rounded,
                    color: colors.success,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isCompleted ? 'Trip Completed' : booking.status.label,
                      style: TextStyle(
                        color: colors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(
                    Icons.my_location_rounded,
                    colors.success,
                    'Pickup',
                    booking.pickup.name,
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.location_on_rounded,
                    colors.danger,
                    'Destination',
                    booking.destination.name,
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.directions_car_rounded,
                    colors.accent,
                    'Vehicle',
                    '${booking.vehicle.displayName} • ${booking.vehicle.registrationNumber}',
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.route_rounded,
                    colors.textMuted,
                    'Distance / ETA',
                    '${booking.distanceKm.toStringAsFixed(1)} km • ${booking.durationMinutes} min',
                  ),
                  const SizedBox(height: 12),
                  _row(
                    Icons.payments_rounded,
                    colors.textMuted,
                    'Fare',
                    'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _onReportIncident,
              icon: Icon(Icons.report_outlined, color: colors.danger),
              label: Text(
                'Report Incident',
                style: TextStyle(color: colors.danger),
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
                backgroundColor: colors.danger,
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
                  : Text(
                      _isCompleted ? 'Trip Completed' : 'End Trip',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, Color color, String label, String value) {
    final colors = DrunkDrivePalette.of(context);

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
                style: TextStyle(color: colors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: colors.textPrimary,
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
