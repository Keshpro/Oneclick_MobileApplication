
import 'package:flutter/material.dart';

import '../models/payment_request.dart';

class CheckoutScreen extends StatefulWidget {
  final PaymentRequest paymentRequest;

  // Connected when a trusted payment service is ready.
  final Future<void> Function(PaymentRequest request)? onPay;

  const CheckoutScreen({
    super.key,
    required this.paymentRequest,
    this.onPay,
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color primary = Color(0xFF0D9488);
  static const Color dark = Color(0xFF102D38);
  static const Color background = Color(0xFFF5F8FA);

  bool _processing = false;

  Future<void> _startPayment() async {
    final onPay = widget.onPay;

    if (onPay == null || _processing) return;

    setState(() => _processing = true);

    try {
      await onPay(widget.paymentRequest);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to start payment. Please try again.',
          ),
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
    final request = widget.paymentRequest;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'OneClick Payment',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _amountCard(request),
                  const SizedBox(height: 24),
                  _sectionTitle('Order Summary'),
                  const SizedBox(height: 12),
                  _orderSummary(request),
                  const SizedBox(height: 24),
                  _sectionTitle('Payment Method'),
                  const SizedBox(height: 12),
                  _paymentMethod(),
                  const SizedBox(height: 24),
                  _securityInfo(),
                ],
              ),
            ),
            _paymentFooter(request),
          ],
        ),
      ),
    );
  }

  Widget _amountCard(PaymentRequest request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D9488),
            Color(0xFF075B60),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(height: 14),
          const Text(
            'TOTAL PAYABLE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              request.formattedAmount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              request.module.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: dark,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _orderSummary(PaymentRequest request) {
    return _card(
      child: Column(
        children: [
          _summaryRow(
            'Service',
            request.module.displayName,
          ),
          const SizedBox(height: 16),
          _summaryRow(
            'Order',
            request.title,
          ),
          const SizedBox(height: 16),
          _summaryRow(
            'Order ID',
            request.orderId,
          ),
          const SizedBox(height: 16),
          if (request.description.trim().isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                request.description,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 12),
          _summaryRow(
            'Total',
            request.formattedAmount,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: bold ? dark : Colors.black54,
            fontWeight:
                bold ? FontWeight.w800 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: dark,
              fontSize: bold ? 17 : 13,
              fontWeight:
                  bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentMethod() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              color: primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card Payment',
                  style: TextStyle(
                    color: dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'PayHere Sandbox integration',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.radio_button_checked_rounded,
            color: primary,
          ),
        ],
      ),
    );
  }

  Widget _securityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: .15),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: primary,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Payment details will be processed by '
              'the secure payment gateway. '
              'OneClick will verify payment status '
              'before confirming your order.',
              style: TextStyle(
                color: dark,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentFooter(PaymentRequest request) {
    final ready = widget.onPay != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE8EFF1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Amount to pay',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                request.formattedAmount,
                style: const TextStyle(
                  color: dark,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed:
                  ready && !_processing ? _startPayment : null,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                disabledBackgroundColor:
                    const Color(0xFFB5CCCA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _processing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ready
                              ? 'Continue to Secure Payment'
                              : 'Gateway Setup Pending',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (!ready) ...[
            const SizedBox(height: 9),
            const Text(
              'Sandbox gateway is not connected yet.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE5ECEF),
        ),
      ),
      child: child,
    );
  }
}
