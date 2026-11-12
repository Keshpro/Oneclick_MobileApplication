
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_appointments_screen.dart';

typedef DoctorPaymentHandler = Future<String?> Function(
  String appointmentId,
);

enum _PaymentView {
  checkout,
  processing,
  checking,
  success,
}

class AppointmentSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String consultationType;

  // Existing draft appointment document ID.
  final String appointmentId;

  // Amount supplied by the booking flow.
  // LKR 2500.00 = 250000 minor units.
  final int amountMinor;

  // Must initiate the real sandbox gateway payment.
  // Return a real payment document ID after gateway flow.
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
  }) : assert(amountMinor > 0);

  @override
  State<AppointmentSuccessScreen> createState() =>
      _AppointmentSuccessScreenState();
}

class _AppointmentSuccessScreenState
    extends State<AppointmentSuccessScreen> {
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF075B60);
  static const Color background = Color(0xFFF7FAF9);
  static const Color textDark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  _PaymentView _view = _PaymentView.checkout;

  String? _paymentId;
  String? _errorMessage;

  String get _doctorName {
    final value =
        widget.doctor['name']?.toString().trim() ?? '';

    return value.isEmpty ? 'Doctor' : value;
  }

  String get _specialty {
    return widget.doctor['specialtyLabel']
            ?.toString() ??
        'General';
  }

  String get _hospital {
    return widget.doctor['hospital']?.toString() ??
        'Hospital';
  }

  String get _formattedAmount {
    final whole = widget.amountMinor ~/ 100;
    final cents =
        (widget.amountMinor % 100).toString().padLeft(2, '0');

    final digits = whole.toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

    return 'LKR $formatted.$cents';
  }

  String get _formattedDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final date = widget.appointmentDate;

    return '${days[date.weekday - 1]}, '
        '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  Future<bool> _verifyPaymentAndAppointment(
    String paymentId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null ||
        widget.appointmentId.trim().isEmpty ||
        paymentId.trim().isEmpty) {
      return false;
    }

    final db = FirebaseFirestore.instance;

    // Read authoritative server records.
    final paymentSnapshot = await db
        .collection('payments')
        .doc(paymentId)
        .get(
          const GetOptions(source: Source.server),
        );

    if (!paymentSnapshot.exists) return false;

    final payment = paymentSnapshot.data()!;

    final paymentVerified =
        payment['status'] == 'paid' &&
        payment['userId'] == user.uid &&
        payment['orderId'] == widget.appointmentId &&
        payment['module'] == 'doctor' &&
        payment['currency'] == 'LKR';

    if (!paymentVerified) return false;

    // Doctor appointment must be confirmed by backend.
    final appointmentSnapshot = await db
        .collection('appointments')
        .doc(widget.appointmentId)
        .get(
          const GetOptions(source: Source.server),
        );

    if (!appointmentSnapshot.exists) return false;

    final appointment = appointmentSnapshot.data()!;

    final appointmentConfirmed =
        appointment['userId'] == user.uid &&
        appointment['status'] == 'confirmed' &&
        appointment['paymentId'] == paymentId;

    return appointmentConfirmed;
  }

  Future<void> _startPayment() async {
    if (_view != _PaymentView.checkout) return;

    final handler = widget.onStartPayment;

    if (handler == null) {
      setState(() {
        _errorMessage =
            'PayHere Sandbox is not connected yet.';
      });
      return;
    }

    setState(() {
      _view = _PaymentView.processing;
      _errorMessage = null;
    });

    try {
      // Gateway integration is provided by the caller.
      final paymentId =
          await handler(widget.appointmentId);

      if (!mounted) return;

      if (paymentId == null || paymentId.trim().isEmpty) {
        setState(() {
          _view = _PaymentView.checkout;
          _errorMessage =
              'Payment was not completed. No appointment '
              'has been confirmed.';
        });
        return;
      }

      _paymentId = paymentId;

      // A gateway callback does not prove payment success.
      await _checkConfirmation();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _view = _PaymentView.checkout;
        _errorMessage =
            'Could not complete the payment request. '
            'Check your payment history before retrying.';
      });
    }
  }

  Future<void> _checkConfirmation() async {
    final paymentId = _paymentId;

    if (paymentId == null) return;

    setState(() {
      _view = _PaymentView.checking;
      _errorMessage = null;
    });

    try {
      final confirmed =
          await _verifyPaymentAndAppointment(paymentId);

      if (!mounted) return;

      if (confirmed) {
        setState(() {
          _view = _PaymentView.success;
        });
      } else {
        setState(() {
          _view = _PaymentView.checkout;
          _errorMessage =
              'Payment or appointment confirmation '
              'could not be verified yet. '
              'Use Check Confirmation again. '
              'Do not pay twice.';
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _view = _PaymentView.checkout;
        _errorMessage =
            'Unable to check the confirmation right now. '
            'Please check again. Do not pay twice.';
      });
    }
  }

  void _openMyAppointments() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MyAppointmentsScreen(),
      ),
    );
  }

  void _backHome() {
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = _view == _PaymentView.success;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: completed
              ? primary
              : background,
          foregroundColor: completed
              ? Colors.white
              : textDark,
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: true,
          title: Text(
            completed
                ? 'Booking Confirmation'
                : 'OneClick Payment',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Back to Home',
              onPressed: _backHome,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: _view == _PaymentView.processing ||
                _view == _PaymentView.checking
            ? _buildProcessingScreen()
            : completed
                ? _buildSuccessScreen()
                : _buildCheckoutScreen(),
      ),
    );
  }

  // ============================================================
  // CHECKOUT SCREEN
  // ============================================================

  Widget _buildCheckoutScreen() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _amountCard(),
                const SizedBox(height: 25),

                _sectionTitle('Doctor Appointment'),
                const SizedBox(height: 12),
                _doctorCard(),

                const SizedBox(height: 22),

                _sectionTitle('Appointment Details'),
                const SizedBox(height: 12),
                _appointmentDetailsCard(),

                const SizedBox(height: 22),

                _sectionTitle('Payment Method'),
                const SizedBox(height: 12),
                _paymentMethodCard(),

                const SizedBox(height: 18),
                _securityCard(),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 17),
                  _errorCard(_errorMessage!),
                ],
              ],
            ),
          ),
          _checkoutBottomBar(),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primary,
            primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 14),
          const Text(
            'CONSULTATION FEE',
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.2,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formattedAmount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Doctor Appointment Payment',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorCard() {
    return _whiteCard(
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: primary,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _specialty,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: muted,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _hospital,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentDetailsCard() {
    return _whiteCard(
      child: Column(
        children: [
          _infoRow(
            Icons.calendar_month_outlined,
            'Date',
            _formattedDate,
          ),
          const SizedBox(height: 17),
          _infoRow(
            Icons.schedule_rounded,
            'Time',
            widget.appointmentTime,
          ),
          const SizedBox(height: 17),
          _infoRow(
            widget.consultationType == 'Video'
                ? Icons.videocam_outlined
                : Icons.local_hospital_outlined,
            'Consultation',
            widget.consultationType,
          ),
          const SizedBox(height: 17),
          _infoRow(
            Icons.confirmation_number_outlined,
            'Reference',
            widget.appointmentId,
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Payable',
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _formattedAmount,
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodCard() {
    return _whiteCard(
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
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Online Payment',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'PayHere Sandbox Gateway',
                  style: TextStyle(
                    color: muted,
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

  Widget _securityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(17),
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
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your appointment will only be confirmed '
              'after the payment is verified by the '
              'OneClick backend. Payment details are '
              'handled by the gateway.',
              style: TextStyle(
                color: primaryDark,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkoutBottomBar() {
    final gatewayReady =
        widget.onStartPayment != null;

    final canPay =
        gatewayReady && _paymentId == null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20, 15, 20, 19,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Amount to pay',
                    style: TextStyle(
                      color: muted,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  _formattedAmount,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _paymentId != null
                    ? _checkConfirmation
                    : canPay
                        ? _startPayment
                        : null,
                icon: Icon(
                  _paymentId != null
                      ? Icons.refresh_rounded
                      : Icons.lock_rounded,
                ),
                label: Text(
                  _paymentId != null
                      ? 'Check Confirmation'
                      : gatewayReady
                          ? 'Pay Securely'
                          : 'Gateway Setup Required',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFB7D2CF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            if (!gatewayReady) ...[
              const SizedBox(height: 8),
              const Text(
                'Connect PayHere Sandbox to enable payment.',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 5),
            TextButton(
              onPressed: _openMyAppointments,
              child: const Text(
                'View My Appointments',
                style: TextStyle(color: primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROCESSING SCREEN
  // ============================================================

  Widget _buildProcessingScreen() {
    final checking =
        _view == _PaymentView.checking;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: primary,
                strokeWidth: 4,
              ),
              const SizedBox(height: 27),
              Text(
                checking
                    ? 'Verifying Payment'
                    : 'Connecting to Payment Gateway',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                checking
                    ? 'Checking your payment and '
                        'appointment confirmation.'
                    : 'Complete the payment using '
                        'the secure gateway.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT SUCCESS + APPOINTMENT SUCCESS
  // ============================================================

  Widget _buildSuccessScreen() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20, 30, 20, 20,
              ),
              children: [
                Center(
                  child: Container(
                    width: 106,
                    height: 106,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF86EFAC),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 78,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Doctor Appointment is Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 11),
                const Text(
                  'Your payment has been verified '
                  'and your appointment is booked.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 26),

                _doctorCard(),

                const SizedBox(height: 17),

                _appointmentDetailsCard(),

                const SizedBox(height: 17),

                _verifiedPaymentCard(),

                const SizedBox(height: 17),

                _reminderCard(),
              ],
            ),
          ),
          _successBottomBar(),
        ],
      ),
    );
  }

  Widget _verifiedPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFD1FAE5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Color(0xFF16A34A),
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Verified',
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Paid: $_formattedAmount',
                  style: const TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Transaction: ${_paymentId ?? ''}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFFEF3C7),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFFD97706),
            size: 23,
          ),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Appointment Reminder\n'
              'Please be ready a few minutes before '
              'your scheduled consultation.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20, 13, 20, 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openMyAppointments,
                icon: const Icon(
                  Icons.calendar_month_rounded,
                ),
                label: const Text(
                  'View My Appointments',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: _backHome,
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Home'),
              style: TextButton.styleFrom(
                foregroundColor: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SHARED UI HELPERS
  // ============================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
