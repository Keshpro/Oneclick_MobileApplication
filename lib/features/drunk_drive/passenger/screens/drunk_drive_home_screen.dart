import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'my_vehicles_screen.dart';
import 'book_driver_screen.dart';
import 'my_trips_screen.dart';
import 'active_trip_screen.dart';
import '../../driver/screens/driver_application_screen.dart';
import '../../driver/screens/driver_home_screen.dart';

class DrunkDriveHomeScreen extends StatefulWidget {
  const DrunkDriveHomeScreen({super.key});

  @override
  State<DrunkDriveHomeScreen> createState() => _DrunkDriveHomeScreenState();
}

class _DrunkDriveHomeScreenState extends State<DrunkDriveHomeScreen> {
  final BookingService _bookingService = BookingService();
  BookingModel? _activeBooking;

  @override
  void initState() {
    super.initState();
    _loadActiveBooking();
  }

  void _loadActiveBooking() {
    final bookings = _bookingService.getMyBookings();

    if (bookings.isEmpty) {
      setState(() => _activeBooking = null);
      return;
    }

    final latest = bookings.first;
    final isFinished =
        latest.status == BookingStatus.completed ||
        latest.status == BookingStatus.cancelledByUser ||
        latest.status == BookingStatus.cancelledByDriver;

    setState(() {
      _activeBooking = isFinished ? null : latest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        title: const Text(
          'Drunk & Drive',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Get home safely',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'A verified driver comes to you and drives your own vehicle.',
              style: TextStyle(color: DrunkDriveColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),

            if (_activeBooking == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: DrunkDriveColors.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: DrunkDriveColors.textMuted,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'No active trips',
                      style: TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: DrunkDriveColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: DrunkDriveColors.accent, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Current Trip',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DrunkDriveColors.accent.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _activeBooking!.status.label,
                            style: const TextStyle(
                              color: DrunkDriveColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_activeBooking!.pickup.name} → ${_activeBooking!.destination.name}',
                      style: const TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vehicle: ${_activeBooking!.vehicle.displayName}',
                      style: const TextStyle(
                        color: DrunkDriveColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    if (_activeBooking!.tripPin != null &&
                        _activeBooking!.status !=
                            BookingStatus.tripStarted) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DrunkDriveColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trip PIN',
                              style: TextStyle(
                                color: DrunkDriveColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _activeBooking!.tripPin!,
                              style: const TextStyle(
                                color: DrunkDriveColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Give this PIN to your driver when you are ready to start.',
                              style: TextStyle(
                                color: DrunkDriveColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ActiveTripScreen(booking: _activeBooking!),
                            ),
                          );

                          if (!mounted) return;

                          _loadActiveBooking();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DrunkDriveColors.accent,
                          side: const BorderSide(
                            color: DrunkDriveColors.accent,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'View Trip',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookDriverScreen(),
                    ),
                  ).then((_) => _loadActiveBooking());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDriveColors.accent,
                  foregroundColor: DrunkDriveColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Book a Driver',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyVehiclesScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: DrunkDriveColors.surfaceBorder),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'My Vehicles',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyTripsScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: DrunkDriveColors.surfaceBorder),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'My Trips',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverHomeScreen(),
                    ),
                  ).then((_) => _loadActiveBooking());
                },
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text(
                  'Switch to Driver Mode',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDriveColors.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: DrunkDriveColors.accent),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverApplicationScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.badge_rounded,
                  color: DrunkDriveColors.accent,
                ),
                label: const Text(
                  'Become a Driver / Driver Status',
                  style: TextStyle(
                    color: DrunkDriveColors.accent,
                    fontWeight: FontWeight.w700,
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
