import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  /// Optional callback for cash payment.
  final VoidCallback? onCashPaymentSelected;

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
    this.onCashPaymentSelected,
  });

  @override
  State<DoctorPaymentSection> createState() => _DoctorPaymentSectionState();
}

class _DoctorPaymentSectionState extends State<DoctorPaymentSection> {
  // Palette
  static const Color primary = Color(0xFF087F6D);
  static const Color primarySoft = Color(0xFFE6F4F1);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color amber = Color(0xFFB45309);
  static const Color amberSoft = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEF2F2);

  bool _processing = false;
  bool _loadingStatus = true;
  String? _loadError;

  String? _paymentId;
  String? _paymentStatus;
  String? _paymentMethod;

  bool get _hasPayment =>
      _paymentStatus == 'demo_paid' || _paymentStatus == 'pending_cash';

  bool get _isDemoPaid => _paymentStatus == 'demo_paid';

  bool get _isCashPending => _paymentStatus == 'pending_cash';

  @override
  void initState() {
    super.initState();
    _refreshPaymentStatus();
  }

  // ---------------------------------------------------------------------------
  // Logic (unchanged behaviour)
  // ---------------------------------------------------------------------------

  Future<void> _refreshPaymentStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => _loadingStatus = false);
      return;
    }

    if (mounted) setState(() => _loadError = null);

    try {
      final booking = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.bookingId)
          .get();

      if (!booking.exists) {
        throw StateError('Appointment not found.');
      }

      final bookingData = booking.data()!;

      if (bookingData['userId'] != user.uid) {
        throw StateError('Unauthorized appointment.');
      }

      final paymentId = bookingData['paymentId']?.toString();

      if (paymentId == null || paymentId.isEmpty) {
        if (mounted) {
          setState(() {
            _paymentId = null;
            _paymentStatus = null;
            _paymentMethod = null;
          });
        }
        return;
      }

      final payment = await FirebaseFirestore.instance
          .collection('payments')
          .doc(paymentId)
          .get();

      if (!payment.exists) {
        throw StateError('Payment record not found.');
      }

      final data = payment.data()!;

      final validPayment = data['userId'] == user.uid &&
          data['bookingId'] == widget.bookingId &&
          data['module'] == 'doctor' &&
          data['amountMinor'] == widget.amountMinor &&
          data['environment'] == 'demo' &&
          data['currency'] == 'LKR';

      if (!validPayment) {
        throw StateError('Payment details mismatch.');
      }

      if (!mounted) return;

      setState(() {
        _paymentId = paymentId;
        _paymentStatus = data['status']?.toString();
        _paymentMethod = data['method']?.toString();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _pay() async {
    if (_processing || _loadingStatus || _hasPayment) return;

    setState(() => _processing = true);

    try {
      // Recheck the booking before opening checkout.
      await _refreshPaymentStatus();

      if (!mounted || _hasPayment || _loadError != null) return;

      final completed = await Navigator.of(context).push<bool>(
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

      if (completed == true) {
        await _refreshPaymentStatus();

        if (!mounted) return;

        if (_isDemoPaid) {
          widget.onPaymentVerified();
        } else if (_isCashPending) {
          widget.onCashPaymentSelected?.call();
          _snack('Cash selected. Pay at the clinic to confirm.', amber);
        }
      }
    } catch (error) {
      if (!mounted) return;
      _snack(_friendlyError(error), danger);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _friendlyError(Object error) {
    if (error is StateError) return error.message;
    return 'Something went wrong. Check your connection and try again.';
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(message),
        ),
      );
  }

  /// 250000 -> "2,500.00"
  String _formatAmount(int minor) {
    final whole = minor ~/ 100;
    final cents = (minor % 100).toString().padLeft(2, '0');
    final digits = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '$buffer.$cents';
  }

  Future<void> _copyPaymentId() async {
    final id = _paymentId;
    if (id == null) return;
    await Clipboard.setData(ClipboardData(text: id));
    if (mounted) _snack('Payment ID copied', ink);
  }

  // ---------------------------------------------------------------------------
  // UI pieces
  // ---------------------------------------------------------------------------

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consultation fee',
            style: TextStyle(
              color: Color(0xFFBFE6DF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'LKR',
                style: TextStyle(
                  color: Color(0xFFBFE6DF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatAmount(widget.amountMinor),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodTile(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: primary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: muted, fontSize: 12, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'You can pay by',
          style: TextStyle(
            color: ink,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _methodTile(
              Icons.credit_card_rounded,
              'Card',
              'Pay now and confirm instantly',
            ),
            const SizedBox(width: 12),
            _methodTile(
              Icons.payments_outlined,
              'Cash',
              'Pay at the clinic',
            ),
          ],
        ),
      ],
    );
  }

  Widget _payButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _processing ? null : _pay,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB3CECA),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: _processing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text('Pay LKR ${_formatAmount(widget.amountMinor)}'),
      ),
    );
  }

  Widget _detailRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: muted, fontSize: 13)),
          const SizedBox(width: 16),
          Flexible(child: value),
        ],
      ),
    );
  }

  Widget _statusCard() {
    final cash = _isCashPending;
    final accent = cash ? amber : primary;
    final soft = cash ? amberSoft : primarySoft;

    return Container(
      key: ValueKey(_paymentStatus),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: soft,
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cash ? Icons.schedule_rounded : Icons.check_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cash ? 'Pay cash at the clinic' : 'Payment received',
                        style: TextStyle(
                          color: accent,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cash
                            ? 'Your appointment is booked. Bring '
                                'LKR ${_formatAmount(widget.amountMinor)} '
                                'to your visit.'
                            : 'Your appointment is confirmed.',
                        style: const TextStyle(
                          color: ink,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            child: Column(
              children: [
                _detailRow(
                  'Method',
                  Text(
                    _paymentMethod == 'cash' ? 'Cash' : 'Demo card',
                    style: const TextStyle(
                      color: ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _detailRow(
                  'Amount',
                  Text(
                    'LKR ${_formatAmount(widget.amountMinor)}',
                    style: const TextStyle(
                      color: ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_paymentId != null)
                  _detailRow(
                    'Payment ID',
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _copyPaymentId,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _paymentId!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.copy_rounded,
                              size: 15,
                              color: muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            color: surface,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: muted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo mode: no real money was charged.',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dangerSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: danger, size: 20),
              SizedBox(width: 8),
              Text(
                "Couldn't load payment details",
                style: TextStyle(
                  color: danger,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _loadError ?? '',
            style: const TextStyle(color: ink, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() => _loadingStatus = true);
              _refreshPaymentStatus();
            },
            style: TextButton.styleFrom(
              foregroundColor: danger,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Try again',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingSkeleton() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: primary),
      ),
    );
  }

  Widget _body() {
    if (_loadingStatus) return _loadingSkeleton();
    if (_loadError != null) return _errorCard();
    if (_hasPayment) return _statusCard();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _methods(),
        const SizedBox(height: 18),
        _payButton(),
        const SizedBox(height: 10),
        const Text(
          'Demo payment. No real money is charged.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _amountCard(),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey<String>(
              _loadingStatus
                  ? 'loading'
                  : _loadError != null
                      ? 'error'
                      : (_paymentStatus ?? 'unpaid'),
            ),
            child: _body(),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: widget.onViewAppointments,
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: const Text('View my appointments'),
        ),
      ],
    );
  }
}