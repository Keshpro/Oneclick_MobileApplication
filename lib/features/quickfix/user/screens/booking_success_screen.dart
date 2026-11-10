
import 'package:flutter/material.dart';

import 'my_bookings_screen.dart';

class PaymentRequest {
  final String orderId;
  final double amount;
  final String currency;

  const PaymentRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
  });

  String get formattedAmount => '$currency ${amount.toStringAsFixed(2)}';

  factory PaymentRequest.fromMap(Map<String, dynamic> map) {
    final value = map['amount'];
    final amount = value is num ? value.toDouble() : 0.0;
    final orderId = map['orderId']?.toString() ?? 'N/A';

    return PaymentRequest(
      orderId: orderId,
      amount: amount,
      currency: map['currency']?.toString() ?? 'INR',
    );
  }
}

class CheckoutScreen extends StatelessWidget {
  final PaymentRequest paymentRequest;
  final Future<void> Function(PaymentRequest request)? onPay;

  const CheckoutScreen({
    super.key,
    required this.paymentRequest,
    this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text('Order ID: ${paymentRequest.orderId}'),
              const SizedBox(height: 8),
              Text('Amount: ${paymentRequest.formattedAmount}'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (onPay != null) {
                      await onPay!(paymentRequest);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Pay Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> worker;

  // Optional payment details supplied by the booking flow.
  final PaymentRequest? paymentRequest;

  // Pass true only when the booking has actually been
  // accepted and is eligible for payment.
  final bool bookingAccepted;

  // Connected to the common payment gateway service.
  final Future<void> Function(PaymentRequest request)? onPay;

  const BookingSuccessScreen({
    super.key,
    required this.worker,
    this.paymentRequest,
    this.bookingAccepted = false,
    this.onPay,
  });

  static const Color _primary = Color(0xFF0D9488);
  static const Color _primaryDark = Color(0xFF075B60);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _background = Color(0xFFF8FAFC);

  String get _workerName {
    final name = worker['name']?.toString().trim() ?? '';
    return name.isNotEmpty ? name : 'the professional';
  }

  bool get _canOpenCheckout {
    return bookingAccepted && paymentRequest != null;
  }

  void _openCheckout(BuildContext context) {
    if (!_canOpenCheckout) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          paymentRequest: paymentRequest!,
          onPay: onPay,
        ),
      ),
    );
  }

  void _openMyBookings(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MyBookingsScreen(),
      ),
      (route) => route.isFirst,
    );
  }

  void _backToHome(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = bookingAccepted;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Booking Status',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: () => _backToHome(context),
            icon: const Icon(
              Icons.close_rounded,
              color: _textDark,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 26),

                      _buildStatusIcon(isAccepted),

                      const SizedBox(height: 28),

                      Text(
                        isAccepted
                            ? 'Booking Accepted!'
                            : 'Booking Request Sent!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        isAccepted
                            ? '$_workerName has accepted your '
                                'service request.'
                            : 'Your service request has been sent '
                                'to $_workerName. You will be '
                                'notified once they accept your job.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textMuted,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _buildBookingCard(isAccepted),

                      const SizedBox(height: 18),

                      _buildStatusInfo(isAccepted),

                      if (paymentRequest != null) ...[
                        const SizedBox(height: 18),
                        _buildPaymentCard(),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool accepted) {
    final iconColor = accepted
        ? const Color(0xFF16A34A)
        : _primary;

    final circleColor = accepted
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFE0F2F1);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor.withValues(alpha: .22),
          width: 2,
        ),
      ),
      child: Icon(
        accepted
            ? Icons.check_circle_rounded
            : Icons.mark_email_read_rounded,
        color: iconColor,
        size: 76,
      ),
    );
  }

  Widget _buildBookingCard(bool accepted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: _primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Fix Service',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _workerName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Booking Status',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accepted
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  accepted ? 'Accepted' : 'Pending',
                  style: TextStyle(
                    color: accepted
                        ? const Color(0xFF15803D)
                        : const Color(0xFF92400E),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          if (paymentRequest != null) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Booking Reference',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    paymentRequest!.orderId,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusInfo(bool accepted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primary.withValues(alpha: .14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            accepted
                ? Icons.verified_outlined
                : Icons.notifications_active_outlined,
            color: _primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              accepted
                  ? 'Your service request has been accepted. '
                      'Check the payment section below if payment '
                      'is required.'
                  : 'You can track your booking from My Bookings. '
                      'Payment is not confirmed at this stage.',
              style: const TextStyle(
                color: _primaryDark,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final request = paymentRequest!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: _primary,
              ),
              SizedBox(width: 10),
              Text(
                'Payment Summary',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Quoted Amount',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                request.formattedAmount,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          Text(
            bookingAccepted
                ? 'You can continue to the OneClick checkout.'
                : 'Payment becomes available after the '
                    'booking is accepted.',
            style: const TextStyle(
              color: _textMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_canOpenCheckout) ...[
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _openCheckout(context),
              icon: const Icon(Icons.payment_rounded),
              label: const Text(
                'Continue to Payment',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _openMyBookings(context),
            icon: const Icon(
              Icons.calendar_month_rounded,
              size: 20,
            ),
            label: const Text(
              'View My Bookings',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _textDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => _backToHome(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textDark,
              side: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
