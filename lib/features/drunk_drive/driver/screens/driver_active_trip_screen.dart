import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_firestore_service.dart';
import '../../services/driver_trip_location_service.dart';
import '../../theme/drunk_drive_colors.dart';
import 'report_incident_screen.dart';

class DriverActiveTripScreen extends StatefulWidget {
  final BookingModel booking;

  const DriverActiveTripScreen({super.key, required this.booking});

  @override
  State<DriverActiveTripScreen> createState() => _DriverActiveTripScreenState();
}

class _DriverActiveTripScreenState extends State<DriverActiveTripScreen> {
  final BookingFirestoreService _bookingService = BookingFirestoreService();
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _bookingStream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _trackingStatusListener;

  final DriverTripLocationService _locationService = DriverTripLocationService();
  bool _locationBusy = false;
  bool _locationSharing = false;

  Future<void> _toggleLocation() async {
    if (_locationBusy) return;
    setState(() => _locationBusy = true);
    try {
      if (_locationSharing) {
        await _locationService.stop();
      } else {
        await _locationService.start(widget.booking.id);
      }
      if (mounted) setState(() => _locationSharing = _locationService.isSharing);
    } catch (error) {
      if (mounted) _showMessage('Location sharing: $error');
    } finally {
      if (mounted) setState(() => _locationBusy = false);
    }
  }

  @override
  void dispose() {
    // Best-effort cleanup if the screen is closed. The passenger also checks
    // location freshness, so abandoned browser sessions do not look live.
    _locationService.onError = null;
    final listener = _trackingStatusListener;
    if (listener != null) unawaited(listener.cancel());
    unawaited(_locationService.stop().catchError((Object _) {}));
    super.dispose();
  }

  bool _isEnding = false;
  bool _isConfirmingCash = false;

