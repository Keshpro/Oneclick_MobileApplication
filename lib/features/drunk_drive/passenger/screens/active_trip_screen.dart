import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_firestore_service.dart';
import '../../services/driver_rating_service.dart';
import '../../services/driver_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'payment_screen.dart';

class ActiveTripScreen extends StatefulWidget {
  final BookingModel booking;

  const ActiveTripScreen({super.key, required this.booking});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  DrunkDrivePalette get _palette => DrunkDrivePalette.of(context);

  Color get _onAccent => ThemeData.estimateBrightnessForColor(_palette.accent) == Brightness.dark
      ? Colors.white
      : Colors.black;

  final BookingFirestoreService _bookingService = BookingFirestoreService();
  final DriverRatingService _driverRatingService = DriverRatingService();

  late BookingModel _booking;
  Timer? _driverSearchTimer;
  StreamSubscription<BookingModel?>? _bookingSubscription;
  @override
  void initState() {
    super.initState();

    _booking = widget.booking;

    _bookingSubscription = _bookingService
        .watchBooking(_booking.id)
        .listen(
          (updated) {
            if (!mounted || updated == null) return;

            setState(() {
              _booking = updated;
            });

            if (_booking.status != BookingStatus.searchingDriver) {
              _driverSearchTimer?.cancel();
            }
          },
          onError: (Object error) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unable to update trip: $error')),
            );
          },
        );

    _startDriverSearchTimerIfNeeded();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    _driverSearchTimer?.cancel();
    super.dispose();
  }

  void _startDriverSearchTimerIfNeeded() {
    _driverSearchTimer?.cancel();

    if (_booking.status != BookingStatus.searchingDriver) {
      return;
    }

    _driverSearchTimer = Timer(Duration(seconds: 30), () async {
      if (!mounted) return;

      try {
        final latest = await _bookingService.watchBooking(_booking.id).first;

        if (latest == null ||
            latest.status != BookingStatus.searchingDriver ||
            latest.driverId != null) {
          return;
        }

        final updated = await _bookingService.markDriverNotFound(_booking.id);

        if (updated == null || !mounted) return;

        setState(() {
          _booking = updated;
        });
      } catch (error) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update driver search: $error')),
        );
      }
    });
  }

  Future<void> _refreshBooking() async {
    try {
      final updated = await _bookingService.watchBooking(_booking.id).first;

      if (updated == null || !mounted) return;

      setState(() {
        _booking = updated;
      });

      if (_booking.status != BookingStatus.searchingDriver) {
        _driverSearchTimer?.cancel();
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to refresh booking: $error')),
      );
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
      return _palette.success;
    }

    if (_booking.status == BookingStatus.cancelledByUser ||
        _booking.status == BookingStatus.cancelledByDriver ||
        _booking.status == BookingStatus.driverNotFound ||
        _booking.status == BookingStatus.paymentFailed ||
        _booking.status == BookingStatus.incidentReported) {
      return _palette.danger;
    }

    return _palette.accent;
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cancel Booking?'),
          content: Text('Are you sure you want to cancel this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Keep Booking'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Cancel Booking'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final cancelled = await _bookingService.cancelBookingByPassenger(
      _booking.id,
    );

    if (!mounted) return;

    if (cancelled == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This booking can no longer be cancelled.'),
        ),
      );
      return;
    }

    setState(() {
      _booking = cancelled;
    });

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  Future<void> _retryDriverSearch() async {
    try {
      final updated = await _bookingService.retryDriverSearch(_booking.id);

      if (!mounted) return;

      if (updated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to restart the driver search.')),
        );
        return;
      }

      setState(() {
        _booking = updated;
      });

      _startDriverSearchTimerIfNeeded();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Searching for a driver again...')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to retry driver search: $error')),
      );
    }
  }

  Future<void> _showDriverRatingDialog() async {
    final driverId = _booking.driverId;

    if (driverId == null ||
        _driverRatingService.hasRatedBooking(_booking.id) ||
        !mounted) {
      return;
    }

    int selectedRating = 0;
    final reviewController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _palette.surface,
              title: Text(
                'Rate Your Driver',
                style: TextStyle(
                  color: _palette.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'How was your experience with your driver?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _palette.textMuted),
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;

                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = star;
                            });
                          },
                          icon: Icon(
                            star <= selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: _palette.accent,
                            size: 34,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: reviewController,
                      maxLines: 3,
                      style: TextStyle(color: _palette.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Write a review (optional)',
                        hintStyle: TextStyle(
                          color: _palette.textMuted,
                        ),
                        filled: true,
                        fillColor: _palette.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(color: _palette.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () {
                          final submitted = _driverRatingService.submitRating(
                            bookingId: _booking.id,
                            driverId: driverId,
                            rating: selectedRating,
                            review: reviewController.text,
                          );

                          if (submitted != null) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _palette.accent,
                    foregroundColor: _onAccent,
                  ),
                  child: Text(
                    'Submit Rating',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    reviewController.dispose();
  }

  Future<void> _openPayment() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PaymentScreen(booking: _booking)),
    );

    if (!mounted) return;

    _refreshBooking();

    if (result == true) {
      await _showDriverRatingDialog();

      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  Future<void> _shareTrip() async {
    final shareText =
        '''
Drunk & Drive Trip

Pickup: ${_booking.pickup.name}
Destination: ${_booking.destination.name}
Vehicle: ${_booking.vehicle.displayName}
Registration: ${_booking.vehicle.registrationNumber}
Distance: ${_booking.distanceKm.toStringAsFixed(1)} km
Status: ${_booking.status.label}

Booking ID: ${_booking.id}
''';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Trip',
                  style: TextStyle(
                    color: _palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Copy these trip details and share them with someone you trust.',
                  style: TextStyle(
                    color: _palette.textMuted,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _onAccent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _palette.surfaceBorder),
                  ),
                  child: Text(
                    shareText.trim(),
                    style: TextStyle(color: _palette.textPrimary, height: 1.5),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: shareText.trim()),
                      );

                      if (!sheetContext.mounted) return;

                      Navigator.pop(sheetContext);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Trip details copied to clipboard.'),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy_rounded),
                    label: Text(
                      'Copy Trip Details',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _palette.accent,
                      foregroundColor: _onAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _contactDriver() {
    final driverId = _booking.driverId;

    if (driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No driver has been assigned yet.')),
      );
      return;
    }

    final driver = DriverService().getDriverApplicationByUserId(driverId);

    if (driver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Driver contact details are unavailable.'),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Driver',
                  style: TextStyle(
                    color: _palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 18),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _palette.accent,
                    child: Icon(
                      Icons.person_rounded,
                      color: _onAccent,
                    ),
                  ),
                  title: Text(
                    driver.fullName,
                    style: TextStyle(
                      color: _palette.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    'Assigned Driver',
                    style: TextStyle(color: _palette.textMuted),
                  ),
                ),

                SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _onAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        color: _palette.accent,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          driver.phone,
                          style: TextStyle(
                            color: _palette.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: driver.phone),
                      );

                      if (!sheetContext.mounted) return;

                      Navigator.pop(sheetContext);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Driver phone number copied.'),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy_rounded),
                    label: Text(
                      'Copy Phone Number',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _palette.accent,
                      foregroundColor: _onAccent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEmergencyOptions() async {
    final emergencyDetails =
        '''
Drunk & Drive - Emergency Trip Details

Booking ID: ${_booking.id}
Pickup: ${_booking.pickup.name}
Destination: ${_booking.destination.name}
Vehicle: ${_booking.vehicle.displayName}
Registration: ${_booking.vehicle.registrationNumber}
Status: ${_booking.status.label}
''';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sos_rounded,
                      color: _palette.danger,
                      size: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Emergency / SOS',
                        style: TextStyle(
                          color: _palette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _palette.danger.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _palette.danger.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    'This app does not automatically contact emergency services. '
                    'If you are in immediate danger, contact the appropriate local '
                    'emergency service directly.',
                    style: TextStyle(
                      color: _palette.textPrimary,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'You can copy your trip details so they are ready to provide '
                  'to someone assisting you.',
                  style: TextStyle(
                    color: _palette.textMuted,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: emergencyDetails.trim()),
                      );

                      if (!sheetContext.mounted) return;

                      Navigator.pop(sheetContext);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Emergency trip details copied.'),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy_rounded),
                    label: Text(
                      'Copy Emergency Trip Details',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _palette.danger,
                      foregroundColor: _palette.textPrimary,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                if (_booking.driverId != null) ...[
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);

                        if (!mounted) return;

                        _contactDriver();
                      },
                      icon: Icon(Icons.phone_rounded),
                      label: Text(
                        'Contact Driver',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _palette.accent,
                        side: BorderSide(color: _palette.accent),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: _palette.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.background,
      appBar: AppBar(
        backgroundColor: _palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: _palette.textPrimary),
        title: Text(
          'Trip Details',
          style: TextStyle(color: _palette.textPrimary, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _refreshBooking,
            tooltip: 'Refresh trip',
            icon: Icon(Icons.refresh_rounded, color: _palette.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshBooking();
          },
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            children: [
              _buildStatusCard(),
              SizedBox(height: 16),

              if (_showTripPin) ...[
                _buildPinCard(),
                SizedBox(height: 16),
              ],

              _buildRouteCard(),
              SizedBox(height: 16),

              _buildVehicleCard(),
              SizedBox(height: 16),

              _buildTripSummaryCard(),
              SizedBox(height: 20),
              if (_booking.status == BookingStatus.requested ||
                  _booking.status == BookingStatus.searchingDriver ||
                  _booking.status == BookingStatus.driverAssigned ||
                  _booking.status == BookingStatus.driverAccepted ||
                  _booking.status == BookingStatus.driverArriving ||
                  _booking.status == BookingStatus.driverArrived ||
                  _booking.status == BookingStatus.verification) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _cancelBooking,
                    icon: Icon(Icons.cancel_outlined),
                    label: Text(
                      'Cancel Booking',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _palette.danger,
                      side: BorderSide(color: _palette.danger),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
              if (_booking.status == BookingStatus.driverNotFound) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _retryDriverSearch,
                    icon: Icon(Icons.refresh_rounded),
                    label: Text(
                      'Retry Driver Search',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _palette.accent,
                      foregroundColor: _onAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
              if (_booking.status == BookingStatus.tripCompleted ||
                  _booking.status == BookingStatus.payment) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openPayment,
                    icon: Icon(Icons.payment_rounded),
                    label: Text(
                      'Proceed to Payment',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _palette.accent,
                      foregroundColor: _onAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],

              if (_tripIsRunning) ...[
                _buildSafetyCard(),
                SizedBox(height: 16),
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
      padding: EdgeInsets.all(16),
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
          SizedBox(width: 12),
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
                SizedBox(height: 5),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _palette.textMuted,
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
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _palette.accent),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pin_rounded,
            color: _palette.accent,
            size: 30,
          ),
          SizedBox(height: 8),
          Text(
            'Trip PIN',
            style: TextStyle(color: _palette.textMuted, fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            _booking.tripPin!,
            style: TextStyle(
              color: _palette.accent,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Give this PIN to your assigned driver only when you are ready to start the trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _palette.textMuted,
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
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _palette.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route',
            style: TextStyle(
              color: _palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 16),
          _detailRow(
            Icons.my_location_rounded,
            _palette.success,
            'Pickup',
            _booking.pickup.name,
          ),
          SizedBox(height: 16),
          _detailRow(
            Icons.location_on_rounded,
            _palette.danger,
            'Destination',
            _booking.destination.name,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _palette.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Vehicle',
            style: TextStyle(
              color: _palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 16),
          _detailRow(
            Icons.directions_car_rounded,
            _palette.accent,
            'Vehicle',
            _booking.vehicle.displayName,
          ),
          SizedBox(height: 14),
          _detailRow(
            Icons.confirmation_number_outlined,
            _palette.textMuted,
            'Registration',
            _booking.vehicle.registrationNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard() {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _palette.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: TextStyle(
              color: _palette.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 16),
          _detailRow(
            Icons.route_rounded,
            _palette.textMuted,
            'Distance',
            '${_booking.distanceKm.toStringAsFixed(1)} km',
          ),
          SizedBox(height: 14),
          _detailRow(
            Icons.schedule_rounded,
            _palette.textMuted,
            'Estimated Time',
            '${_booking.durationMinutes} min',
          ),
          SizedBox(height: 14),
          _detailRow(
            Icons.payments_rounded,
            _palette.success,
            'Estimated Fare',
            'Rs. ${_booking.fareEstimate.total.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _palette.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _palette.accent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: _palette.accent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your trip is active. Stay safe and use the emergency option if you need assistance.',
              style: TextStyle(
                color: _palette.textMuted,
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
            onPressed: _shareTrip,
            icon: Icon(Icons.share_rounded),
            label: Text(
              'Share Trip',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _palette.textPrimary,
              side: BorderSide(color: _palette.surfaceBorder),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        if (_booking.driverId != null) ...[
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _contactDriver,
              icon: Icon(Icons.phone_rounded),
              label: Text(
                'Contact Driver',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _palette.accent,
                side: BorderSide(color: _palette.accent),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],

        SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _showEmergencyOptions,
            icon: Icon(Icons.sos_rounded, color: _palette.danger),
            label: Text(
              'Emergency / SOS',
              style: TextStyle(
                color: _palette.danger,
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
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: _palette.textMuted,
                  fontSize: 11,
                ),
              ),
              SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: _palette.textPrimary,
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
