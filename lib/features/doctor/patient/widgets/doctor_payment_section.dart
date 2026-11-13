import 'package:flutter/material.dart';

import '../../../payment/models/payment_request.dart';
import '../../../payment/screens/checkout_screen.dart';



class DoctorPaymentSection extends StatefulWidget {
  final String bookingId;
  final int amountMinor;

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;

  final VoidCallback onPaymentVerified;
  final VoidCallback onViewAppointments;

  const DoctorPaymentSection({
    super.key,
    required this.bookingId,
    required this.amountMinor,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.onPaymentVerified,
    required this.onViewAppointments,
  });

  @override
  State<DoctorPaymentSection> createState() =>
      _DoctorPaymentSectionState();
}

class _DoctorPaymentSectionState
    extends State<DoctorPaymentSection> {
  bool _processing = false;

  Future<void> _pay() async {
    if (_processing) return;

    setState(() => _processing = true);

    try {
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            request: PaymentRequest(
              bookingId: widget.bookingId,
              module: 'doctor',
              title: 'Doctor Consultation',
              amountMinor: widget.amountMinor,
              firstName: widget.firstName,
              lastName: widget.lastName,
              email: widget.email,
              phone: widget.phone,
              address: widget.address,
              city: widget.city,
            ),
          ),
        ),
      );

      if (!mounted) return;

      if (verified == true) {
        widget.onPaymentVerified();
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount =
        (widget.amountMinor / 100).toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Amount to pay',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            Text(
              'LKR $amount',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _processing ? null : _pay,
            icon: _processing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.lock_outline),
            label: Text(
              _processing
                  ? 'Processing...'
                  : 'Pay Securely with PayHere',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF087F6D),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFFB3CECA),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'PayHere Sandbox • Test payments only',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 10),

        TextButton(
          onPressed: widget.onViewAppointments,
          child: const Text(
            'View My Appointments',
            style: TextStyle(
              color: Color(0xFF009C91),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
