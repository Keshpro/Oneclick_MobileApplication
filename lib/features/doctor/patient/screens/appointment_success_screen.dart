import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../payment/models/payment_request.dart';
import '../../../payment/screens/checkout_screen.dart';
import 'my_appointments_screen.dart';

typedef DoctorPaymentHandler = Future<String?> Function(
  String appointmentId,
);

class AppointmentSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String consultationType;
  final String appointmentId;
  final int amountMinor;

  // Retained for compatibility with existing booking calls.
  // Demo checkout does not use the old PayHere handler.
  final DoctorPaymentHandler? onStartPayment;

  const AppointmentSuccessScreen({
    super.key,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.consultationType,
    required this.appointmentId,
    required this.amountMinor,
    this.onStartPayment,
  });

  @override
  State<AppointmentSuccessScreen> createState() =>
      _AppointmentSuccessScreenState();
}

class _AppointmentSuccessScreenState extends State<AppointmentSuccessScreen> {
  // Palette
  static const Color primary = Color(0xFF087F6D);
  static const Color primarySoft = Color(0xFFE6F4F1);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF4F7F6);
  static const Color amber = Color(0xFFB45309);
  static const Color amberSoft = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEF2F2);

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', //
  ];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  bool _processing = false;
  bool _completed = false;

  String? _paymentId;
  String? _paymentMethod;
  String? _paymentStatus;
  String? _error;

  bool get _isCash => _paymentMethod == 'cash';

  String get _doctorName => widget.doctor['name']?.toString() ?? 'Doctor';

  String get _specialty =>
      widget.doctor['specialtyLabel']?.toString() ??
      widget.doctor['specialization']?.toString() ??
      'General';

  String get _hospital =>
      widget.doctor['hospital']?.toString() ?? 'General Clinic';

  String get _amount => _formatAmount(widget.amountMinor);

  String get _date {
    final d = widget.appointmentDate;
    return '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} '
        '${d.year}';
  }

  String get _initial {
    final name = _doctorName.replaceFirst(
      RegExp(r'^(dr\.?\s+)', caseSensitive: false),
      '',
    );
    return name.isEmpty ? 'D' : name.characters.first.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _restorePayment();
  }

  // ---------------------------------------------------------------------------
  // Logic (unchanged behaviour)
  // ---------------------------------------------------------------------------

  Future<void> _restorePayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final booking = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .get();

      if (!mounted || !booking.exists) return;

      final data = booking.data()!;

      if (data['userId'] != user.uid) return;

      final paymentId = data['paymentId']?.toString();
      final status = data['paymentStatus']?.toString();

      if (paymentId == null ||
          paymentId.isEmpty ||
          (status != 'demo_paid' && status != 'pending_cash')) {
        return;
      }

      await _loadPayment(paymentId);
    } catch (_) {
      // User can retry opening checkout if no payment exists.
    }
  }

  Future<void> _loadPayment(String paymentId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final payment = await FirebaseFirestore.instance
        .collection('payments')
        .doc(paymentId)
        .get();

    if (!mounted || !payment.exists) return;

    final data = payment.data()!;

    if (data['userId'] != user.uid ||
        data['bookingId'] != widget.appointmentId ||
        data['module'] != 'doctor' ||
        data['amountMinor'] != widget.amountMinor ||
        data['environment'] != 'demo') {
      return;
    }

    final status = data['status']?.toString();
    final method = data['method']?.toString();

    if ((status == 'demo_paid' && method == 'card') ||
        (status == 'pending_cash' && method == 'cash')) {
      setState(() {
        _paymentId = paymentId;
        _paymentStatus = status;
        _paymentMethod = method;
        _completed = true;
        _error = null;
      });
    }
  }

  Future<PaymentRequest> _createRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please log in first.');
    }

    final booking = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .get();

    if (!booking.exists) {
      throw StateError('Appointment not found.');
    }

    final data = booking.data()!;

    if (data['userId'] != user.uid) {
      throw StateError('Unauthorized appointment.');
    }

    if (data['status'] != 'awaiting_payment') {
      throw StateError('This appointment is not awaiting payment.');
    }

    if (data['amountMinor'] != widget.amountMinor) {
      throw StateError('Appointment amount mismatch.');
    }

    final displayName =
        user.displayName?.trim() ?? data['userName']?.toString().trim() ?? '';

    final parts =
        displayName.isEmpty ? <String>[] : displayName.split(RegExp(r'\s+'));

    return PaymentRequest(
      bookingId: widget.appointmentId,
      module: 'doctor',
      title: 'Doctor Consultation - $_doctorName',
      amountMinor: widget.amountMinor,
      firstName: parts.isNotEmpty ? parts.first : '',
      lastName: parts.length > 1 ? parts.skip(1).join(' ') : '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      address: '',
      city: '',
    );
  }

  Future<void> _startPayment() async {
    if (_processing || _completed) return;

    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      // Avoid opening checkout for a booking already paid.
      final booking = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .get();

      final existingId = booking.data()?['paymentId']?.toString();

      if (existingId != null && existingId.isNotEmpty) {
        await _loadPayment(existingId);

        if (_completed) return;
      }

      final request = await _createRequest();

      if (!mounted) return;

      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(request: request),
        ),
      );

      if (!mounted) return;

      if (completed == true) {
        final updated = await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointmentId)
            .get();

        final paymentId = updated.data()?['paymentId']?.toString();

        if (paymentId == null || paymentId.isEmpty) {
          throw StateError('Payment reference not found.');
        }

        await _loadPayment(paymentId);

        if (!_completed && mounted) {
          setState(() {
            _error = "We couldn't confirm your payment. Try again, or check "
                'My appointments.';
          });
        }
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error is StateError
            ? error.message
            : 'Something went wrong. Check your connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  void _openAppointments() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MyAppointmentsScreen(),
      ),
    );
  }

  void _backHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

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

  Future<void> _copy(String value, String message) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(message),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Shared pieces
  // ---------------------------------------------------------------------------

  Widget _doctorHeader() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: primarySoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initial,
              style: const TextStyle(
                color: primary,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _hospital,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotCell(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: muted),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ink,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotStrip() {
    return Container(
      color: surface,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _slotCell(Icons.calendar_today_rounded, 'Date', _date),
          const SizedBox(width: 12),
          _slotCell(Icons.schedule_rounded, 'Time', widget.appointmentTime),
          const SizedBox(width: 12),
          _slotCell(
            Icons.videocam_outlined,
            'Type',
            widget.consultationType,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: muted, fontSize: 13)),
          const SizedBox(width: 16),
          Flexible(child: value),
        ],
      ),
    );
  }

  Widget _copyable(String value, String toast) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _copy(value, toast),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.copy_rounded, size: 15, color: muted),
          ],
        ),
      ),
    );
  }

  Widget _appointmentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _doctorHeader(),
          _slotStrip(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Column(
              children: [
                _row(
                  'Booking reference',
                  _copyable(widget.appointmentId, 'Booking reference copied'),
                ),
                const Divider(height: 18, color: line),
                _row(
                  'Consultation fee',
                  Text(
                    'LKR $_amount',
                    style: const TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    final accent = _isCash ? amber : primary;
    final soft = _isCash ? amberSoft : primarySoft;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment',
            style: TextStyle(
              color: ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          _row(
            'Method',
            Text(
              _isCash ? 'Cash' : 'Demo card',
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _row(
            'Status',
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: soft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _paymentStatus == 'pending_cash' ? 'Pay at clinic' : 'Paid',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (_paymentId != null)
            _row(
              'Payment ID',
              _copyable(_paymentId!, 'Payment ID copied'),
            ),
          const SizedBox(height: 6),
          const Row(
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
        ],
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dangerSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: ink, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _primaryStyle() => ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size.fromHeight(54),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFB3CECA),
        disabledForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      );

  ButtonStyle _secondaryStyle() => OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );

  // ---------------------------------------------------------------------------
  // Screens
  // ---------------------------------------------------------------------------

  Widget _pendingBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const Text(
          'Review and pay',
          style: TextStyle(
            color: ink,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your slot is held. Pay by card or choose cash at checkout '
          'to confirm it.',
          style: TextStyle(color: muted, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 20),
        _appointmentCard(),
        if (_error != null) _errorBanner(),
        const SizedBox(height: 14),
        const Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 15, color: muted),
            SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _completedBody() {
    final accent = _isCash ? amber : primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const SizedBox(height: 8),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Opacity(
              opacity: ((scale - 0.6) / 0.4).clamp(0.0, 1.0),
              child: Transform.scale(scale: scale, child: child),
            ),
            child: Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(
                _isCash ? Icons.schedule_rounded : Icons.check_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _isCash ? 'Appointment booked' : 'Payment received',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ink,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCash
              ? 'Pay LKR $_amount in cash at the clinic to complete your '
                  'booking.'
              : 'Your appointment is confirmed.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 24),
        _appointmentCard(),
        const SizedBox(height: 14),
        _paymentCard(),
      ],
    );
  }

  Widget _bottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _completed
                ? [
                    ElevatedButton(
                      onPressed: _openAppointments,
                      style: _primaryStyle(),
                      child: const Text('View my appointments'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _backHome,
                      style: TextButton.styleFrom(
                        foregroundColor: muted,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('Back to home'),
                    ),
                  ]
                : [
                    ElevatedButton(
                      onPressed: _processing ? null : _startPayment,
                      style: _primaryStyle(),
                      child: _processing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : Text('Continue to pay LKR $_amount'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _openAppointments,
                      style: _secondaryStyle(),
                      child: const Text('View my appointments'),
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: ink,
          title: Text(
            _completed ? 'Confirmation' : 'Checkout',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              tooltip: 'Close',
              onPressed: _backHome,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey<bool>(_completed),
              child: _completed ? _completedBody() : _pendingBody(),
            ),
          ),
        ),
        bottomNavigationBar: _bottomBar(),
      ),
    );
  }
}