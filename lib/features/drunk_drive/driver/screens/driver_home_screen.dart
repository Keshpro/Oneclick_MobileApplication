import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../services/booking_policy.dart';
import '../../services/gps_policy.dart';
import '../../services/driver_trip_location_service.dart';
import '../../models/driver_application_model.dart';
import '../../models/driver_rating_model.dart';
import '../../passenger/widgets/cancellation_reason_dialog.dart';

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
import '../../passenger/screens/drunk_drive_home_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final bool fromPassengerMode;
  final VoidCallback? onSwitchToPassenger;

  const DriverHomeScreen({
    super.key,
    this.fromPassengerMode = false,
    this.onSwitchToPassenger,
  });

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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _paymentsSubscription;

  final DriverRatingService _driverRatingService = DriverRatingService();
  Stream<List<DriverRatingModel>>? _ratingsStream;

  bool _isOnline = false;

  bool _isApproved = false;
  bool _isCheckingAuthorization = true;
  bool _authorizationCheckFailed = false;

  List<BookingModel> _incomingRequests = [];
  final DriverTripLocationService _pickupTracking = DriverTripLocationService();
  bool _pickupTrackingBusy = false;
  bool _pickupSharing = false;
  Future<void> _togglePickupTracking() async {
    if (_pickupTrackingBusy ||
        _activeTrip?.status != BookingStatus.driverArriving) {
      return;
    }
    final id = _activeTrip!.id;
    setState(() => _pickupTrackingBusy = true);
    try {
      if (_pickupSharing) {
        await _pickupTracking.stop();
      } else {
        await _pickupTracking.start(id);
      }
      if (mounted &&
          _activeTrip?.status == BookingStatus.driverArriving &&
          _activeTrip?.id == id) {
        setState(() => _pickupSharing = _pickupTracking.isSharing);
      } else {
        await _pickupTracking.stop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to share pickup location. Check GPS and permissions.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pickupTrackingBusy = false);
    }
  }

  Position? _requestPosition;
  StreamSubscription<Position>? _requestLocationSubscription;
  StreamSubscription<DriverApplicationModel?>? _approvalSubscription;
  Timer? _requestRefreshTimer;
  DriverApplicationModel? _driverApplication;
  bool _locationLoading = false;
  String? _requestLocationError;
  String? _requestFeedError;
  bool _refreshingGps = false;
  int _gpsGeneration = 0;

  bool get _canReceiveRequests =>
      mounted && _isApproved && _isOnline && _activeTrip == null;

  double? _pickupDistance(BookingModel booking) =>
      GpsPolicy.pickupDistanceMeters(_requestPosition, booking.pickup);

  bool _isCompatible(BookingModel booking) {
    final application = _driverApplication;
    return application != null &&
        BookingPolicy.compatible(
          booking,
          manual: application.canDriveManual,
          automatic: application.canDriveAutomatic,
        );
  }

  String get _emptyRequestMessage {
    final current = _incomingRequests
        .where((b) => !BookingPolicy.searchExpired(b))
        .toList();
    if (current.isEmpty) {
      return 'No new requests available. Book a fresh ride from a different passenger account.';
    }
    final compatible = current.where(_isCompatible).toList();
    if (compatible.isEmpty) {
      return 'Requests are available, but none match your registered vehicle transmission skills.';
    }
    final withCoordinates = compatible
        .where((b) => _pickupDistance(b) != null)
        .toList();
    if (withCoordinates.isEmpty) {
      return 'Requests have no valid pickup coordinates. Ask the passenger to select a new map pin.';
    }
    return '${withCoordinates.length} compatible request(s) outside the 15 km pickup radius.';
  }

  void _stopRequestGps() {
    _gpsGeneration++;
    _requestLocationSubscription?.cancel();
    _requestLocationSubscription = null;
    _requestRefreshTimer?.cancel();
    _requestRefreshTimer = null;
    _requestPosition = null;
    _requestLocationError = null;
    _locationLoading = false;
    _refreshingGps = false;
  }

  final Set<String> _notifiedRequestIds = <String>{};
  List<BookingModel> get _nearbyRequests {
    final application = _driverApplication;
    if (!_canReceiveRequests ||
        !GpsPolicy.usable(_requestPosition) ||
        application == null ||
        !BookingPolicy.licenceValid(application.licenceExpiry)) {
      return [];
    }
    final result = _incomingRequests
        .where(
          (booking) =>
              !BookingPolicy.searchExpired(booking) &&
              _isCompatible(booking) &&
              GpsPolicy.withinPickupRadius(_requestPosition, booking.pickup),
        )
        .toList();
    result.sort((a, b) => _pickupDistance(a)!.compareTo(_pickupDistance(b)!));
    return result;
  }

  Set<String> _declinedBookingIds = {};

  BookingModel? _activeTrip;

  final TextEditingController _pinController = TextEditingController();

  bool _isStartingTrip = false;

  // Prevent duplicate request actions while a Firestore write is pending.
  final Set<String> _pendingRequestIds = <String>{};
  bool _isAcceptingRequest = false;

  int _todayTrips = 0;

  double _todayEarnings = 0;

  double _weeklyEarnings = 0;
  double _monthlyEarnings = 0;

  double _pendingCash = 0;
  double _unpaidPayments = 0;
  double _simulatedPayments = 0;
  double _confirmedPayments = 0;
  List<BookingModel> _awaitingPayment = [];

  @override
  void initState() {
    super.initState();

    _pickupTracking.onError = (_) async {
      if (mounted) setState(() => _pickupSharing = false);
    };
    _checkAuthorization();
  }

  @override
  void dispose() {
    _requestsSubscription?.cancel();
    _stopRequestGps();
    _pickupTracking.onError = null;
    unawaited(_pickupTracking.stop().catchError((Object _) {}));
    _approvalSubscription?.cancel();
    _requestRefreshTimer?.cancel();

    _activeTripSubscription?.cancel();

    _paymentsSubscription?.cancel();

    _pinController.dispose();

    super.dispose();
  }

  Future<void> _checkAuthorization() async {
    if (!mounted) return;
    setState(() {
      _isCheckingAuthorization = true;
      _authorizationCheckFailed = false;
    });
    try {
      final application = await DriverFirestoreService().getMyApplication();
      final isApproved =
          application?.status == DriverApplicationStatus.approved;
      _driverApplication = application;
      debugPrint('[DD_ROUTE_V3] driver dashboard approved=$isApproved');

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
      _approvalSubscription?.cancel();
      _approvalSubscription = DriverFirestoreService()
          .watchMyApplication()
          .listen(
            (application) {
              if (!mounted) return;
              final approved =
                  application?.status == DriverApplicationStatus.approved;
              final changed = approved != _isApproved;
              setState(() {
                _driverApplication = application;
                _isApproved = approved;
              });
              if (changed && approved) {
                unawaited(_checkAuthorization());
              }
              if (!approved) {
                _requestsSubscription?.cancel();
                _requestsSubscription = null;
                _stopRequestGps();
                unawaited(_pickupTracking.stop().catchError((Object _) {}));
                _pickupSharing = false;
                _activeTripSubscription?.cancel();
                _paymentsSubscription?.cancel();
                setState(() {
                  _isOnline = false;
                  _incomingRequests = [];
                  _requestPosition = null;
                });
              }
            },
            onError: (Object _) {
              if (mounted) setState(() => _authorizationCheckFailed = true);
            },
          );
    } catch (error) {
      debugPrint('[DD_ROUTE_V3] driver authorization error=$error');
      if (!mounted) return;
      setState(() => _authorizationCheckFailed = true);
    } finally {
      if (mounted) {
        setState(() => _isCheckingAuthorization = false);
      }
    }
  }

  void _applyRequestPosition(Position position) {
    if (!_canReceiveRequests) return;
    if (!GpsPolicy.usable(position)) {
      if (!GpsPolicy.usable(_requestPosition)) {
        setState(() {
          _requestPosition = null;
          _requestLocationError = 'GPS accuracy is too low or the position is outdated. Enable precise location and retry.';
        });
      }
      return;
    }
    setState(() {
      _requestPosition = position;
      _requestLocationError = null;
    });
    _notifyNearbyRequests();
  }

  void _notifyNearbyRequests() {
    if (!_canReceiveRequests) return;
    final newNearby = _nearbyRequests
        .where((booking) => _notifiedRequestIds.add(booking.id))
        .length;
    if (newNearby > 0 && ModalRoute.of(context)?.isCurrent == true) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            newNearby == 1
                ? 'New nearby trip request'
                : '$newNearby nearby trip requests',
          ),
        ),
      );
    }
  }

  Future<void> _refreshRequestGps() async {
    if (!_canReceiveRequests || _refreshingGps || _locationLoading) return;
    final generation = _gpsGeneration;
    _refreshingGps = true;
    try {
      final position = await GpsPolicy.currentPosition();
      if (!_canReceiveRequests || generation != _gpsGeneration) return;
      _applyRequestPosition(position);
    } catch (error) {
      if (!_canReceiveRequests || generation != _gpsGeneration) return;
      if (!GpsPolicy.usable(_requestPosition) || error is StateError) {
        setState(() {
          _requestPosition = null;
          _requestLocationError = error is StateError
              ? error.message
              : 'GPS unavailable. Refresh your location.';
        });
      }
    } finally {
      if (generation == _gpsGeneration) _refreshingGps = false;
    }
  }

  Future<void> _startRequestLocation() async {
    if (_locationLoading || !_canReceiveRequests) return;
    final generation = ++_gpsGeneration;
    _refreshingGps = false;
    setState(() {
      _locationLoading = true;
      _requestLocationError = null;
      _requestPosition = null;
    });
    try {
      await _requestLocationSubscription?.cancel();
      _requestLocationSubscription = null;
      _requestRefreshTimer?.cancel();
      final position = await GpsPolicy.currentPosition();
      if (!_canReceiveRequests || generation != _gpsGeneration) return;
      _applyRequestPosition(position);
      _requestLocationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
            ),
          ).listen(
            (position) {
              if (_canReceiveRequests && generation == _gpsGeneration) {
                _applyRequestPosition(position);
              }
            },
            onError: (Object _) {
              if (_canReceiveRequests && generation == _gpsGeneration) {
                setState(() {
                  _requestPosition = null;
                  _requestLocationError =
                      'GPS stream unavailable. Enable location and retry.';
                });
              }
            },
          );
      _requestRefreshTimer = Timer.periodic(const Duration(seconds: 10), (
        timer,
      ) {
        if (!_canReceiveRequests || generation != _gpsGeneration) return;
        setState(() {}); // Refresh request expiry and GPS freshness.
        if (timer.tick % 3 == 0) unawaited(_refreshRequestGps());
      });
    } catch (error) {
      if (_canReceiveRequests && generation == _gpsGeneration) {
        setState(() {
          _requestPosition = null;
          _requestLocationError = error is StateError
              ? error.message
              : 'Unable to get GPS. Enable precise location and retry.';
        });
      }
    } finally {
      if (mounted && generation == _gpsGeneration) {
        setState(() => _locationLoading = false);
      }
    }
  }

  void _loadRequests() {
    _requestsSubscription?.cancel();
    _requestsSubscription = null;
    if (!_canReceiveRequests) return;
    if (!GpsPolicy.usable(_requestPosition) && !_locationLoading) {
      unawaited(_startRequestLocation());
    }
    setState(() => _requestFeedError = null);
    _requestsSubscription = _firestoreService.watchAvailableRequests().listen(
      (requests) {
        if (!_canReceiveRequests) return;
        setState(() {
          _requestFeedError = null;
          _incomingRequests = requests
              .where((booking) => !_declinedBookingIds.contains(booking.id))
              .toList();
        });
        _notifyNearbyRequests();
      },
      onError: (Object error) {
        if (!_canReceiveRequests) return;
        final message =
            error is FirebaseException && error.code == 'permission-denied'
            ? 'Firestore denied access to available requests. Check the driver booking read rules.'
            : 'Unable to load booking requests. Check the connection and retry.';
        setState(() {
          _incomingRequests = [];
          _requestFeedError = message;
        });
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

            final hadTrip = _activeTrip != null;
            if (booking?.status != BookingStatus.driverArriving &&
                _pickupTracking.isSharing) {
              unawaited(_pickupTracking.stop().catchError((Object _) {}));
              _pickupSharing = false;
            }
            setState(() {
              _activeTrip = booking;
            });
            if (booking != null) {
              _requestsSubscription?.cancel();
              _requestsSubscription = null;
              _stopRequestGps();
            } else if (hadTrip && _isOnline) {
              _loadRequests();
            }
          },

          onError: (_) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unable to load your active trip. Please try again.',
                ),
              ),
            );
          },
        );
  }

  Widget _buildDriverRatingCard() {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      return _statCard(
        'Driver Rating',
        'Sign in required',
        Icons.star_rounded,
        Colors.amber,
      );
    }

    return StreamBuilder<List<DriverRatingModel>>(
      stream: _ratingsStream ??= _driverRatingService.watchRatingsForDriver(
        driverId,
      ),
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
              (total, item) => total + item.rating,
            );
            final average = total / ratings.length;
            text = '${average.toStringAsFixed(1)} ★ (${ratings.length})';
          }
        }
        return _statCard(
          'Driver Rating',
          text,
          Icons.star_rounded,
          Colors.amber,
        );
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
        .listen(
          (snapshot) {
            if (!mounted) return;
            final now = DateTime.now();
            final startOfToday = DateTime(now.year, now.month, now.day);
            final startOfWeek = startOfToday.subtract(
              Duration(days: now.weekday - 1),
            );

            int todayTrips = 0;
            double todayEarnings = 0;
            double weeklyEarnings = 0;
            double monthlyEarnings = 0;
            final startOfMonth = DateTime(now.year, now.month);
            double confirmed = 0;
            double pending = 0;
            double unpaid = 0;
            double simulated = 0;
            final awaitingPayment = <BookingModel>[];

            for (final document in snapshot.docs) {
              final booking = BookingModel.fromMap(
                document.id,
                document.data(),
              );
              if (booking.status != BookingStatus.completed) continue;

              if (booking.paymentStatus == 'unpaid' ||
                  booking.paymentStatus == 'pending') {
                awaitingPayment.add(booking);
              }
              final amount = booking.customerAmountDue;
              final completedAt = booking.completedAt;
              final completedToday =
                  completedAt != null && !completedAt.isBefore(startOfToday);
              final completedThisWeek =
                  completedAt != null && !completedAt.isBefore(startOfWeek);

              if (completedToday) todayTrips++;

              switch (booking.paymentStatus) {
                case 'paid':
                  confirmed += amount;
                  if (completedToday) todayEarnings += amount;
                  if (completedThisWeek) weeklyEarnings += amount;
                  if (completedAt != null &&
                      !completedAt.isBefore(startOfMonth)) {
                    monthlyEarnings += amount;
                  }
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

            awaitingPayment.sort(
              (a, b) => (b.completedAt ?? b.createdAt).compareTo(
                a.completedAt ?? a.createdAt,
              ),
            );
            setState(() {
              _awaitingPayment = awaitingPayment;
              _todayTrips = todayTrips;
              _todayEarnings = todayEarnings;
              _weeklyEarnings = weeklyEarnings;
              _monthlyEarnings = monthlyEarnings;
              _confirmedPayments = confirmed;
              _pendingCash = pending;
              _unpaidPayments = unpaid;
              _simulatedPayments = simulated;
            });
          },
          onError: (Object _) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unable to load your payment summary right now.'),
              ),
            );
          },
        );
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update your trip. Please try again.'),
        ),
      );
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to confirm arrival. Please try again.')),
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to start verification. Please try again.'),
        ),
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
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to start the trip. Please try again.')),
      );
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

    if (confirmed != true || !mounted || _activeTrip == null) return;
    final bookingId = _activeTrip!.id;
    final reason = await chooseCancellationReason(context, driver: true);
    if (reason == null || !mounted || _activeTrip?.id != bookingId) return;

    BookingModel? cancelled;

    try {
      cancelled = await _firestoreService.cancelBookingByDriver(
        bookingId,
        reason: reason,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to cancel this booking. Please try again.'),
        ),
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
    if (!_nearbyRequests.any((b) => b.id == booking.id) ||
        _isAcceptingRequest ||
        _pendingRequestIds.contains(booking.id) ||
        _activeTrip != null) {
      return;
    }

    setState(() {
      _isAcceptingRequest = true;
      _pendingRequestIds.add(booking.id);
    });
    try {
      final position = await GpsPolicy.currentPosition();
      if (!mounted || !_canReceiveRequests) return;
      _applyRequestPosition(position);
      if (!GpsPolicy.withinPickupRadius(position, booking.pickup)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot accept: pickup is outside 15 km or GPS is inaccurate. Refresh location.',
            ),
          ),
        );
        return;
      }
      final updated = await _firestoreService.acceptBookingByDriver(
        booking.id,
        driverPosition: position,
      );
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
          .showSnackBar(const SnackBar(content: Text('Booking accepted!')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to accept this booking. It may already have been assigned. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAcceptingRequest = false;
          _pendingRequestIds.remove(booking.id);
        });
      }
    }
  }

  Future<void> _onDecline(BookingModel booking) async {
    if (_isAcceptingRequest ||
        _pendingRequestIds.contains(booking.id) ||
        _activeTrip != null) {
      return;
    }

    setState(() => _pendingRequestIds.add(booking.id));
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to decline this request. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _pendingRequestIds.remove(booking.id));
      }
    }
  }

  bool _isUpdatingOnlineStatus = false;

  Future<void> _toggleOnline(bool value) async {
    if (_isUpdatingOnlineStatus) return;

    if (!_isApproved ||
        (value &&
            !BookingPolicy.licenceValid(
              _driverApplication?.licenceExpiry ?? '',
            ))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Only approved drivers with a valid licence can go online.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isUpdatingOnlineStatus = true;
    });

    try {
      await DriverFirestoreService().setMyOnlineStatus(value);
      if (!mounted) return;

      setState(() {
        _isOnline = value;
      });
      if (value) {
        _loadRequests();
        _loadActiveTrip();
      } else {
        _requestsSubscription?.cancel();
        _requestsSubscription = null;
        _stopRequestGps();

        setState(() {
          _requestPosition = null;
          _incomingRequests = [];
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'You are now ONLINE' : 'You are now OFFLINE'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to change your availability. Check your connection and try again.',
          ),
        ),
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

        leading: !Navigator.canPop(context)
            ? IconButton(
                tooltip: 'OneClick Home',
                icon: const Icon(Icons.home_outlined),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
              )
            : null,
        title: Text(
          'Driver Mode',

          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                final switchToPassenger = widget.onSwitchToPassenger;
                if (switchToPassenger != null) {
                  switchToPassenger();
                  return;
                }
                final navigator = Navigator.of(context);
                if (widget.fromPassengerMode && navigator.canPop()) {
                  navigator.pop();
                } else {
                  navigator.pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const DrunkDriveHomeScreen(
                        startInPassengerMode: true,
                        preferDriverMode: true,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.swap_horiz_rounded, size: 19),
              label: const Text('Passenger'),
              style: TextButton.styleFrom(
                foregroundColor: colors.accent,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: _isCheckingAuthorization
            ? Center(child: CircularProgressIndicator(color: colors.accent))
            : _authorizationCheckFailed
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Unable to load your driver dashboard. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _checkAuthorization,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            : !_isApproved
            ? _buildNotApprovedView()
            : _buildDriverDashboard(),
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

  Widget _buildAwaitingPaymentCard(BookingModel booking) {
    final cashSelected =
        booking.paymentStatus == 'pending' && booking.paymentMethod == 'cash';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip completed • Amount due',
            style: TextStyle(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _rs(booking.customerAmountDue),
            style: TextStyle(
              color: colors.accent,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.pickup.name} → ${booking.destination.name}',
            style: TextStyle(color: colors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            cashSelected
                ? 'Cash selected. Confirm only after receiving payment.'
                : 'Waiting for passenger to select payment method.',
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => DriverActiveTripScreen(booking: booking),
                  ),
                );
              },
              icon: const Icon(Icons.payments_outlined),
              label: const Text('View Payment'),
            ),
          ),
        ],
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

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isUpdatingOnlineStatus) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Switch(
                    value: _isOnline,
                    activeTrackColor: colors.success,
                    onChanged: _isUpdatingOnlineStatus ? null : _toggleOnline,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        if (_awaitingPayment.isNotEmpty) ...[
          Text(
            'Payments to Collect',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ..._awaitingPayment.map(_buildAwaitingPaymentCard),
          const SizedBox(height: 12),
        ],
        if (_activeTrip != null) ...[
          if (_activeTrip!.status == BookingStatus.driverArriving) ...[
            OutlinedButton.icon(
              onPressed: _pickupTrackingBusy ? null : _togglePickupTracking,
              icon: const Icon(Icons.my_location),
              label: Text(
                _pickupSharing
                    ? 'Stop sharing pickup location'
                    : 'Share pickup location with passenger',
              ),
            ),
            const SizedBox(height: 12),
          ],
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

              if (!mounted) return;
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
                ? 'Waiting for new customer booking requests...'
                : 'Switch to ONLINE to start receiving booking requests.',

            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),

          if (_isOnline) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  GpsPolicy.usable(_requestPosition)
                      ? 'GPS ±${_requestPosition!.accuracy.toStringAsFixed(0)} m${_requestPosition!.isMocked ? ' (simulated)' : ''}'
                      : 'Waiting for accurate GPS',
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
                TextButton.icon(
                  onPressed: _locationLoading ? null : _startRequestLocation,
                  icon: const Icon(Icons.my_location, size: 18),
                  label: const Text('Refresh GPS'),
                ),
                TextButton.icon(
                  onPressed: _loadRequests,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh requests'),
                ),
              ],
            ),
          ],
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
        else if (_locationLoading)
          const Center(child: CircularProgressIndicator())
        else if (_requestFeedError != null)
          Column(
            children: [
              Text(_requestFeedError!, style: TextStyle(color: colors.danger)),
              TextButton(
                onPressed: _loadRequests,
                child: const Text('Retry requests'),
              ),
            ],
          )
        else if (_requestLocationError != null ||
            !GpsPolicy.usable(_requestPosition))
          Column(
            children: [
              Text(
                _requestLocationError ??
                    'GPS is outdated. Refresh your location.',
                style: TextStyle(color: colors.textMuted),
              ),
              TextButton(
                onPressed: _startRequestLocation,
                child: const Text('Retry location'),
              ),
            ],
          )
        else if (!BookingPolicy.licenceValid(
          _driverApplication?.licenceExpiry ?? '',
        ))
          const Text(
            'Your licence has expired or needs correction. Contact admin.',
          )
        else if (_nearbyRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: colors.surface,

              borderRadius: BorderRadius.circular(18),
            ),

            child: Center(
              child: Text(
                _emptyRequestMessage,

                style: TextStyle(color: colors.textMuted),
              ),
            ),
          )
        else
          ..._nearbyRequests.map(
            (booking) => Padding(
              padding: const EdgeInsets.only(bottom: 12),

              child: _BookingRequestCard(
                booking: booking,
                pickupDistanceKm: _pickupDistance(booking)! / 1000,
                isProcessing: _pendingRequestIds.contains(booking.id),
                actionsDisabled:
                    _isAcceptingRequest ||
                    _pendingRequestIds.contains(booking.id),

                onAccept: () => _onAccept(booking),

                onDecline: () => _onDecline(booking),
              ),
            ),
          ),

        const SizedBox(height: 28),

        Text(
          'Earnings & Performance',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

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
            Expanded(child: _buildDriverRatingCard()),

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

        _statCard(
          'Monthly Confirmed',
          _rs(_monthlyEarnings),
          Icons.calendar_month_rounded,
          colors.success,
        ),
        const SizedBox(height: 12),
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
          _paymentRow(
            'Confirmed cash received',
            _confirmedPayments,
            Icons.check_circle_outline,
            colors.success,
          ),
          const SizedBox(height: 12),
          _paymentRow(
            'Cash awaiting confirmation',
            _pendingCash,
            Icons.hourglass_empty_rounded,
            colors.accent,
          ),
          const SizedBox(height: 12),
          _paymentRow(
            'Unpaid',
            _unpaidPayments,
            Icons.pending_actions_rounded,
            colors.danger,
          ),
          const SizedBox(height: 12),
          _paymentRow(
            'Simulated card payments',
            _simulatedPayments,
            Icons.credit_card_rounded,
            colors.textMuted,
          ),
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
  final double pickupDistanceKm;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isProcessing;
  final bool actionsDisabled;

  const _BookingRequestCard({
    required this.booking,
    required this.pickupDistanceKm,
    required this.onAccept,
    required this.onDecline,
    required this.isProcessing,
    required this.actionsDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = DrunkDrivePalette.of(context);
    final onSuccess =
        ThemeData.estimateBrightnessForColor(colors.success) == Brightness.dark
        ? Colors.white
        : Colors.black;

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
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: 20,
                color: colors.accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New trip request',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${pickupDistanceKm.toStringAsFixed(1)} km to pickup (straight-line)',
            style: TextStyle(
              color: colors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          _locationLine(
            colors,
            icon: Icons.trip_origin_rounded,
            label: 'PICKUP',
            value: booking.pickup.name,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Container(width: 2, height: 18, color: colors.surfaceBorder),
          ),
          _locationLine(
            colors,
            icon: Icons.location_on_rounded,
            label: 'DESTINATION',
            value: booking.destination.name,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 18,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${booking.vehicle.displayName} · ${booking.vehicle.transmission.label}\n${booking.distanceKm.toStringAsFixed(1)} km · approx. ${booking.durationMinutes} min',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: actionsDisabled ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(color: colors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: actionsDisabled ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.success,
                    foregroundColor: onSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Accept trip',
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

  Widget _locationLine(
    DrunkDrivePalette colors, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: colors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value.trim().isEmpty ? 'Location not specified' : value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
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
