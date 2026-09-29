import 'package:flutter/material.dart';

import '../../models/fare_estimate.dart';
import '../../models/location_model.dart';
import '../../models/trip_reason.dart';
import '../../models/vehicle_model.dart';
import '../../services/booking_service.dart';
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
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final BookingService _bookingService = BookingService();
  bool _isConfirming = false;

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

  Future<void> _onConfirm() async {
    setState(() => _isConfirming = true);

    await Future.delayed(const Duration(milliseconds: 400));

    _bookingService.createBooking(
      vehicle: widget.vehicle,
      pickup: widget.pickup,
      destination: widget.destination,
      reason: widget.reason,
      fareEstimate: widget.fareEstimate,
      distanceKm: widget.distanceKm,
      durationMinutes: widget.durationMinutes,
    );

    if (!mounted) return;
    setState(() => _isConfirming = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DrunkDriveColors.surface,
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: DrunkDriveColors.success),
            SizedBox(width: 10),
            Text('Booking Created', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "We're now finding a nearby verified driver for you.",
          style: TextStyle(color: DrunkDriveColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done', style: TextStyle(color: DrunkDriveColors.accent)),
          ),
        ],
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DrunkDriveHomeScreen()),
      (route) => route.isFirst,
    );
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
          'Confirm Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DrunkDriveColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(Icons.my_location_rounded, DrunkDriveColors.success, 'Pickup', widget.pickup.name),
                  const SizedBox(height: 12),
                  _detailRow(Icons.location_on_rounded, DrunkDriveColors.danger, 'Destination', widget.destination.name),
                  const SizedBox(height: 12),
                  _detailRow(Icons.directions_car_rounded, DrunkDriveColors.accent, 'Vehicle', widget.vehicle.displayName),
                  const SizedBox(height: 12),
                  _detailRow(Icons.info_outline_rounded, DrunkDriveColors.textMuted, 'Reason', widget.reason.label),
                  const SizedBox(height: 12),
                  _detailRow(
                    Icons.route_rounded,
                    DrunkDriveColors.textMuted,
                    'Distance / Time',
                    '${widget.distanceKm.toStringAsFixed(1)} km • ${widget.durationMinutes} min',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DrunkDriveColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Fare',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    _rs(widget.fareEstimate.total),
                    style: const TextStyle(
                      color: DrunkDriveColors.accent,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isConfirming ? null : _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DrunkDriveColors.accent,
                    foregroundColor: DrunkDriveColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isConfirming
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DrunkDriveColors.background,
                          ),
                        )
                      : const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isConfirming ? null : () => Navigator.pop(context),
                  child: const Text('Edit', style: TextStyle(color: DrunkDriveColors.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: DrunkDriveColors.textMuted, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}