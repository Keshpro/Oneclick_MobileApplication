import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/vehicle_model.dart';
import '../../services/booking_service.dart';
import '../../services/driver_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'driver_application_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final DriverService _driverService = DriverService();
  final BookingService _bookingService = BookingService();

  bool _isOnline = false;
  bool _isApproved = false;
  List<BookingModel> _incomingRequests = [];

  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  void _checkAuthorization() {
    final isApproved = _driverService.isCurrentDriverApproved();
    setState(() {
      _isApproved = isApproved;
    });

    if (isApproved) {
      _loadRequests();
    }
  }

  void _loadRequests() {
    // Incoming requests for drivers (e.g. requested bookings)
    final allBookings = _bookingService.getMyBookings();
    setState(() {
      _incomingRequests = allBookings;
    });
  }

  void _toggleOnline(bool value) {
    if (!_isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only approved drivers can go online.')),
      );
      return;
    }

    setState(() {
      _isOnline = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'You are now ONLINE' : 'You are now OFFLINE'),
        backgroundColor: _isOnline ? DrunkDriveColors.success : DrunkDriveColors.surfaceBorder,
      ),
    );
  }

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Driver Mode',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: !_isApproved ? _buildNotApprovedView() : _buildDriverDashboard(),
      ),
    );
  }

  Widget _buildNotApprovedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_person_rounded,
              color: DrunkDriveColors.danger,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Driver Mode Restricted',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your account has not been approved for Driver Mode yet. You must complete verification and receive backend approval first.',
              textAlign: TextAlign.center,
              style: TextStyle(color: DrunkDriveColors.textMuted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverApplicationScreen(),
                  ),
                ).then((_) => _checkAuthorization());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DrunkDriveColors.accent,
                foregroundColor: DrunkDriveColors.background,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('View Driver Application Status', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDashboard() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Online / Offline Switcher Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DrunkDriveColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isOnline ? DrunkDriveColors.success : DrunkDriveColors.surfaceBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isOnline ? DrunkDriveColors.success : DrunkDriveColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      color: _isOnline ? DrunkDriveColors.success : DrunkDriveColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isOnline,
                activeTrackColor: DrunkDriveColors.success,
                onChanged: _toggleOnline,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Earnings & Stats Grid
        Row(
          children: [
            Expanded(
              child: _statCard('Today\'s Trips', '4', Icons.local_taxi_rounded, DrunkDriveColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard('Today\'s Earnings', _rs(4500), Icons.payments_rounded, DrunkDriveColors.success),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard('Driver Rating', '4.8 ★', Icons.star_rounded, Colors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard('Weekly Total', _rs(18200), Icons.account_balance_wallet_rounded, Colors.cyanAccent),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Booking Requests Section
        const Text(
          'Booking Requests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          _isOnline
              ? 'Searching for customer trip requests in your area...'
              : 'Switch to ONLINE to start receiving booking requests.',
          style: const TextStyle(color: DrunkDriveColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 14),

        if (!_isOnline)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DrunkDriveColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'You are currently offline.',
                style: TextStyle(color: DrunkDriveColors.textMuted),
              ),
            ),
          )
        else if (_incomingRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DrunkDriveColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'No pending requests near you.',
                style: TextStyle(color: DrunkDriveColors.textMuted),
              ),
            ),
          )
        else
          ..._incomingRequests.map((booking) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BookingRequestCard(booking: booking),
              )),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DrunkDriveColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: DrunkDriveColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingRequestCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DrunkDriveColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DrunkDriveColors.accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Trip Request',
                style: TextStyle(color: DrunkDriveColors.accent, fontWeight: FontWeight.w800, fontSize: 14),
              ),
              Text(
                'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Pickup: ${booking.pickup.name}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text('Destination: ${booking.destination.name}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Vehicle: ${booking.vehicle.displayName} (${booking.vehicle.transmission.label})',
            style: const TextStyle(color: DrunkDriveColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request declined')));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DrunkDriveColors.danger,
                    side: const BorderSide(color: DrunkDriveColors.danger),
                  ),
                  child: const Text('DECLINE'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking Accepted!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DrunkDriveColors.success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ACCEPT', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
