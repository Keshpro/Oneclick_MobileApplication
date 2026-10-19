import 'package:flutter/material.dart';

import '../../models/fare_estimate.dart';
import '../../models/location_model.dart';
import '../../models/trip_reason.dart';
import '../../models/vehicle_model.dart';
import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_firestore_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'drunk_drive_home_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final VehicleModel vehicle;
  final LocationModel pickup;
  final LocationModel destination;
  final TripReason reason;
  final FareEstimate fareEstimate;
  final double distanceKm;
  final int durationMinutes;

  const BookingConfirmationScreen({
    super.key,
    required this.vehicle,
    required this.pickup,
    required this.destination,
    required this.reason,
    required this.fareEstimate,
    required this.distanceKm,
    required this.durationMinutes,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final BookingFirestoreService _bookingService = BookingFirestoreService();
  bool _isConfirming = false;

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

  Future<void> _onConfirm() async {
    if (_isConfirming) return;

    setState(() => _isConfirming = true);

    try {
      final booking = BookingModel(
        id: '',
        passengerId: _bookingService.currentUserId,
        vehicle: widget.vehicle,
        pickup: widget.pickup,
        destination: widget.destination,
        reason: widget.reason,
        fareEstimate: widget.fareEstimate,
        distanceKm: widget.distanceKm,
        durationMinutes: widget.durationMinutes,
        status: BookingStatus.searchingDriver,
        createdAt: DateTime.now(),
      );

      await _bookingService.createBookingModel(booking);

      if (!mounted) return;
      setState(() => _isConfirming = false);

      final colors = DrunkDrivePalette.of(context);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: colors.surface,
          title: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: colors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Booking Created',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "We're now searching for an available driver.",
            style: TextStyle(color: colors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Done', style: TextStyle(color: colors.accent)),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DrunkDriveHomeScreen(),
        ),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to create booking: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DrunkDrivePalette.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Confirm Booking',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                  _detailRow(
                    Icons.my_location_rounded,
                    colors.success,
                    'Pickup',
                    widget.pickup.name,
                    colors,
                  ),
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.location_on_rounded,
                    colors.danger,
                    'Destination',
                    widget.destination.name,
                    colors,
                  ),
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.directions_car_rounded,
                    colors.accent,
                    'Vehicle',
                    widget.vehicle.displayName,
                    colors,
                  ),
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.info_outline_rounded,
                    colors.textMuted,
                    'Reason',
                    widget.reason.label,
                    colors,
                  ),
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.route_rounded,
                    colors.textMuted,
                    'Distance / Time',
                    '${widget.distanceKm.toStringAsFixed(1)} km • ${widget.durationMinutes} min',
                    colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Estimated Fare',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _rs(widget.fareEstimate.total),
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.surfaceBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConfirming ? null : _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colors.surfaceBorder,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isConfirming ? null : () => Navigator.pop(context),
                  child: Text(
                    'Edit',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    Color iconColor,
    String label,
    String value,
    DrunkDrivePalette colors,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
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
