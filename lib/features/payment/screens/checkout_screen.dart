
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/payment_request.dart';
import '../services/payment_service.dart';

class CheckoutScreen extends StatefulWidget {
  final PaymentRequest request;

  const CheckoutScreen({
    super.key,
    required this.request,
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _loading = false;
  String? _paymentId;
  String? _error;
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final id = await PaymentService.startPayment(
        widget.request,
      );

      if (!mounted) return;

      setState(() {
        _paymentId = id;
      });

      _listenForConfirmation(id);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _listenForConfirmation(String paymentId) {
    _subscription?.cancel();

    _subscription = PaymentService
        .watchPayment(paymentId)
        .listen(
      (snapshot) {
        if (!mounted) return;

        final data = snapshot.data();

        if (data?['status'] == 'paid') {
          _subscription?.cancel();

          Navigator.of(context).pop(true);
        }
      },
      onError: (Object error) {
        if (!mounted) return;

        setState(() {
          _loading = false;
          _error = 'Unable to verify payment: $error';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount =
        (widget.request.amountMinor / 100).toStringAsFixed(2);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Secure Checkout'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 60,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(height: 16),
              const Text(
                'OneClick Payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PayHere Sandbox • Test Payment',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 30),
                      Text(widget.request.title),
                      const SizedBox(height: 12),
                      Text(
                        'Booking: ${widget.request.bookingId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'LKR $amount',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
              if (_paymentId != null) ...[
                const SizedBox(height: 20),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        'Waiting for verified payment confirmation...',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton.icon(
                onPressed:
                    _loading ? null : _startPayment,
                icon: const Icon(Icons.lock_outline),
                label: Text(
                  _loading
                      ? 'Processing...'
                      : 'Pay with PayHere',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(18),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your booking is confirmed only after '
                'the payment is verified by the server.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
