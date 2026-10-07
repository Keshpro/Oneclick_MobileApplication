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
        const SnackBar(
          content: Text('Unable to start payment. Please try again.'),
        ),
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

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: DrunkDriveColors.surface,
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: DrunkDriveColors.success),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Payment Completed',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: Text(
            _selectedMethod == 'Cash'
                ? 'The trip has been marked as paid by cash.'
                : 'Mock card payment completed successfully.',
            style: const TextStyle(color: DrunkDriveColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Done',
                style: TextStyle(color: DrunkDriveColors.accent),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final booking =
        _bookingService.getBookingById(widget.booking.id) ?? widget.booking;

    return Scaffold(
      backgroundColor: DrunkDriveColors.background,
      appBar: AppBar(
        backgroundColor: DrunkDriveColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: DrunkDriveColors.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Fare',
                    style: TextStyle(
                      color: DrunkDriveColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs. ${booking.fareEstimate.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _summaryRow('From', booking.pickup.name),
                  const SizedBox(height: 10),
                  _summaryRow('To', booking.destination.name),
                  const SizedBox(height: 10),
                  _summaryRow(
                    'Distance',
                    '${booking.distanceKm.toStringAsFixed(1)} km',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Method',
              style: TextStyle(
                color: Colors.white,
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
            ),
            const SizedBox(height: 10),
            _paymentOption(
              value: 'Card',
              icon: Icons.credit_card_rounded,
              title: 'Card',
              subtitle: 'Mock card payment for prototype',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DrunkDriveColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: DrunkDriveColors.accent,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is currently a prototype payment flow. No real card transaction will be made.',
                      style: TextStyle(
                        color: DrunkDriveColors.textMuted,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: DrunkDriveColors.accent,
                foregroundColor: DrunkDriveColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _selectedMethod == 'Cash'
                          ? 'Confirm Cash Payment'
                          : 'Pay Now',
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
  }) {
    final selected = _selectedMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DrunkDriveColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? DrunkDriveColors.accent
                : DrunkDriveColors.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? DrunkDriveColors.accent
                  : DrunkDriveColors.textMuted,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: DrunkDriveColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? DrunkDriveColors.accent
                  : DrunkDriveColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(
              color: DrunkDriveColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