  @override
  void initState() {
    super.initState();
    _locationService.onError = (error) async {
      if (!mounted) return;
      setState(() => _locationSharing = false);
      _showMessage('Location sharing stopped: $error');
    };
    _bookingStream = FirebaseFirestore.instance
        .collection('drunkDriveBookings')
        .doc(widget.booking.id)
        .snapshots();
    _trackingStatusListener = _bookingStream.listen((snapshot) {
      final status = snapshot.data()?['status'];
      if (status != 'tripStarted' && status != 'tripInProgress' &&
          _locationService.isSharing) {
        unawaited(_locationService.stop().catchError((Object _) {}));
        if (mounted) setState(() => _locationSharing = false);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onEndTrip() async {
    if (_isEnding) return;
    setState(() => _isEnding = true);

    try {
      final updated = await _bookingService.endTrip(
        bookingId: widget.booking.id,
      );
      if (!mounted) return;
      if (updated == null) {
        _showMessage('Unable to complete this trip. Please refresh and try again.');
        return;
      }
      try {
        await _locationService.stop();
      } catch (_) {
        // Trip completion already succeeded. Do not report it as failed.
      }
      if (mounted) setState(() => _locationSharing = false);
      if (mounted) _showMessage('Trip completed. Payment has not been confirmed yet.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Error completing trip: $error');
    } finally {
      if (mounted) setState(() => _isEnding = false);
    }
  }

  Future<void> _onConfirmCash(BookingModel booking) async {
    if (_isConfirmingCash ||
        booking.status != BookingStatus.completed ||
        booking.paymentStatus != 'pending' ||
        booking.paymentMethod != 'cash') {
      return;
    }

    final colors = DrunkDrivePalette.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Confirm Cash Received?',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Only confirm after you have actually received '
          'Rs. ${booking.customerAmountDue.toStringAsFixed(0)} in cash.',
          style: TextStyle(color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Not Yet', style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Cash Received', style: TextStyle(color: colors.accent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isConfirmingCash = true);
    try {
      final updated = await _bookingService.confirmCashPaymentReceived(
        booking.id,
      );
      if (!mounted) return;
      _showMessage(
        updated == null
            ? 'Payment could not be confirmed. Check its current status.'
            : 'Cash received. Payment recorded in Firebase.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to confirm payment: $error');
    } finally {
      if (mounted) setState(() => _isConfirmingCash = false);
    }
  }

  Future<void> _onReportIncident(BookingModel booking) async {
    final reported = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportIncidentScreen(booking: booking),
      ),
    );
    if (!mounted) return;
    if (reported == true) {
      _showMessage('Incident report submitted.');
    }
  }

  String _paymentDescription(BookingModel booking) {
    switch (booking.paymentStatus) {
      case 'paid':
        return 'Cash received and confirmed';
      case 'pending':
        return 'Cash requested — waiting for driver confirmation';
      case 'simulated':
        return 'Card payment simulated — no real payment received';
      default:
        return 'Unpaid — waiting for passenger payment selection';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = DrunkDrivePalette.of(context);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _bookingStream,
      builder: (context, snapshot) {
        BookingModel booking = widget.booking;
        String? loadError;

        if (snapshot.hasError) {
          loadError = 'Unable to load the latest trip status.';
        } else if (snapshot.hasData) {
          final document = snapshot.data!;
          final data = document.data();
          if (!document.exists || data == null) {
            loadError = 'This booking is no longer available.';
          } else if (data['driverId'] != _bookingService.currentUserId) {
            loadError = 'You do not have access to this trip.';
          } else {
            booking = BookingModel.fromMap(document.id, data);
          }
        }

        final completed = booking.status == BookingStatus.completed;
        final canConfirmCash = completed &&
            booking.paymentStatus == 'pending' &&
            booking.paymentMethod == 'cash';

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            foregroundColor: colors.textPrimary,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              completed ? 'Trip Completed' : 'Active Trip',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SafeArea(
            child: loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        loadError,
                        style: TextStyle(color: colors.danger),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              completed
                                  ? Icons.check_circle_rounded
                                  : Icons.directions_car_filled_rounded,
                              color: colors.success,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                completed ? 'Trip Completed' : booking.status.label,
                                style: TextStyle(
                                  color: colors.success,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!completed &&
                          (booking.status == BookingStatus.tripStarted ||
                              booking.status == BookingStatus.tripInProgress)) ...[
                        const SizedBox(height: 16),
                        Card(
                          color: colors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Live location sharing', style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                )),
                                const SizedBox(height: 8),
                                Text(
                                  _locationSharing
                                    ? 'Your location is being shared with this passenger while this screen is active.'
                                    : 'Share your GPS position with the passenger during this trip. You can stop at any time.',
                                  style: TextStyle(color: colors.textMuted),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: _locationBusy ? null : _toggleLocation,
                                  icon: Icon(_locationSharing ? Icons.location_off : Icons.my_location),
                                  label: Text(_locationBusy
                                      ? 'Updating…'
                                      : _locationSharing ? 'Stop Sharing' : 'Start Sharing Location'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
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
                            _row(Icons.my_location_rounded, colors.success,
                                'Pickup', booking.pickup.name),
                            const SizedBox(height: 12),
                            _row(Icons.location_on_rounded, colors.danger,
                                'Destination', booking.destination.name),
                            const SizedBox(height: 12),
                            _row(
                              Icons.directions_car_rounded,
                              colors.accent,
                              'Vehicle',
                              '${booking.vehicle.displayName} • '
                                  '${booking.vehicle.registrationNumber}',
                            ),
                            const SizedBox(height: 12),
                            _row(
                              Icons.route_rounded,
                              colors.textMuted,
                              'Distance / ETA',
                              '${booking.distanceKm.toStringAsFixed(1)} km • '
                                  '${booking.durationMinutes} min',
                            ),
                            const SizedBox(height: 12),
                            _row(
                              Icons.payments_rounded,
                              colors.accent,
                              completed ? 'Customer to Pay' : 'Estimated Fare',
                              'Rs. ${booking.customerAmountDue.toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                      ),
                      if (completed) ...[
                        const SizedBox(height: 16),
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
                              Text(
                                'Payment Status',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _paymentDescription(booking),
                                style: TextStyle(color: colors.textMuted),
                              ),
                              if (booking.paymentStatus == 'simulated') ...[
                                const SizedBox(height: 8),
                                Text(
                                  'No real card transaction took place.',
                                  style: TextStyle(color: colors.danger),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => _onReportIncident(booking),
                        icon: Icon(Icons.report_outlined, color: colors.danger),
                        label: Text(
                          'Report Incident',
                          style: TextStyle(color: colors.danger),
                        ),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: loadError != null
                    ? ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Back to Dashboard'),
                      )
                    : !completed
                        ? ElevatedButton(
                            onPressed: _isEnding ? null : _onEndTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.danger,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isEnding
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('End Trip'),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canConfirmCash) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isConfirmingCash
                                        ? null
                                        : () => _onConfirmCash(booking),
                                    icon: _isConfirmingCash
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.payments_rounded),
                                    label: Text(
                                      _isConfirmingCash
                                          ? 'Confirming...'
                                          : 'Confirm Cash Received',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colors.accent,
                                    side: BorderSide(color: colors.accent),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('Back to Dashboard'),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _row(IconData icon, Color iconColor, String label, String value) {
    final colors = DrunkDrivePalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: colors.textMuted, fontSize: 11)),
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
