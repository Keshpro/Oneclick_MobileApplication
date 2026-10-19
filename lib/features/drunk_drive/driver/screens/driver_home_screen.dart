import 'dart:async';

import '../../services/booking_firestore_service.dart';
import '../../services/driver_firestore_service.dart';

import 'package:flutter/material.dart';

import '../../models/vehicle_model.dart';
import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/vehicle_service.dart';
import '../../services/driver_rating_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'driver_application_screen.dart';
import 'driver_active_trip_screen.dart';
import 'driver_trip_history_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});
  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final BookingFirestoreService _firestoreService = BookingFirestoreService();
  StreamSubscription<List<BookingModel>>? _requestsSubscription;
  StreamSubscription<BookingModel?>? _activeTripSubscription;
  final DriverRatingService _driverRatingService = DriverRatingService();

  bool _isOnline = false;

  bool _isApproved = false;
  List<BookingModel> _incomingRequests = [];
  BookingModel? _activeTrip;
  final TextEditingController _pinController = TextEditingController();

  bool _isStartingTrip = false;

  int _todayTrips = 0;

  double _todayEarnings = 0;

  double _weeklyEarnings = 0;
  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    _activeTripSubscription?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthorization() async {
    try {
      final isApproved = await DriverFirestoreService()
          .isCurrentDriverApproved();
      if (!mounted) return;
      setState(() {
        _isApproved = isApproved;
      });
      if (isApproved) {
        _loadRequests();
        _loadActiveTrip();
        _loadDriverStats();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to check driver status: $error')),
      );
    }
  }

  void _loadRequests() {
    _requestsSubscription?.cancel();
    _requestsSubscription = _firestoreService.watchAvailableRequests().listen(
      (requests) {
        if (!mounted) return;
        setState(() {
          _incomingRequests = requests;
        });
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load booking requests: $error')),
        );
      },
    );
  }

  void _loadActiveTrip() {
    _activeTripSubscription?.cancel();
    _activeTripSubscription = _firestoreService
        .watchMyActiveDriverBooking()
        .listen(
          (booking) {
            if (!mounted) return;
            setState(() {
              _activeTrip = booking;
            });
          },
          onError: (error) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable to load active trip: $error')),
            );
          },
        );
  }

  String get _driverRatingText {
    final average = _driverRatingService.getAverageRating(
      VehicleService.currentUserId,
    );
    final count = _driverRatingService.getRatingCount(
      VehicleService.currentUserId,
    );
    if (average == null || count == 0) {
      return 'No ratings';
    }
    return '${average.toStringAsFixed(1)} ★ ($count)';
  }

  Future<void> _loadDriverStats() async {
    try {
      final completedTrips = await _firestoreService.getCompletedDriverTrips();
      if (!mounted) return;
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfWeek = startOfToday.subtract(
        Duration(days: now.weekday - 1),
      );
      int todayTrips = 0;
      double todayEarnings = 0;
      double weeklyEarnings = 0;
      for (final booking in completedTrips) {
        final completedAt = booking.completedAt;
        if (completedAt == null) continue;
        if (!completedAt.isBefore(startOfToday)) {
          todayTrips++;
          todayEarnings += booking.fareEstimate.total;
        }
        if (!completedAt.isBefore(startOfWeek)) {
          weeklyEarnings += booking.fareEstimate.total;
        }
      }
      setState(() {
        _todayTrips = todayTrips;
        _todayEarnings = todayEarnings;
        _weeklyEarnings = weeklyEarnings;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load driver statistics: $error')),
      );
    }
  }

  Future<void> _onStartHeading() async {
    if (_activeTrip == null) return;
    try {
      final updated = await _firestoreService.startHeadingToCustomer(
        _activeTrip!.id,
      );
      if (!mounted) return;
      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start heading to customer.')),
        );
        return;
      }
      setState(() {
        _activeTrip = updated;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Heading to customer.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to update trip: $error')));
    }
  }

  Future<void> _onDriverArrived() async {
    if (_activeTrip == null) return;
    try {
      final updated = await _firestoreService.markDriverArrived(
        _activeTrip!.id,
      );
      if (!mounted) return;
      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to mark driver as arrived.')),
        );
        return;
      }
      setState(() {
        _activeTrip = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have arrived at the customer.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update arrival: $error')),
      );
    }
  }

  Future<void> _onBeginVerification() async {
    if (_activeTrip == null) return;
    try {
      final updated = await _firestoreService.beginVerification(
        _activeTrip!.id,
      );
      if (!mounted) return;
      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to start verification.')),
        );
        return;
      }
      setState(() {
        _activeTrip = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ready to verify customer PIN.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start verification: $error')),
      );
    }
  }

  Future<void> _onStartTrip() async {
    if (_activeTrip == null || _isStartingTrip) return;
    final bookingId = _activeTrip!.id;
    final enteredPin = _pinController.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(enteredPin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit PIN.')),
      );
      return;
    }
    setState(() => _isStartingTrip = true);
    try {
      final updated = await _firestoreService.startTripWithPin(
        bookingId: bookingId,
        enteredPin: enteredPin,
      );
      if (!mounted) return;
      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect PIN or trip cannot be started.'),
          ),
        );
        return;
      }
      _pinController.clear();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverActiveTripScreen(booking: updated),
        ),
      );
      if (!mounted) return;
      _loadDriverStats();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to start trip: $error')));
    } finally {
      if (mounted) {
        setState(() => _isStartingTrip = false);
      }
    }
  }

  Future<void> _onCancelBooking() async {
    if (_activeTrip == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: DrunkDrivePalette.of(context).surface,
          title: const Text(
            'Cancel Booking?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to cancel this booking?',
            style: TextStyle(color: DrunkDrivePalette.of(context).textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Booking'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Cancel Booking',
                style: TextStyle(color: DrunkDrivePalette.of(context).danger),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    BookingModel? cancelled;
    try {
      cancelled = await _firestoreService.cancelBookingByDriver(
        _activeTrip!.id,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to cancel booking: $error')),
      );
      return;
    }
    if (!mounted) return;
    if (cancelled == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This booking can no longer be cancelled.'),
        ),
      );
      return;
    }
    _pinController.clear();
    _loadActiveTrip();
    _loadRequests();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Booking cancelled.')));
  }

  // NOTE: in this prototype, the same mock account acts as both the  // passenger and the driver (there's only one test user). So a  // driver "accepting" a booking here may be accepting their own  // trip. This resolves naturally once there are separate real  // accounts — the accept/decline logic itself doesn't change.
  Future<void> _onAccept(BookingModel booking) async {
    try {
      final updated = await _firestoreService.acceptBookingByDriver(booking.id);
      if (!mounted) return;
      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This booking is no longer available.')),
        );
        return;
      }
      setState(() {
        _incomingRequests.removeWhere((b) => b.id == booking.id);
        _activeTrip = updated;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Booking Accepted!')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to accept booking: $error')),
      );
    }
  }

  void _onDecline(BookingModel booking) {
    // Mock-stage decline: this driver simply stops seeing it. A real  // backend would record which driver declined so it isn't shown  // to them again, without affecting other drivers.
    setState(() {
      _incomingRequests.removeWhere((b) => b.id == booking.id);
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Request declined')));
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
    if (_isOnline) {
      _loadRequests();
      _loadActiveTrip();
    } else {
      _requestsSubscription?.cancel();
      setState(() {
        _incomingRequests = [];
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'You are now ONLINE' : 'You are now OFFLINE'),
        backgroundColor: _isOnline
            ? DrunkDrivePalette.of(context).success
            : DrunkDrivePalette.of(context).surfaceBorder,
      ),
    );
  }

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DrunkDrivePalette.of(context).background,
      appBar: AppBar(
        backgroundColor: DrunkDrivePalette.of(context).background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Driver Dashboard',
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
            Icon(
              Icons.lock_person_rounded,
              color: DrunkDrivePalette.of(context).danger,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Driver Access Restricted',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your account has not been approved for Driver Mode yet. You must complete verification and receive backend approval first.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DrunkDrivePalette.of(context).textMuted,
                fontSize: 13,
                height: 1.4,
              ),
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
                backgroundColor: DrunkDrivePalette.of(context).accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'View Driver Application Status',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
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
            color: DrunkDrivePalette.of(context).surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isOnline
                  ? DrunkDrivePalette.of(context).success
                  : DrunkDrivePalette.of(context).surfaceBorder,
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
                      color: _isOnline
                          ? DrunkDrivePalette.of(context).success
                          : DrunkDrivePalette.of(context).textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: TextStyle(
                      color: _isOnline
                          ? DrunkDrivePalette.of(context).success
                          : DrunkDrivePalette.of(context).textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isOnline,
                activeTrackColor: DrunkDrivePalette.of(context).success,
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
              child: _statCard(
                'Today\'s Trips',
                _todayTrips.toString(),
                Icons.local_taxi_rounded,
                DrunkDrivePalette.of(context).accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Today\'s Earnings',
                _rs(_todayEarnings),
                Icons.payments_rounded,
                DrunkDrivePalette.of(context).success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Driver Rating',
                _driverRatingText,
                Icons.star_rounded,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Weekly Total',
                _rs(_weeklyEarnings),
                Icons.account_balance_wallet_rounded,
                Colors.cyanAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverTripHistoryScreen(),
                ),
              );
              _loadDriverStats();
            },
            icon: const Icon(Icons.history_rounded),
            label: const Text(
              'View Trip History',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: DrunkDrivePalette.of(context).accent,
              side: BorderSide(color: DrunkDrivePalette.of(context).accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_activeTrip != null) ...[
          const Text(
            'Your Current Trip',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _ActiveTripCard(
            booking: _activeTrip!,
            pinController: _pinController,
            isStarting: _isStartingTrip,
            onStartHeading: _onStartHeading,
            onDriverArrived: _onDriverArrived,
            onBeginVerification: _onBeginVerification,
            onStartTrip: _onStartTrip,
            onCancelBooking: _onCancelBooking,
            onViewActiveTrip: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DriverActiveTripScreen(booking: _activeTrip!),
                ),
              );
              _loadActiveTrip();
              _loadRequests();
              _loadDriverStats();
            },
          ),
          const SizedBox(height: 24),
        ],
        // Booking Requests Section — hidden while the driver already  // has an active trip (spec section 33).
        if (_activeTrip == null) ...[
          const Text(
            'Booking Requests',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isOnline
                ? 'Searching for customer trip requests in your area...'
                : 'Switch to ONLINE to start receiving booking requests.',
            style: TextStyle(
              color: DrunkDrivePalette.of(context).textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (_activeTrip != null)
          const SizedBox.shrink()
        else if (!_isOnline)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DrunkDrivePalette.of(context).surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                'You are currently offline.',
                style: TextStyle(
                  color: DrunkDrivePalette.of(context).textMuted,
                ),
              ),
            ),
          )
        else if (_incomingRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: DrunkDrivePalette.of(context).surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                'No pending requests near you.',
                style: TextStyle(
                  color: DrunkDrivePalette.of(context).textMuted,
                ),
              ),
            ),
          )
        else
          ..._incomingRequests.map(
            (booking) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookingRequestCard(
                booking: booking,
                onAccept: () => _onAccept(booking),
                onDecline: () => _onDecline(booking),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DrunkDrivePalette.of(context).surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: DrunkDrivePalette.of(context).textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _BookingRequestCard({
    required this.booking,
    required this.onAccept,
    required this.onDecline,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DrunkDrivePalette.of(context).surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DrunkDrivePalette.of(context).accent.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Trip Request',
                style: TextStyle(
                  color: DrunkDrivePalette.of(context).accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pickup: ${booking.pickup.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Destination: ${booking.destination.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vehicle: ${booking.vehicle.displayName} (${booking.vehicle.transmission.label})',
            style: TextStyle(
              color: DrunkDrivePalette.of(context).textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DrunkDrivePalette.of(context).danger,
                    side: BorderSide(
                      color: DrunkDrivePalette.of(context).danger,
                    ),
                  ),
                  child: const Text('DECLINE'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DrunkDrivePalette.of(context).success,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'ACCEPT',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  final BookingModel booking;
  final TextEditingController pinController;
  final bool isStarting;
  final VoidCallback onStartHeading;
  final VoidCallback onDriverArrived;
  final VoidCallback onBeginVerification;
  final VoidCallback onStartTrip;
  final VoidCallback onCancelBooking;
  final VoidCallback onViewActiveTrip;
  const _ActiveTripCard({
    required this.booking,
    required this.pinController,
    required this.isStarting,
    required this.onStartHeading,
    required this.onDriverArrived,
    required this.onBeginVerification,
    required this.onStartTrip,
    required this.onCancelBooking,
    required this.onViewActiveTrip,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DrunkDrivePalette.of(context).surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DrunkDrivePalette.of(context).success.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.status.label,
                style: TextStyle(
                  color: DrunkDrivePalette.of(context).success,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pickup: ${booking.pickup.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Destination: ${booking.destination.name}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vehicle: ${booking.vehicle.displayName} (${booking.vehicle.registrationNumber})',
            style: TextStyle(
              color: DrunkDrivePalette.of(context).textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          if (booking.status == BookingStatus.driverAssigned) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartHeading,
                icon: const Icon(Icons.directions_car_rounded),
                label: const Text(
                  'Start Heading to Customer',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDrivePalette.of(context).accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (booking.status == BookingStatus.driverArriving) ...[
            Text(
              'You are heading to the customer pickup location.',
              style: TextStyle(
                color: DrunkDrivePalette.of(context).textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDriverArrived,
                icon: const Icon(Icons.location_on_rounded),
                label: const Text(
                  "I've Arrived",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDrivePalette.of(context).accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (booking.status == BookingStatus.driverArrived) ...[
            Text(
              'You have arrived at the pickup location.',
              style: TextStyle(
                color: DrunkDrivePalette.of(context).textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onBeginVerification,
                icon: const Icon(Icons.verified_user_rounded),
                label: const Text(
                  'Verify Customer',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDrivePalette.of(context).accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else if (booking.status == BookingStatus.verification) ...[
            Text(
              'Ask the customer for their Trip PIN to start the trip.',
              style: TextStyle(
                color: DrunkDrivePalette.of(context).textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                hintStyle: TextStyle(
                  color: DrunkDrivePalette.of(context).textMuted,
                ),
                filled: true,
                fillColor: DrunkDrivePalette.of(context).background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isStarting ? null : onStartTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDrivePalette.of(context).accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isStarting
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Start Trip',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ] else if (booking.status == BookingStatus.tripStarted ||
              booking.status == BookingStatus.tripInProgress) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewActiveTrip,
                icon: const Icon(Icons.navigation_rounded),
                label: const Text(
                  'View Active Trip',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DrunkDrivePalette.of(context).accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          if (booking.status == BookingStatus.driverAssigned ||
              booking.status == BookingStatus.driverArriving ||
              booking.status == BookingStatus.driverArrived ||
              booking.status == BookingStatus.verification) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isStarting ? null : onCancelBooking,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text(
                  'Cancel Booking',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DrunkDrivePalette.of(context).danger,
                  side: BorderSide(color: DrunkDrivePalette.of(context).danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
