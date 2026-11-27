import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oneclick/features/payment/models/payment_request.dart';
import 'package:oneclick/features/payment/screens/checkout_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // ======================================================
  // THEME
  // ======================================================

  static const Color navy = Color(0xFF1E293B);
  static const Color primary = Color(0xFF087F6D);
  static const Color primarySoft = Color(0xFFE6F4F1);
  static const Color background = Color(0xFFF8FAFC);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);

  static const Color green = Color(0xFF059669);
  static const Color amber = Color(0xFFD97706);
  static const Color blue = Color(0xFF2563EB);
  static const Color red = Color(0xFFDC2626);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _filter = 'All';

  final Set<String> _processingIds = {};

  String? _streamUid;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _bookingStream;

  late final Stream<User?> _authStream;

  static const List<String> _filters = [
    'All',
    'Pending',
    'Approved',
    'Completed',
    'Rejected',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _authStream = _auth.authStateChanges();
  }

  // ======================================================
  // FIRESTORE STREAM
  // ======================================================

  void _bindStream(String userId) {
    if (_streamUid == userId) return;

    _streamUid = userId;

    _bookingStream = _db
        .collection('work_appointments')
        .where('customerId', isEqualTo: userId)
        .snapshots();
  }

  // ======================================================
  // DATA HELPERS
  // ======================================================

  String _text(dynamic value, [String fallback = '—']) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }

  String _status(Map<String, dynamic> data) {
    return _text(data['status'], 'unknown').toLowerCase();
  }

  String _paymentStatus(Map<String, dynamic> data) {
    return _text(data['paymentStatus'], 'unpaid').toLowerCase();
  }

  bool _isApproved(Map<String, dynamic> data) {
    final status = _status(data);

    return status == 'accepted' || status == 'approved';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
      case 'approved':
        return 'Approved';

      case 'pending':
        return 'Pending';

      case 'completed':
        return 'Completed';

      case 'rejected':
        return 'Rejected';

      case 'cancelled':
        return 'Cancelled';

      default:
        return 'Unknown';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
      case 'approved':
        return green;

      case 'completed':
        return blue;

      case 'pending':
        return amber;

      case 'rejected':
      case 'cancelled':
        return red;

      default:
        return muted;
    }
  }

  String _paymentLabel(String status) {
    switch (status) {
      case 'demo_paid':
        return 'Demo Paid';

      case 'pending_cash':
        return 'Cash Pending';

      case 'paid':
        return 'Paid';

      case 'failed':
        return 'Payment Failed';

      case 'refunded':
        return 'Refunded';

      case 'unpaid':
        return 'Not Paid';

      default:
        return status.replaceAll('_', ' ');
    }
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'demo_paid':
      case 'paid':
        return green;

      case 'pending_cash':
      case 'unpaid':
        return amber;

      case 'failed':
        return red;

      default:
        return muted;
    }
  }

  int? _amountMinor(Map<String, dynamic> data) {
    final value = data['amountMinor'];

    if (value is num && value.isFinite && value > 0 && value == value.toInt()) {
      return value.toInt();
    }

    return null;
  }

  String _money(int minor) {
    final whole = minor ~/ 100;

    final cents = (minor % 100).toString().padLeft(2, '0');

    final digits = whole.toString();

    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return 'LKR $buffer.$cents';
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  String _dateText(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _dateTimeText(dynamic value) {
    final date = _parseDate(value);

    if (date == null) {
      return 'Date unavailable';
    }

    final time = TimeOfDay.fromDateTime(date);

    return '${_dateText(date)} at '
        '${time.format(context)}';
  }

  String _appointmentDate(Map<String, dynamic> data) {
    final date = _parseDate(data['appointmentDate']);

    if (date != null) {
      return _dateText(date);
    }

    final legacyDate = _parseDate(data['date']);

    return legacyDate != null
        ? _dateText(legacyDate)
        : _text(data['date'], 'Date unavailable');
  }

  String _appointmentTime(Map<String, dynamic> data) {
    final date = _parseDate(data['appointmentDate']);

    if (date != null) {
      return TimeOfDay.fromDateTime(date).format(context);
    }

    return _text(data['time'], 'Time unavailable');
  }

  String _initial(String name) {
    final value = name.trim();

    return value.isEmpty ? 'W' : value.characters.first.toUpperCase();
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? red : primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ======================================================
  // PAYMENT ELIGIBILITY
  // ======================================================

  bool _canPay(Map<String, dynamic> data) {
    final paymentId = _text(data['paymentId'], '');

    final paymentStatus = _paymentStatus(data);

    return data['customerId'] == _auth.currentUser?.uid &&
        data['serviceType'] == 'quickfix' &&
        data['currency'] == 'LKR' &&
        _isApproved(data) &&
        paymentId.isEmpty &&
        paymentStatus == 'unpaid' &&
        _amountMinor(data) != null;
  }

  // ======================================================
  // COMMON PAYMENT SYSTEM
  // ======================================================

  Future<void> _startPayment(String bookingId) async {
    if (_processingIds.contains(bookingId)) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      _message('Please sign in before making a payment.', error: true);

      return;
    }

    setState(() {
      _processingIds.add(bookingId);
    });

    try {
      // Read latest booking directly from server.
      final bookingSnapshot = await _db
          .collection('work_appointments')
          .doc(bookingId)
          .get(const GetOptions(source: Source.server));

      if (!mounted) return;

      if (_auth.currentUser?.uid != user.uid) {
        throw StateError('Your login session has changed.');
      }

      if (!bookingSnapshot.exists) {
        throw StateError('Booking no longer exists.');
      }

      final booking = bookingSnapshot.data()!;

      if (booking['customerId'] != user.uid) {
        throw StateError('You cannot pay for this booking.');
      }

      if (!_canPay(booking)) {
        throw StateError(
          'This booking is not eligible for payment. '
          'It may already have a payment record or '
          'may no longer be approved.',
        );
      }

      final amountMinor = _amountMinor(booking)!;

      final category = _text(booking['category'], 'QuickFix Service');

      final customerName = _text(
        booking['customerName'] ?? user.displayName ?? user.email,
        'Customer',
      );

      final nameParts = customerName.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Reuse existing PaymentRequest model.
      final request = PaymentRequest(
        module: 'quickfix',
        bookingId: bookingId,
        title: 'QuickFix - $category',
        amountMinor: amountMinor,
        firstName: firstName,
        lastName: lastName,
        email: _text(booking['customerEmail'] ?? user.email, ''),
        phone: _text(booking['customerPhone'] ?? booking['phone'], ''),
        address: _text(booking['address'], ''),
        city: _text(booking['city'], ''),
      );

      // Open existing Common Checkout Screen.
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => CheckoutScreen(request: request)),
      );

      if (!mounted || _auth.currentUser?.uid != user.uid) {
        return;
      }

      if (result == true) {
        // Read the actual stored payment state.
        // Do not manually mark a payment as successful.

        final updated = await _db
            .collection('work_appointments')
            .doc(bookingId)
            .get(const GetOptions(source: Source.server));

        if (!mounted || _auth.currentUser?.uid != user.uid) {
          return;
        }

        final data = updated.data();

        if (data == null) {
          _message('Booking details are unavailable.', error: true);

          return;
        }

        final status = _paymentStatus(data);

        if (status == 'demo_paid') {
          _message('Demo payment recorded successfully.');
        } else if (status == 'pending_cash') {
          _message(
            'Cash payment selected. '
            'Payment is still pending.',
          );
        } else {
          _message('Please check your booking payment status.');
        }

        // Firestore stream automatically refreshes
        // the booking card.
      }
    } catch (error) {
      _message(
        error is StateError
            ? error.message
            : 'Unable to open or verify payment. '
                  'Please refresh your booking and try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingIds.remove(bookingId);
        });
      }
    }
  }

  // ======================================================
  // COMMON UI COMPONENTS
  // ======================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: line),
      ),
      child: child,
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _information(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: muted),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: muted, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notice({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 13),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 43),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ink,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // BOOKING DETAILS
  // ======================================================

  void _showBookingDetails(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final amount = _amountMinor(data);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    color: ink,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                _detailRow('Booking ID', doc.id),

                _detailRow('Worker', _text(data['workerName'])),

                _detailRow('Service', _text(data['category'])),

                _detailRow('Date', _appointmentDate(data)),

                _detailRow('Time', _appointmentTime(data)),

                _detailRow(
                  'Duration',
                  data['durationHours'] == null
                      ? 'Not recorded'
                      : '${data['durationHours']} hour(s)',
                ),

                _detailRow('Address', _text(data['address'])),

                _detailRow('Issue', _text(data['issue'], 'Not specified')),

                const Divider(),

                _detailRow('Booking status', _statusLabel(_status(data))),

                _detailRow(
                  'Amount',
                  amount == null ? 'Not configured' : _money(amount),
                ),

                _detailRow(
                  'Payment status',
                  _paymentLabel(_paymentStatus(data)),
                ),

                _detailRow(
                  'Payment method',
                  _text(data['paymentMethod'], 'Not selected'),
                ),

                _detailRow('Created', _dateTimeText(data['createdAt'])),

                if (data['completedAt'] != null)
                  _detailRow('Completed', _dateTimeText(data['completedAt'])),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: navy),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ======================================================
  // TRANSACTION DETAILS
  // ======================================================

  void _showTransactionDetails(Map<String, dynamic> booking) {
    final paymentId = _text(booking['paymentId'], '');

    final userId = _auth.currentUser?.uid;

    if (paymentId.isEmpty || paymentId.contains('/') || userId == null) {
      return;
    }

    final stream = _db.collection('payments').doc(paymentId).snapshots();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(30),
                  child: Text('Unable to load transaction details.'),
                );
              }

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(
                    heightFactor: 1,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final data = snapshot.data!.data();

              if (data == null ||
                  data['userId'] != userId ||
                  _auth.currentUser?.uid != userId ||
                  data['module'] != 'quickfix' ||
                  data['bookingId'] != booking['bookingId']) {
                return const Padding(
                  padding: EdgeInsets.all(30),
                  child: Text('Transaction unavailable.'),
                );
              }

              final amount = _amountMinor(data);

              final status = _text(data['status'], 'unknown').toLowerCase();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _paymentColor(status).withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status == 'demo_paid' || status == 'paid'
                            ? Icons.check_circle_outline
                            : Icons.receipt_long_outlined,
                        color: _paymentColor(status),
                        size: 39,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Transaction Details',
                      style: TextStyle(
                        color: ink,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      amount == null ? 'Amount unavailable' : _money(amount),
                      style: const TextStyle(
                        color: ink,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 9),

                    _pill(_paymentLabel(status), _paymentColor(status)),

                    const SizedBox(height: 20),

                    _detailRow('Payment ID', paymentId),

                    _detailRow('Booking ID', _text(data['bookingId'])),

                    _detailRow('Worker', _text(data['workerName'])),

                    _detailRow('Service', _text(data['title'])),

                    _detailRow('Payment method', _text(data['method'])),

                    _detailRow(
                      'Transaction date',
                      _dateTimeText(data['createdAt']),
                    ),

                    _detailRow('Environment', _text(data['environment'])),

                    if (data['isRealPayment'] == false)
                      _notice(
                        icon: Icons.info_outline,
                        message:
                            'Demo transaction. '
                            'No real money was charged.',
                        color: primary,
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: navy),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ======================================================
  // BOOKING OVERVIEW
  // ======================================================

  Widget _overview(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final pending = docs.where((doc) {
      return _status(doc.data()) == 'pending';
    }).length;

    final approved = docs.where((doc) {
      return _isApproved(doc.data());
    }).length;

    final completed = docs.where((doc) {
      return _status(doc.data()) == 'completed';
    }).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR QUICKFIX ACTIVITY',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '${docs.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Text(
            'Total Bookings',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
          ),

          const SizedBox(height: 18),

          const Divider(color: Color(0x33FFFFFF)),

          const SizedBox(height: 10),

          Row(
            children: [
              _overviewStat('Pending', pending, const Color(0xFFFCD34D)),

              _overviewStat('Approved', approved, const Color(0xFF86EFAC)),

              _overviewStat('Completed', completed, const Color(0xFF93C5FD)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewStat(String label, int count, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BOOKING STATUS NOTICE
  // ======================================================

  Widget _bookingNotice(Map<String, dynamic> data) {
    final status = _status(data);

    final paymentStatus = _paymentStatus(data);

    if (status == 'pending') {
      return _notice(
        icon: Icons.schedule_outlined,
        message:
            'Waiting for worker approval. '
            'You can pay once the request is approved.',
        color: amber,
      );
    }

    if (status == 'rejected') {
      return _notice(
        icon: Icons.cancel_outlined,
        message:
            'Your booking request was rejected '
            'by the worker.',
        color: red,
      );
    }

    if (status == 'cancelled') {
      return _notice(
        icon: Icons.event_busy_outlined,
        message: 'This appointment was cancelled.',
        color: red,
      );
    }

    if (status == 'completed') {
      return _notice(
        icon: Icons.task_alt_rounded,
        message: paymentStatus == 'pending_cash'
            ? 'Service completed. Cash payment is '
                  'still pending confirmation.'
            : paymentStatus == 'demo_paid' || paymentStatus == 'paid'
            ? 'Your service has been completed.'
            : 'Service completed. '
                  'No successful payment is recorded.',
        color: blue,
      );
    }

    if (paymentStatus == 'demo_paid') {
      return _notice(
        icon: Icons.verified_outlined,
        message:
            'Demo payment recorded successfully. '
            'No real money was charged.',
        color: green,
      );
    }

    if (paymentStatus == 'pending_cash') {
      return _notice(
        icon: Icons.payments_outlined,
        message:
            'Cash payment selected. '
            'Payment is not yet confirmed.',
        color: amber,
      );
    }

    if (_canPay(data)) {
      return _notice(
        icon: Icons.check_circle_outline,
        message:
            'Your booking has been approved. '
            'You can now proceed to payment.',
        color: green,
      );
    }

    if (_isApproved(data)) {
      return _notice(
        icon: Icons.info_outline,
        message:
            'Payment is unavailable for this booking. '
            'The booking may require updated payment details.',
        color: amber,
      );
    }

    return const SizedBox.shrink();
  }

  // ======================================================
  // BOOKING CARD
  // ======================================================

  Widget _bookingCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    final status = _status(data);

    final paymentStatus = _paymentStatus(data);

    final workerName = _text(data['workerName'], 'Worker');

    final category = _text(data['category'], 'QuickFix');

    final amount = _amountMinor(data);

    final paymentId = _text(data['paymentId'], '');

    final processing = _processingIds.contains(doc.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker information
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: primarySoft,
                  child: Text(
                    _initial(workerName),
                    style: const TextStyle(
                      color: primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        category,
                        style: const TextStyle(
                          color: primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _pill(_statusLabel(status), _statusColor(status)),
              ],
            ),

            const SizedBox(height: 15),

            const Divider(color: line),

            const SizedBox(height: 8),

            // Correct appointment date and time.
            // Never use createdAt as appointment date.
            _information(Icons.calendar_today_outlined, _appointmentDate(data)),

            _information(Icons.access_time_rounded, _appointmentTime(data)),

            if (data['durationHours'] != null)
              _information(
                Icons.timelapse_outlined,
                '${data['durationHours']} hour(s)',
              ),

            _information(
              Icons.location_on_outlined,
              _text(data['address'], 'Address unavailable'),
            ),

            if (_text(data['issue'], '').isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _text(data['issue']),
                  style: const TextStyle(color: ink, fontSize: 13, height: 1.4),
                ),
              ),

            const SizedBox(height: 15),

            // Payment summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Amount',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    amount == null ? 'Not configured' : _money(amount),
                    style: const TextStyle(
                      color: ink,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill(
                        _paymentLabel(paymentStatus),
                        _paymentColor(paymentStatus),
                      ),

                      if (data['paymentMethod'] != null)
                        _pill(
                          _text(data['paymentMethod']).toUpperCase(),
                          muted,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            _bookingNotice(data),

            const SizedBox(height: 14),

            // View booking details
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: navy,
                  side: const BorderSide(color: line),
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: processing
                    ? null
                    : () {
                        _showBookingDetails(doc);
                      },
                icon: const Icon(Icons.info_outline, size: 19),
                label: const Text('View Booking Details'),
              ),
            ),

            // Pay Now is only available for
            // approved, unpaid bookings.
            if (_canPay(data)) ...[
              const SizedBox(height: 9),

              SizedBox(
                width: double.infinity,
                height: 51,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),

                  onPressed: processing
                      ? null
                      : () {
                          _startPayment(doc.id);
                        },

                  icon: processing
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.credit_card_rounded),

                  label: Text(
                    processing ? 'Processing...' : 'Pay Now',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],

            // Transaction history
            if (paymentId.isNotEmpty) ...[
              const SizedBox(height: 9),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: processing
                      ? null
                      : () {
                          _showTransactionDetails({
                            ...data,
                            'bookingId': doc.id,
                          });
                        },
                  icon: const Icon(Icons.receipt_long_outlined, size: 20),
                  label: const Text('View Transaction'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ======================================================
  // BOOKING FILTERS
  // ======================================================

  Widget _filterBar() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _filters.length,

        separatorBuilder: (_, _) => const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final filter = _filters[index];

          final selected = _filter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            showCheckmark: false,
            selectedColor: navy,
            backgroundColor: Colors.white,

            side: BorderSide(color: selected ? navy : line),

            labelStyle: TextStyle(
              color: selected ? Colors.white : ink,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),

            onSelected: (_) {
              setState(() {
                _filter = filter;
              });
            },
          );
        },
      ),
    );
  }

  // ======================================================
  // BOOKING LIST
  // ======================================================

  Widget _bookingList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final filtered = docs.where((doc) {
      final data = doc.data();

      if (_filter == 'All') {
        return true;
      }

      if (_filter == 'Approved') {
        return _isApproved(data);
      }

      return _status(data) == _filter.toLowerCase();
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _overview(docs),
        ),

        const SizedBox(height: 8),

        _filterBar(),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 13),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'My Appointments',
                  style: TextStyle(
                    color: ink,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                '${filtered.length} bookings',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? _emptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No bookings found',
                  message: _filter == 'All'
                      ? 'Your QuickFix appointments '
                            'will appear here.'
                      : 'No appointments match '
                            'the selected filter.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _bookingCard(filtered[index]);
                  },
                ),
        ),
      ],
    );
  }

  // ======================================================
  // REAL-TIME BOOKING CONTENT
  // ======================================================

  Widget _bookingContent(String userId) {
    _bindStream(userId);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: ValueKey(userId),
      stream: _bookingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _emptyState(
            icon: Icons.error_outline_rounded,
            title: 'Unable to load bookings',
            message:
                'Check your internet connection '
                'and Firestore permissions.',
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: primary));
        }

        final docs =
            snapshot.data!.docs.where((doc) {
              final data = doc.data();

              // Support older QuickFix bookings.
              // Exclude other worker service modules.

              return data['customerId'] == userId &&
                  (data['serviceType'] == 'quickfix' ||
                      data['serviceType'] == null);
            }).toList()..sort((a, b) {
              final first = _parseDate(a.data()['createdAt']);

              final second = _parseDate(b.data()['createdAt']);

              return (second ?? DateTime(1970)).compareTo(
                first ?? DateTime(1970),
              );
            });

        return _bookingList(docs);
      },
    );
  }

  // ======================================================
  // MAIN BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        foregroundColor: navy,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      body: StreamBuilder<User?>(
        stream: _authStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (snapshot.hasError) {
            return _emptyState(
              icon: Icons.error_outline,
              title: 'Authentication unavailable',
              message: 'Please check your login session.',
            );
          }

          final user = snapshot.data;

          if (user == null) {
            _streamUid = null;
            _bookingStream = null;

            return _emptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Sign in required',
              message:
                  'Please sign in to view '
                  'your QuickFix bookings.',
            );
          }

          return _bookingContent(user.uid);
        },
      ),
    );
  }
}
