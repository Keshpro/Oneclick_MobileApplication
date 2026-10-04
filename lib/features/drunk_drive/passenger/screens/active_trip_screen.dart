import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'payment_screen.dart';

class ActiveTripScreen extends StatefulWidget {
  final BookingModel booking;

  const ActiveTripScreen({super.key, required this.booking});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final BookingService _bookingService = BookingService();

  late BookingModel _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _refreshBooking();
  }

  void _refreshBooking() {
    final updated = _bookingService.getBookingById(widget.booking.id);

    if (updated != null) {
      setState(() {
        _booking = updated;
      });
    }
  }

  bool get _showTripPin {
    return _booking.tripPin != null &&
        _booking.status != BookingStatus.tripStarted &&
        _booking.status != BookingStatus.tripInProgress &&
        _booking.status != BookingStatus.tripCompleted &&
        _booking.status != BookingStatus.completed;
  }

  bool get _tripIsRunning {
    return _booking.status == BookingStatus.tripStarted ||
        _booking.status == BookingStatus.tripInProgress;
  }

  bool get _tripIsCompleted {
    return _booking.status == BookingStatus.tripCompleted ||
        _booking.status == BookingStatus.completed;
  }

  String get _statusMessage {
    switch (_booking.status) {
      case BookingStatus.requested:
        return 'Looking for an available driver...';

      case BookingStatus.searchingDriver:
        return 'Searching for a verified driver near you...';

      case BookingStatus.driverAssigned:
        return 'A driver has accepted your booking.';

      case BookingStatus.driverAccepted:
        return 'Your driver has accepted the trip.';

      case BookingStatus.driverArriving:
        return 'Your driver is on the way to you.';

      case BookingStatus.driverArrived:
        return 'Your driver has arrived.';

      case BookingStatus.verification:
        return 'Verify the driver and provide your Trip PIN when ready.';

      case BookingStatus.tripStarted:
      case BookingStatus.tripInProgress:
        return 'Your trip is currently in progress.';

      case BookingStatus.tripCompleted:
        return 'Your trip has been completed safely.';

      case BookingStatus.payment:
        return 'Your trip is complete. Payment is pending.';

      case BookingStatus.completed:
        return 'This booking has been completed.';

      case BookingStatus.cancelledByUser:
        return 'This booking was cancelled by you.';

      case BookingStatus.cancelledByDriver:
        return 'This booking was cancelled by the driver.';

      case BookingStatus.driverNotFound:
        return 'No driver was available for this booking.';

      case BookingStatus.paymentFailed:
        return 'The payment could not be completed.';

      case BookingStatus.incidentReported:
        return 'An incident has been reported for this trip.';
    }
  }

  Color get _statusColor {
    if (_tripIsCompleted) {
      return DrunkDriveColors.success;
    }

    if (_booking.status == BookingStatus.cancelledByUser ||
        _booking.status == BookingStatus.cancelledByDriver ||
        _booking.status == BookingStatus.driverNotFound ||
        _booking.status == BookingStatus.paymentFailed ||
        _booking.status == BookingStatus.incidentReported) {
      return DrunkDriveColors.danger;
    }

    return DrunkDriveColors.accent;
  }

  Future<void> _openPayment() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(booking: _booking)),
    );

    if (!mounted) return;

    _refreshBooking();

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature — coming soon')));
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
          'Trip Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _refreshBooking,
            tooltip: 'Refresh trip',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshBooking();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),

              if (_showTripPin) ...[
                _buildPinCard(),
                const SizedBox(height: 16),
              ],

              _buildRouteCard(),
              const SizedBox(height: 16),

              _buildVehicleCard(),
              const SizedBox(height: 16),

              _buildTripSummaryCard(),
              const SizedBox(height: 20),

              if (_booking.status == BookingStatus.tripCompleted ||
                  _booking.status == BookingStatus.payment) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openPayment,
                    icon: const Icon(Icons.payment_rounded),
                    label: const Text(
                      'Proceed to Payment',
                      style: TextStyle(fontWeight: FontWeight.w800),
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
                const SizedBox(height: 16),
              ],

              if (_tripIsRunning) ...[
                _buildSafetyCard(),
                const SizedBox(height: 16),
              ],

              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _statusColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _tripIsCompleted
                ? Icons.check_circle_rounded
                : _tripIsRunning
                ? Icons.directions_car_filled_rounded
                : Icons.schedule_rounded,
            color: _statusColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _booking.status.label,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    color: DrunkDriveColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DrunkDriveColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DrunkDriveColors.accent),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.pin_rounded,
            color: DrunkDriveColors.accent,
            size: 30,
          ),
          const SizedBox(height: 8),
          const Text(
            'Trip PIN',
            style: TextStyle(color: DrunkDriveColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            _booking.tripPin!,
            style: const TextStyle(
              color: DrunkDriveColors.accent,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Give this PIN to your assigned driver only when you are ready to start the trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DrunkDriveColors.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DrunkDriveColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(
            Icons.my_location_rounded,
            DrunkDriveColors.success,
            'Pickup',
            _booking.pickup.name,
          ),
          const SizedBox(height: 16),
          _detailRow(
            Icons.location_on_rounded,
            DrunkDriveColors.danger,
            'Destination',
            _booking.destination.name,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DrunkDriveColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Vehicle',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(
            Icons.directions_car_rounded,
            DrunkDriveColors.accent,
            'Vehicle',
            _booking.vehicle.displayName,
          ),
          const SizedBox(height: 14),
          _detailRow(
            Icons.confirmation_number_outlined,
            DrunkDriveColors.textMuted,
            'Registration',
            _booking.vehicle.registrationNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: DrunkDriveColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Summary',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(
            Icons.route_rounded,
            DrunkDriveColors.textMuted,
            'Distance',
            '${_booking.distanceKm.toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 14),
          _detailRow(
            Icons.schedule_rounded,
            DrunkDriveColors.textMuted,
            'Estimated Time',
            '${_booking.durationMinutes} min',
          ),
          const SizedBox(height: 14),
          _detailRow(
            Icons.payments_rounded,
            DrunkDriveColors.success,
            'Estimated Fare',
            'Rs. ${_booking.fareEstimate.total.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DrunkDriveColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DrunkDriveColors.accent.withValues(alpha: 0.35),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: DrunkDriveColors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your trip is active. Stay safe and use the emergency option if you need assistance.',
              style: TextStyle(
                color: DrunkDriveColors.textMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showComingSoon('Share Trip'),
            icon: const Icon(Icons.share_rounded),
            label: const Text(
              'Share Trip',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: DrunkDriveColors.surfaceBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _booking.driverId == null
                ? null
                : () => _showComingSoon('Contact Driver'),
            icon: const Icon(Icons.phone_rounded),
            label: const Text(
              'Contact Driver',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: DrunkDriveColors.accent,
              side: const BorderSide(color: DrunkDriveColors.accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showComingSoon('Emergency / SOS'),
            icon: const Icon(Icons.sos_rounded, color: DrunkDriveColors.danger),
            label: const Text(
              'Emergency / SOS',
              style: TextStyle(
                color: DrunkDriveColors.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
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
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
