import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_firestore_service.dart';
import '../../theme/drunk_drive_colors.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final BookingFirestoreService _bookingService = BookingFirestoreService();
  StreamSubscription<BookingModel?>? _bookingSubscription;

  late BookingModel _booking;
  String _selectedMethod = 'Cash';
  bool _isProcessing = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _bookingSubscription = _bookingService.watchBooking(widget.booking.id).listen(
      (booking) {
        if (!mounted) return;
        setState(() {
          if (booking != null) _booking = booking;
          _loadError = booking == null ? 'Booking could not be found.' : null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _loadError = 'Unable to load payment details: $error');
      },
    );
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }

  String _statusText(BookingModel booking) {
    switch (booking.paymentStatus) {
      case 'paid':
        return 'Cash payment confirmed by driver';
      case 'pending':
        return 'Waiting for driver to confirm cash received';
      case 'simulated':
        return 'Card payment simulated — no money was charged';
      default:
        return 'Payment not yet requested';
    }
  }

  Future<void> _pay() async {
    if (_isProcessing || _loadError != null) return;
    setState(() => _isProcessing = true);

    try {
      // Recheck Firestore rather than relying on the booking passed by navigation.
      final booking = await _bookingService.getBookingForParticipant(
        widget.booking.id,
      );
      if (!mounted) return;

      if (booking == null) {
        _showMessage('Booking could not be found or accessed.');
        return;
      }
      setState(() => _booking = booking);

      if (booking.status != BookingStatus.completed) {
        _showMessage('Payment is available after the trip is completed.');
        return;
      }
      if (booking.paymentStatus != 'unpaid') {
        _showMessage(_statusText(booking));
        return;
      }

      final isCash = _selectedMethod == 'Cash';
      final updated = isCash
          ? await _bookingService.requestCashPayment(booking.id)
          : await _bookingService.completeSimulatedCardPayment(booking.id);
      if (!mounted) return;

      if (updated == null) {
        _showMessage('Payment status changed. Please check and try again.');
        return;
      }

      setState(() => _booking = updated);
      final palette = DrunkDrivePalette.of(context);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: palette.surface,
          title: Row(
            children: [
              Icon(
                isCash ? Icons.hourglass_top_rounded : Icons.info_rounded,
                color: palette.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isCash ? 'Cash Payment Requested' : 'Card Payment Simulated',
                  style: TextStyle(color: palette.textPrimary),
                ),
              ),
            ],
          ),
          content: Text(
            isCash
                ? 'Please pay the driver directly. Your payment stays pending '
                    'until the driver confirms receiving the cash.'
                : 'This is a demonstration only. No real card was charged '
                    'and this booking is not marked as paid.',
            style: TextStyle(color: palette.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Done', style: TextStyle(color: palette.accent)),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to update payment: $error');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = DrunkDrivePalette.of(context);
    final booking = _booking;
    final canRequest = booking.status == BookingStatus.completed &&
        booking.paymentStatus == 'unpaid' &&
        _loadError == null;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loadError != null) ...[
              Text(_loadError!, style: TextStyle(color: palette.danger)),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: palette.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer to Pay',
                      style: TextStyle(color: palette.textMuted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    'Rs. ${booking.customerAmountDue.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _summaryRow('From', booking.pickup.name, palette),
                  const SizedBox(height: 10),
                  _summaryRow('To', booking.destination.name, palette),
                  const SizedBox(height: 10),
                  _summaryRow('Distance',
                      '${booking.distanceKm.toStringAsFixed(1)} km', palette),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.surfaceBorder),
              ),
              child: Text(
                _statusText(booking),
                style: TextStyle(
                  color: booking.paymentStatus == 'paid'
                      ? palette.success
                      : palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (canRequest) ...[
              const SizedBox(height: 24),
              Text('Payment Method',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  )),
              const SizedBox(height: 12),
              _paymentOption(
                value: 'Cash',
                icon: Icons.payments_outlined,
                title: 'Cash',
                subtitle: 'Pay the driver directly',
                palette: palette,
              ),
              const SizedBox(height: 10),
              _paymentOption(
                value: 'Card',
                icon: Icons.credit_card_rounded,
                title: 'Card (simulation)',
                subtitle: 'Demo only — no card charge will occur',
                palette: palette,
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: palette.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cash payment is only recorded as paid after driver confirmation. '
                      'Card payments are simulated and do not transfer money.',
                      style: TextStyle(color: palette.textMuted, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.surface,
            border: Border(top: BorderSide(color: palette.surfaceBorder)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isProcessing || !canRequest) ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      !canRequest
                          ? booking.paymentStatus == 'unpaid'
                              ? 'Available After Trip Completion'
                              : _statusText(booking)
                          : _selectedMethod == 'Cash'
                              ? 'Request Cash Payment'
                              : 'Simulate Card Payment',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required DrunkDrivePalette palette,
  }) {
    final selected = _selectedMethod == value;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isProcessing ? null : () => setState(() => _selectedMethod = value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? palette.accent : palette.surfaceBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? palette.accent : palette.textMuted),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(color: palette.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? palette.accent : palette.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, DrunkDrivePalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75,
          child: Text(label, style: TextStyle(color: palette.textMuted, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
