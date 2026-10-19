import 'dart:async';

import 'package:flutter/material.dart';

import '../../../auth/screens/provider_role_selection_screen.dart';
import '../../driver/screens/driver_home_screen.dart';
import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_firestore_service.dart';
import '../../services/driver_firestore_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'active_trip_screen.dart';
import 'book_driver_screen.dart';
import 'my_trips_screen.dart';
import 'my_vehicles_screen.dart';

/// Customer entry point for Drunk & Drive.
/// The shared OneClick provider flow stays in the auth module.
class DrunkDriveHomeScreen extends StatefulWidget {
  const DrunkDriveHomeScreen({super.key});

  @override
  State<DrunkDriveHomeScreen> createState() => _DrunkDriveHomeScreenState();
}

class _DrunkDriveHomeScreenState extends State<DrunkDriveHomeScreen> {
  final BookingFirestoreService _bookings = BookingFirestoreService();
  StreamSubscription<List<BookingModel>>? _subscription;
  BookingModel? _activeBooking;
  bool _isApprovedDriver = false;

  @override
  void initState() {
    super.initState();
    _subscription = _bookings.watchMyBookingModels().listen(
      (bookings) {
        const terminal = {
          BookingStatus.completed,
          BookingStatus.cancelledByUser,
          BookingStatus.cancelledByDriver,
          BookingStatus.driverNotFound,
        };
        if (!mounted) return;
        setState(() {
          final active = bookings.where((b) => !terminal.contains(b.status));
          _activeBooking = active.isEmpty ? null : active.first;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load trips: $error')),
        );
      },
    );
    _checkDriverAccess();
  }

  Future<void> _checkDriverAccess() async {
    try {
      final approved = await DriverFirestoreService().isCurrentDriverApproved();
      if (mounted) setState(() => _isApprovedDriver = approved);
    } catch (_) {
      // Guests and unapproved accounts can still view the customer entry UI.
      if (mounted) setState(() => _isApprovedDriver = false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = DrunkDrivePalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Drunk & Drive', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF087F8C), Color(0xFF05636D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.directions_car_filled_rounded,
                      color: Colors.white, size: 38),
                  const SizedBox(height: 16),
                  const Text('Get home safely', style: TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('Book a verified driver to drive your own vehicle.',
                    style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _open(const BookDriverScreen()),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF05636D),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    ),
                    icon: const Icon(Icons.add_road_rounded),
                    label: const Text('Book a Driver',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Your trip', style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800, color: colors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.surfaceBorder),
              ),
              child: _activeBooking == null
                  ? Row(children: [
                      Icon(Icons.route_rounded, color: colors.accent),
                      const SizedBox(width: 12),
                      Text('No active trips', style: TextStyle(color: colors.textMuted)),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Current trip', style: TextStyle(
                        color: colors.textPrimary, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 7),
                      Text(_activeBooking!.status.label,
                        style: TextStyle(color: colors.accent, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('${_activeBooking!.pickup.name} → ${_activeBooking!.destination.name}',
                        style: TextStyle(color: colors.textMuted)),
                      const SizedBox(height: 6),
                      Text('Vehicle: ${_activeBooking!.vehicle.displayName}',
                        style: TextStyle(color: colors.textMuted)),
                      if (_activeBooking!.tripPin != null &&
                          _activeBooking!.status != BookingStatus.tripStarted) ...[
                        const SizedBox(height: 12),
                        Text('Trip PIN: ${_activeBooking!.tripPin}',
                          style: TextStyle(color: colors.accent,
                              fontSize: 20, fontWeight: FontWeight.w900)),
                        Text('Share this with your driver only when ready to begin.',
                          style: TextStyle(color: colors.textMuted, fontSize: 12)),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _open(ActiveTripScreen(booking: _activeBooking!)),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('View active trip'),
                      ),
                    ]),
            ),
            const SizedBox(height: 22),
            Text('Manage your journeys', style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800, color: colors.textPrimary)),
            const SizedBox(height: 12),
            _ServiceTile(
              title: 'My Vehicles', subtitle: 'Manage your registered vehicles',
              icon: Icons.directions_car_outlined, colors: colors,
              onTap: () => _open(const MyVehiclesScreen()),
            ),
            const SizedBox(height: 10),
            _ServiceTile(
              title: 'My Trips', subtitle: 'See previous and cancelled trips',
              icon: Icons.history_rounded, colors: colors,
              onTap: () => _open(const MyTripsScreen()),
            ),
            const SizedBox(height: 22),
            Text('Want to provide services?', style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800, color: colors.textPrimary)),
            const SizedBox(height: 12),
            _ServiceTile(
              title: 'Service Providers',
              subtitle: 'Explore OneClick provider roles and registration',
              icon: Icons.badge_outlined, colors: colors,
              onTap: () => _open(const ProviderRoleSelectionScreen()),
            ),
            if (_isApprovedDriver) ...[
              const SizedBox(height: 10),
              _ServiceTile(
                title: 'Driver Dashboard',
                subtitle: 'Manage your requests and earnings',
                icon: Icons.dashboard_outlined, colors: colors,
                onTap: () => _open(const DriverHomeScreen()),
              ),
            ],
            const SizedBox(height: 12),
            Text('OneClick • ${dark ? 'Dark' : 'Light'} appearance',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final DrunkDrivePalette colors;
  final VoidCallback onTap;

  const _ServiceTile({required this.title, required this.subtitle,
    required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: colors.surfaceBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: colors.textPrimary,
                  fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: colors.textMuted,
                  fontSize: 12)),
              ],
            )),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ]),
        ),
      ),
    );
  }
}
