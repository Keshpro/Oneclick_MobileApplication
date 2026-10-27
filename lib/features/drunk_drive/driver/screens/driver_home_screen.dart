import 'dart:async';

import '../../services/booking_firestore_service.dart';

import '../../services/driver_firestore_service.dart';

import 'package:flutter/material.dart';

import '../../models/booking_model.dart';

import '../../models/booking_status.dart';

import '../../models/vehicle_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  DrunkDrivePalette get colors => DrunkDrivePalette.of(context);

  Color get onAccent =>
      ThemeData.estimateBrightnessForColor(colors.accent) == Brightness.dark
      ? Colors.white
      : Colors.black;

  final BookingFirestoreService _firestoreService = BookingFirestoreService();

  StreamSubscription<List<BookingModel>>? _requestsSubscription;

  StreamSubscription<BookingModel?>? _activeTripSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _paymentsSubscription;

  final DriverRatingService _driverRatingService = DriverRatingService();

  bool _isOnline = false;

  bool _isApproved = false;

  List<BookingModel> _incomingRequests = [];
  Set<String> _declinedBookingIds = {};

  BookingModel? _activeTrip;

  final TextEditingController _pinController = TextEditingController();

  bool _isStartingTrip = false;

  int _todayTrips = 0;

  double _todayEarnings = 0;

  double _weeklyEarnings = 0;

  double _pendingCash = 0;
  double _unpaidPayments = 0;
  double _simulatedPayments = 0;
  double _confirmedPayments = 0;

  @override
  void initState() {
    super.initState();

    _checkAuthorization();
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();

    _activeTripSubscription?.cancel();

    _paymentsSubscription?.cancel();

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
        final driverService = DriverFirestoreService();

        final savedOnlineStatus = await driverService.getMyOnlineStatus();

        final declinedIds = await driverService.getMyDeclinedBookingIds();

        if (!mounted) return;

        setState(() {
          _isOnline = savedOnlineStatus;
          _declinedBookingIds = declinedIds;
        });

        if (_isOnline) {
          _loadRequests();
        }

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
          _incomingRequests = requests.where((booking) {
            return !_declinedBookingIds.contains(booking.id);
          }).toList();
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

  Widget _buildDriverRatingCard() {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      return _statCard('Driver Rating', 'Sign in required',
          Icons.star_rounded, Colors.amber);
    }

    return StreamBuilder(
      stream: _driverRatingService.watchRatingsForDriver(driverId),
      builder: (context, snapshot) {
        String text;
        if (snapshot.hasError) {
          text = 'Unable to load';
        } else if (!snapshot.hasData) {
          text = 'Loading...';
        } else {
          final ratings = snapshot.data!;
          if (ratings.isEmpty) {
            text = 'No ratings';
          } else {
            final total = ratings.fold<int>(
              0,
              (sum, item) => sum + item.rating,
            );
            final average = total / ratings.length;
            text = '${average.toStringAsFixed(1)} ★ (${ratings.length})';
          }
        }
        return _statCard('Driver Rating', text,
            Icons.star_rounded, Colors.amber);
      },
    );
  }

  // Listen to all bookings assigned to this driver. Payment changes can occur
  // after a trip ends, so a one-time completed-trip fetch is not sufficient.
  void _loadDriverStats() {
    _paymentsSubscription?.cancel();
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) return;

    _paymentsSubscription = FirebaseFirestore.instance
        .collection('drunkDriveBookings')
        .where('driverId', isEqualTo: driverId)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;
          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);
          final startOfWeek = startOfToday.subtract(
            Duration(days: now.weekday - 1),
          );

          int todayTrips = 0;
          double todayEarnings = 0;
          double weeklyEarnings = 0;
          double confirmed = 0;
          double pending = 0;
          double unpaid = 0;
          double simulated = 0;

          for (final document in snapshot.docs) {
            final booking = BookingModel.fromMap(document.id, document.data());
            if (booking.status != BookingStatus.completed) continue;

            final amount = booking.customerAmountDue;
            final completedAt = booking.completedAt;
            final completedToday = completedAt != null &&
                !completedAt.isBefore(startOfToday);
            final completedThisWeek = completedAt != null &&
                !completedAt.isBefore(startOfWeek);

            if (completedToday) todayTrips++;

            switch (booking.paymentStatus) {
              case 'paid':
                confirmed += amount;
                if (completedToday) todayEarnings += amount;
                if (completedThisWeek) weeklyEarnings += amount;
                break;
              case 'pending':
                pending += amount;
                break;
              case 'simulated':
                simulated += amount;
                break;
              default:
                unpaid += amount;
            }
          }

          setState(() {
            _todayTrips = todayTrips;
            _todayEarnings = todayEarnings;
            _weeklyEarnings = weeklyEarnings;
            _confirmedPayments = confirmed;
            _pendingCash = pending;
            _unpaidPayments = unpaid;
            _simulatedPayments = simulated;
          });
        }, onError: (Object error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to load payment summary: $error')),
          );
        });
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
          SnackBar(content: Text('Unable to start heading to customer.')),
        );

        return;
      }

      setState(() {
        _activeTrip = updated;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Heading to customer.')));
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
          SnackBar(content: Text('Unable to mark driver as arrived.')),
        );

        return;
      }

      setState(() {
        _activeTrip = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have arrived at the customer.')),
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
          SnackBar(content: Text('Unable to start verification.')),
        );

        return;
      }

      setState(() {
        _activeTrip = updated;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ready to verify customer PIN.')));
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
        SnackBar(content: Text('Please enter a valid 4-digit PIN.')),
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
          SnackBar(content: Text('Incorrect PIN or trip cannot be started.')),
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
          backgroundColor: colors.surface,

          title: Text(
            'Cancel Booking?',

            style: TextStyle(color: colors.textPrimary),
          ),

          content: Text(
            'Are you sure you want to cancel this booking?',

            style: TextStyle(color: colors.textMuted),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),

              child: Text('Keep Booking'),
            ),

            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),

              child: Text(
                'Cancel Booking',

                style: TextStyle(color: colors.danger),
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
        SnackBar(content: Text('This booking can no longer be cancelled.')),
      );

      return;
    }

    _pinController.clear();

    _loadActiveTrip();

    _loadRequests();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Booking cancelled.')));
  }

  Future<void> _onAccept(BookingModel booking) async {
    try {
      final updated = await _firestoreService.acceptBookingByDriver(booking.id);

      if (!mounted) return;

      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This booking is no longer available.')),
        );

        return;
      }

      setState(() {
        _incomingRequests.removeWhere((b) => b.id == booking.id);

        _activeTrip = updated;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Booking Accepted!')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to accept booking: $error')),
      );
    }
  }

  Future<void> _onDecline(BookingModel booking) async {
    try {
      await DriverFirestoreService().declineBooking(booking.id);

      if (!mounted) return;

      setState(() {
        _declinedBookingIds.add(booking.id);

        _incomingRequests.removeWhere((request) => request.id == booking.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request declined successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to decline booking: $error')),
      );
    }
  }

  bool _isUpdatingOnlineStatus = false;

  Future<void> _toggleOnline(bool value) async {
    if (_isUpdatingOnlineStatus) return;

    if (!_isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only approved drivers can go online.')),
      );
      return;
    }

    setState(() {
      _isUpdatingOnlineStatus = true;
    });

    try {
      await DriverFirestoreService().setMyOnlineStatus(value);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(
            'Firebase UID: ${DriverFirestoreService().currentUserId}',
          ),
        ),
      );
      debugPrint(
        'Driver Firebase UID: ${DriverFirestoreService().currentUserId}',
      );

      if (!mounted) return;

      setState(() {
        _isOnline = value;
      });
      debugPrint(
        'Driver Firebase UID: ${DriverFirestoreService().currentUserId}',
      );
      if (value) {
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
          content: Text(value ? 'You are now ONLINE' : 'You are now OFFLINE'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save driver availability: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingOnlineStatus = false;
        });
      }
    }
  }

  String _rs(double amount) => 'Rs. ${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,

      appBar: AppBar(
        backgroundColor: colors.background,

        elevation: 0,

        iconTheme: IconThemeData(color: colors.textPrimary),

        title: Text(
          'Driver Mode',

          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
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
            Icon(Icons.lock_person_rounded, color: colors.danger, size: 56),

            const SizedBox(height: 16),

            Text(
              'Driver Mode Restricted',

              style: TextStyle(
                color: colors.textPrimary,

                fontWeight: FontWeight.w800,

                fontSize: 20,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Your account has not been approved for Driver Mode yet. You must complete verification and receive backend approval first.',

              textAlign: TextAlign.center,

              style: TextStyle(
                color: colors.textMuted,

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
                backgroundColor: colors.accent,

                foregroundColor: onAccent,

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,

                  vertical: 14,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              child: Text(
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
            color: colors.surface,

            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: _isOnline ? colors.success : colors.surfaceBorder,

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
                      color: _isOnline ? colors.success : colors.textMuted,

                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',

                    style: TextStyle(
                      color: _isOnline ? colors.success : colors.textMuted,

                      fontWeight: FontWeight.w800,

                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              Switch(
                value: _isOnline,

                activeTrackColor: colors.success,

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
                "Today's Trips",

                _todayTrips.toString(),

                Icons.local_taxi_rounded,

                colors.accent,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _statCard(
                "Today's Confirmed",

                _rs(_todayEarnings),

                Icons.payments_rounded,

                colors.success,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildDriverRatingCard(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _statCard(
                'Weekly Confirmed',

                _rs(_weeklyEarnings),

                Icons.account_balance_wallet_rounded,

                Colors.cyanAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        _buildPaymentSummary(),

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

            label: Text(
              'View Trip History',

              style: TextStyle(fontWeight: FontWeight.w800),
            ),

            style: OutlinedButton.styleFrom(
              foregroundColor: colors.accent,

              side: BorderSide(color: colors.accent),

              padding: const EdgeInsets.symmetric(vertical: 14),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        if (_activeTrip != null) ...[
          Text(
            'Your Current Trip',

            style: TextStyle(
              color: colors.textPrimary,

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

        // Booking Requests Section — hidden while the driver already

        // has an active trip (spec section 33).
        if (_activeTrip == null) ...[
          Text(
            'Booking Requests',

            style: TextStyle(
              color: colors.textPrimary,

              fontWeight: FontWeight.w800,

              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _isOnline
                ? 'Searching for customer trip requests in your area...'
                : 'Switch to ONLINE to start receiving booking requests.',

            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),

          const SizedBox(height: 14),
        ],

        if (_activeTrip != null)
          const SizedBox.shrink()
        else if (!_isOnline)
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: colors.surface,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Center(
              child: Text(
                'You are currently offline.',

                style: TextStyle(color: colors.textMuted),
              ),
            ),
          )
        else if (_incomingRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: colors.surface,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Center(
              child: Text(
                'No pending requests near you.',

                style: TextStyle(color: colors.textMuted),
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

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All completed trips • amounts in LKR',
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          _paymentRow('Confirmed cash received', _confirmedPayments,
              Icons.check_circle_outline, colors.success),
          const SizedBox(height: 12),
          _paymentRow('Cash awaiting confirmation', _pendingCash,
              Icons.hourglass_empty_rounded, colors.accent),
          const SizedBox(height: 12),
          _paymentRow('Unpaid', _unpaidPayments,
              Icons.pending_actions_rounded, colors.danger),
          const SizedBox(height: 12),
          _paymentRow('Simulated card payments', _simulatedPayments,
              Icons.credit_card_rounded, colors.textMuted),
          const SizedBox(height: 12),
          Text(
            'Card payments are simulations and are not counted as real earnings. '
            'Daily and weekly earnings reflect confirmed payments for trips '
            'completed in those periods.',
            style: TextStyle(color: colors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(
    String label,
    double amount,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: colors.textPrimary, fontSize: 12),
          ),
        ),
        Text(
          _rs(amount),
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(height: 10),

          Text(
            value,

            style: TextStyle(
              color: colors.textPrimary,

              fontWeight: FontWeight.w800,

              fontSize: 18,
            ),
          ),

          const SizedBox(height: 2),

          Text(label, style: TextStyle(color: colors.textMuted, fontSize: 11)),
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
    final colors = DrunkDrivePalette.of(context);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: colors.accent.withValues(alpha: 0.5)),
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
                  color: colors.accent,

                  fontWeight: FontWeight.w800,

                  fontSize: 14,
                ),
              ),

              Text(
                'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',

                style: TextStyle(
                  color: colors.textPrimary,

                  fontWeight: FontWeight.w800,

                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Pickup: ${booking.pickup.name}',

            style: TextStyle(
              color: colors.textPrimary,

              fontSize: 13,

              fontWeight: FontWeight.w600,
            ),
          ),

          Text(
            'Destination: ${booking.destination.name}',

            style: TextStyle(
              color: colors.textPrimary,

              fontSize: 13,

              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Vehicle: ${booking.vehicle.displayName} (${booking.vehicle.transmission.label})',

            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,

                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,

                    side: BorderSide(color: colors.danger),
                  ),

                  child: Text('DECLINE'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,

                    foregroundColor: colors.textPrimary,
                  ),

                  child: Text(
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
    final colors = DrunkDrivePalette.of(context);
    final onAccent =
        ThemeData.estimateBrightnessForColor(colors.accent) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colors.surface,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: colors.success.withValues(alpha: 0.6)),
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
                  color: colors.success,

                  fontWeight: FontWeight.w800,

                  fontSize: 14,
                ),
              ),

              Text(
                'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',

                style: TextStyle(
                  color: colors.textPrimary,

                  fontWeight: FontWeight.w800,

                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Pickup: ${booking.pickup.name}',

            style: TextStyle(
              color: colors.textPrimary,

              fontSize: 13,

              fontWeight: FontWeight.w600,
            ),
          ),

          Text(
            'Destination: ${booking.destination.name}',

            style: TextStyle(
              color: colors.textPrimary,

              fontSize: 13,

              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Vehicle: ${booking.vehicle.displayName} (${booking.vehicle.registrationNumber})',

            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),

          const SizedBox(height: 16),

          if (booking.status == BookingStatus.driverAssigned) ...[
            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: onStartHeading,

                icon: const Icon(Icons.directions_car_rounded),

                label: Text(
                  'Start Heading to Customer',

                  style: TextStyle(fontWeight: FontWeight.w800),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,

                  foregroundColor: onAccent,

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

              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: onDriverArrived,

                icon: const Icon(Icons.location_on_rounded),

                label: Text(
                  "I've Arrived",

                  style: TextStyle(fontWeight: FontWeight.w800),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,

                  foregroundColor: onAccent,

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

              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: onBeginVerification,

                icon: const Icon(Icons.verified_user_rounded),

                label: Text(
                  'Verify Customer',

                  style: TextStyle(fontWeight: FontWeight.w800),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,

                  foregroundColor: onAccent,

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

              style: TextStyle(color: colors.textMuted, fontSize: 12),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: pinController,

              keyboardType: TextInputType.number,

              maxLength: 4,

              style: TextStyle(
                color: colors.textPrimary,

                fontSize: 18,

                letterSpacing: 4,
              ),

              decoration: InputDecoration(
                counterText: '',

                hintText: '••••',

                hintStyle: TextStyle(color: colors.textMuted),

                filled: true,

                fillColor: colors.background,

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
                  backgroundColor: colors.accent,

                  foregroundColor: onAccent,

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

                          color: colors.background,
                        ),
                      )
                    : Text(
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

                label: Text(
                  'View Active Trip',

                  style: TextStyle(fontWeight: FontWeight.w800),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,

                  foregroundColor: onAccent,

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

                label: Text(
                  'Cancel Booking',

                  style: TextStyle(fontWeight: FontWeight.w800),
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.danger,

                  side: BorderSide(color: colors.danger),

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
