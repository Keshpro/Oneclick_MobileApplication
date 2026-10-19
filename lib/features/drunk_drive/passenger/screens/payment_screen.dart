import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../models/booking_status.dart';
import '../../services/booking_service.dart';
import '../../theme/drunk_drive_colors.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final BookingService _bookingService = BookingService();

  String _selectedMethod = 'Cash';
  bool _isProcessing = false;

  Future<void> _pay() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));

    var booking = _bookingService.getBookingById(widget.booking.id);

    if (booking == null) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking could not be found.')),
      );
      return;
    }

    if (booking.status == BookingStatus.tripCompleted) {
      booking = _bookingService.moveToPayment(booking.id);
    }

    if (booking == null || booking.status != BookingStatus.payment) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start payment. Please try again.')),
      );
      return;
    }

    final completed = _bookingService.completePayment(booking.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (completed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment could not be completed.')),
      );
      return;
    }

    final palette = DrunkDrivePalette.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: palette.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: palette.success),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Prototype Payment Recorded',
                style: TextStyle(color: palette.textPrimary),
              ),
            ),
          ],
        ),
        content: Text(
          _selectedMethod == 'Cash'
              ? 'Cash payment was marked in the prototype only.'
              : 'Mock card payment was recorded. No real transaction occurred.',
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
  }

  @override
  Widget build(BuildContext context) {
    final palette = DrunkDrivePalette.of(context);
    final booking =
        _bookingService.getBookingById(widget.booking.id) ?? widget.booking;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                  Text(
                    'Trip Fare (Estimated)',
                    style: TextStyle(color: palette.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
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
                  _summaryRow(
                    'Distance',
                    '${booking.distanceKm.toStringAsFixed(1)} km',
                    palette,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Method',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
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
              title: 'Card',
              subtitle: 'Mock card payment for prototype',
              palette: palette,
            ),
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
                  Icon(
                    Icons.info_outline_rounded,
                    color: palette.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is a prototype payment flow. No real card transaction will be made.',
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: 12,
                        height: 1.4,
                      ),
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
              onPressed: _isProcessing ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _selectedMethod == 'Cash'
                          ? 'Confirm Cash Payment (Demo)'
                          : 'Mock Card Payment',
                      style: const TextStyle(fontWeight: FontWeight.w800),
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
        onTap: () => setState(() => _selectedMethod = value),
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
                    Text(
                      title,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(color: palette.textMuted, fontSize: 11),
                    ),
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
          child: Text(
            label,
            style: TextStyle(color: palette.textMuted, fontSize: 12),
          ),
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
