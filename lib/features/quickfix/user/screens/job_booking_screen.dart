
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'booking_success_screen.dart';

class JobBookingScreen extends StatefulWidget {
  final Map<String, dynamic> worker;

  const JobBookingScreen({
    super.key,
    required this.worker,
  });

  @override
  State<JobBookingScreen> createState() =>
      _JobBookingScreenState();
}

class _JobBookingScreenState
    extends State<JobBookingScreen> {
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
  static const Color danger = Color(0xFFDC2626);

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _addressController =
      TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _durationHours = 1;

  bool _isSubmitting = false;

  late final String _workerId;

  late final DocumentReference<Map<String, dynamic>>
      _bookingRef;

  Stream<DocumentSnapshot<Map<String, dynamic>>>?
      _workerStream;

  // ======================================================
  // INITIALIZATION
  // ======================================================

  @override
  void initState() {
    super.initState();

    _workerId = (
      widget.worker['id'] ??
      widget.worker['uid'] ??
      ''
    ).toString().trim();

    _bookingRef = _db
        .collection('work_appointments')
        .doc();

    if (_workerId.isNotEmpty &&
        !_workerId.contains('/')) {
      _workerStream = _db
          .collection('workers')
          .doc(_workerId)
          .snapshots();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  // ======================================================
  // DATA HELPERS
  // ======================================================

  String _text(
    dynamic value, [
    String fallback = '—',
  ]) {
    final result =
        value?.toString().trim() ?? '';

    return result.isEmpty
        ? fallback
        : result;
  }

  int? _hourlyRateMinor(
    Map<String, dynamic> worker,
  ) {
    final details = worker['providerDetails'];

    final rawRate =
        (details is Map
            ? details['hourlyRate']
            : null) ??
        worker['hourlyRate'] ??
        worker['rate'];

    final rate = rawRate is num
        ? rawRate.toDouble()
        : double.tryParse(
            rawRate?.toString().trim() ?? '',
          );

    if (rate == null ||
        !rate.isFinite ||
        rate <= 0) {
      return null;
    }

    final minor = (rate * 100).round();

    return minor > 0 ? minor : null;
  }

  bool _isAvailable(
    Map<String, dynamic> worker,
  ) {
    return worker['isAvailable'] == true;
  }

  DateTime? get _appointmentDateTime {
    if (_selectedDate == null ||
        _selectedTime == null) {
      return null;
    }

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _money(int amountMinor) {
    final whole = amountMinor ~/ 100;

    final cents = (amountMinor % 100)
        .toString()
        .padLeft(2, '0');

    final digits = whole.toString();

    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 &&
          (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return 'LKR $buffer.$cents';
  }

  void _message(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              error ? danger : primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ======================================================
  // DATE SELECTION
  // ======================================================

  Future<void> _selectDate() async {
    if (_isSubmitting) return;

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final lastDate =
        today.add(const Duration(days: 30));

    final previousDate = _selectedDate;

    final initialDate =
        previousDate != null &&
                !previousDate.isBefore(today) &&
                !previousDate.isAfter(lastDate)
            ? previousDate
            : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: navy,
              onPrimary: Colors.white,
              onSurface: ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedDate = picked;
    });
  }

  // ======================================================
  // TIME SELECTION
  // ======================================================

  Future<void> _selectTime() async {
    if (_isSubmitting) return;

    final picked = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: navy,
              onPrimary: Colors.white,
              onSurface: ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedTime = picked;
    });
  }

  // ======================================================
  // BOOKING REVIEW
  // ======================================================

  Future<bool> _confirmBooking({
    required String workerName,
    required String category,
    required int amountMinor,
    required String date,
    required String time,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Review Booking',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _summaryRow(
                  'Worker',
                  workerName,
                ),
                _summaryRow(
                  'Service',
                  category,
                ),
                _summaryRow(
                  'Date',
                  date,
                ),
                _summaryRow(
                  'Time',
                  time,
                ),
                _summaryRow(
                  'Duration',
                  '$_durationHours hour(s)',
                ),

                const Divider(),

                _summaryRow(
                  'Estimated total',
                  _money(amountMinor),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primarySoft,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Your request will be sent to the worker. '
                    'You can make the payment after the worker '
                    'approves your appointment.',
                    style: TextStyle(
                      color: primary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Back'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Send Request',
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  // ======================================================
  // SUBMIT BOOKING
  // ======================================================

  Future<void> _submitBooking(
    Map<String, dynamic> displayedWorker,
  ) async {
    if (_isSubmitting) return;

    if (!(_formKey.currentState?.validate() ??
        false)) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null) {
      _message(
        'Please sign in before making a booking.',
        error: true,
      );

      return;
    }

    if (_workerId.isEmpty ||
        _workerId.contains('/')) {
      _message(
        'Invalid worker information.',
        error: true,
      );

      return;
    }

    if (_workerId == user.uid) {
      _message(
        'You cannot book your own worker account.',
        error: true,
      );

      return;
    }

    final appointmentDate =
        _appointmentDateTime;

    if (appointmentDate == null) {
      _message(
        'Please select the appointment date and time.',
        error: true,
      );

      return;
    }

    final now = DateTime.now();

    if (!appointmentDate.isAfter(now)) {
      _message(
        'Please select a future appointment time.',
        error: true,
      );

      return;
    }

    if (!_isAvailable(displayedWorker)) {
      _message(
        'This worker is currently unavailable.',
        error: true,
      );

      return;
    }

    final displayedRate =
        _hourlyRateMinor(displayedWorker);

    if (displayedRate == null) {
      _message(
        'The worker has not configured a valid hourly rate.',
        error: true,
      );

      return;
    }

    final duration = _durationHours;

    if (duration < 1 || duration > 8) {
      _message(
        'Please select a valid service duration.',
        error: true,
      );

      return;
    }

    final amountMinor =
        displayedRate * duration;

    final formattedDate =
        _formatDate(appointmentDate);

    final formattedTime =
        _selectedTime!.format(context);

    final address =
        _addressController.text.trim();

    final issue =
        _descriptionController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final confirmed = await _confirmBooking(
        workerName: _text(
          displayedWorker['name'],
          'Worker',
        ),
        category: _text(
          displayedWorker['category'],
          'QuickFix',
        ),
        amountMinor: amountMinor,
        date: formattedDate,
        time: formattedTime,
      );

      if (!confirmed || !mounted) return;

      if (_auth.currentUser?.uid != user.uid) {
        throw StateError(
          'Your login session has changed.',
        );
      }

      final workerRef = _db
          .collection('workers')
          .doc(_workerId);

      final savedWorker =
          await _db.runTransaction<
              Map<String, dynamic>>(
        (transaction) async {
          // --------------------------------------------
          // Read existing booking and worker.
          // All reads happen before writes.
          // --------------------------------------------

          final existingBooking =
              await transaction.get(_bookingRef);

          final workerSnapshot =
              await transaction.get(workerRef);

          if (_auth.currentUser?.uid != user.uid) {
            throw StateError(
              'Your login session has changed.',
            );
          }

          if (existingBooking.exists) {
            final existing =
                existingBooking.data()!;

            if (existing['customerId'] != user.uid ||
                existing['workerId'] != _workerId) {
              throw StateError(
                'Invalid existing booking.',
              );
            }

            return <String, dynamic>{
              'id': _workerId,
              'name': existing['workerName'],
              'category': existing['category'],
            };
          }

          if (!workerSnapshot.exists) {
            throw StateError(
              'Worker profile no longer exists.',
            );
          }

          final worker =
              workerSnapshot.data()!;

          // --------------------------------------------
          // Validate real worker availability.
          // --------------------------------------------

          if (!_isAvailable(worker)) {
            throw StateError(
              'The worker is no longer available.',
            );
          }

          // --------------------------------------------
          // Validate real service pricing.
          // --------------------------------------------

          final currentRate =
              _hourlyRateMinor(worker);

          if (currentRate == null) {
            throw StateError(
              'Worker hourly rate is unavailable.',
            );
          }

          if (currentRate != displayedRate) {
            throw StateError(
              'The hourly rate has changed. '
              'Please review the updated amount.',
            );
          }

          if (!appointmentDate.isAfter(
            DateTime.now(),
          )) {
            throw StateError(
              'The selected appointment time '
              'is no longer valid.',
            );
          }

          final workerName = _text(
            worker['name'],
            'Worker',
          );

          final category = _text(
            worker['category'],
            'QuickFix',
          );

          final customerName = _text(
            user.displayName,
            _text(user.email, 'Customer'),
          );

          final totalMinor =
              currentRate * duration;

          // --------------------------------------------
          // Create the payment-ready booking.
          // --------------------------------------------

          transaction.set(_bookingRef, {
            // Booking identification

            'bookingId': _bookingRef.id,
            'appointmentId': _bookingRef.id,

            // Service information

            'serviceType': 'quickfix',
            'module': 'quickfix',
            'category': category,

            // Worker information

            'workerId': _workerId,
            'workerName': workerName,

            // Customer information

            'customerId': user.uid,
            'customerName': customerName,
            'customerEmail': user.email ?? '',

            // Service request

            'address': address,
            'issue': issue,

            // Appointment schedule

            'date': formattedDate,
            'time': formattedTime,

            'appointmentDate':
                Timestamp.fromDate(
              appointmentDate,
            ),

            'appointmentEndDate':
                Timestamp.fromDate(
              appointmentDate.add(
                Duration(hours: duration),
              ),
            ),

            // Pricing

            'hourlyRate': currentRate / 100,
            'hourlyRateMinor': currentRate,

            'durationHours': duration,

            'amountMinor': totalMinor,
            'amount': totalMinor / 100,

            'currency': 'LKR',

            // Booking status

            'status': 'Pending',

            // Payment information

            'paymentStatus': 'unpaid',
            'paymentId': null,
            'paymentMethod': null,
            'paymentEnvironment': 'demo',
            'isRealPayment': false,

            // Timestamps

            'createdAt':
                FieldValue.serverTimestamp(),

            'updatedAt':
                FieldValue.serverTimestamp(),
          });

          return <String, dynamic>{
            ...worker,
            'id': _workerId,
            'uid': _workerId,
          };
        },
      );

      // Existing Firebase Cloud Function
      // quickfixNewBooking automatically generates
      // the worker notification.
      //
      // Do not create a duplicate notification here.

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(
            worker: savedWorker,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _message(
        error is StateError
            ? error.message
            : 'Could not submit booking. '
                'Please check your connection and try again.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ======================================================
  // COMMON UI
  // ======================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(18),
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

  Widget _sectionTitle(
    String title, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 5),

            Text(
              subtitle,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,

      prefixIcon: icon == null
          ? null
          : Icon(icon, color: muted),

      contentPadding:
          const EdgeInsets.all(16),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: line),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: line),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primary,
          width: 1.6,
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool emphasis = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasis ? ink : muted,
                fontSize: emphasis ? 15 : 13,
                fontWeight: emphasis
                    ? FontWeight.w700
                    : FontWeight.normal,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: emphasis ? primary : ink,
                fontSize: emphasis ? 17 : 13,
                fontWeight: FontWeight.w600,
              ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // WORKER PROFILE SUMMARY
  // ======================================================

  Widget _workerCard(
    Map<String, dynamic> worker,
  ) {
    final name = _text(
      worker['name'],
      'Worker',
    );

    final category = _text(
      worker['category'],
      'QuickFix Service',
    );

    final rate = _hourlyRateMinor(worker);

    final available = _isAvailable(worker);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF334155),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR SERVICE PROVIDER',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Colors.white.withValues(
                  alpha: 0.12,
                ),
                child: Text(
                  name.characters.first
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Divider(
            color: Color(0x33FFFFFF),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hourly Rate',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      rate == null
                          ? 'Not configured'
                          : '${_money(rate)}/hr',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: available
                      ? const Color(0xFF065F46)
                      : const Color(0xFF7F1D1D),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  available
                      ? 'Available'
                      : 'Offline',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================================================
  // DATE AND TIME SELECTORS
  // ======================================================

  Widget _selector({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(15),
          onTap:
              _isSubmitting ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: line),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: primary,
                  size: 24,
                ),

                const SizedBox(height: 12),

                Text(
                  label,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scheduleSection() {
    return Row(
      children: [
        _selector(
          icon: Icons.calendar_today_outlined,
          label: 'Appointment Date',
          value: _selectedDate == null
              ? 'Select Date'
              : _formatDate(_selectedDate!),
          onTap: () => _selectDate(),
        ),

        const SizedBox(width: 12),

        _selector(
          icon: Icons.access_time_rounded,
          label: 'Appointment Time',
          value: _selectedTime == null
              ? 'Select Time'
              : _selectedTime!.format(context),
          onTap: () => _selectTime(),
        ),
      ],
    );
  }

  // ======================================================
  // SERVICE DURATION
  // ======================================================

  Widget _durationSection() {
    return _card(
      child: Wrap(
        spacing: 9,
        runSpacing: 10,
        children: List.generate(
          8,
          (index) {
            final hours = index + 1;

            final selected =
                _durationHours == hours;

            return ChoiceChip(
              label: Text(
                '$hours ${hours == 1 ? 'Hour' : 'Hours'}',
              ),

              selected: selected,

              showCheckmark: false,

              selectedColor: primary,

              backgroundColor: background,

              side: BorderSide(
                color:
                    selected ? primary : line,
              ),

              labelStyle: TextStyle(
                color:
                    selected ? Colors.white : ink,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),

              onSelected: _isSubmitting
                  ? null
                  : (_) {
                      setState(() {
                        _durationHours = hours;
                      });
                    },
            );
          },
        ),
      ),
    );
  }

  // ======================================================
  // SERVICE ADDRESS
  // ======================================================

  Widget _addressField() {
    return TextFormField(
      controller: _addressController,
      enabled: !_isSubmitting,
      maxLines: 2,
      maxLength: 300,
      textCapitalization:
          TextCapitalization.sentences,

      decoration: _inputDecoration(
        label: 'Service Address',
        hint: 'Enter your complete address',
        icon: Icons.location_on_outlined,
      ),

      validator: (value) {
        final address =
            value?.trim() ?? '';

        if (address.isEmpty) {
          return 'Please enter your service address.';
        }

        if (address.length < 5) {
          return 'Please enter a valid address.';
        }

        return null;
      },
    );
  }

  // ======================================================
  // ISSUE DESCRIPTION
  // ======================================================

  Widget _issueField() {
    return TextFormField(
      controller: _descriptionController,
      enabled: !_isSubmitting,
      maxLines: 4,
      maxLength: 1000,
      textCapitalization:
          TextCapitalization.sentences,

      decoration: _inputDecoration(
        label: 'Issue Description',
        hint: 'Describe the work or repair you need...',
      ),
    );
  }

  // ======================================================
  // PRICING SUMMARY
  // ======================================================

  Widget _pricingSummary(
    Map<String, dynamic> worker,
  ) {
    final rate = _hourlyRateMinor(worker);

    if (rate == null) {
      return _notice(
        icon: Icons.error_outline,
        message:
            'The worker has not configured a valid hourly rate.',
        color: danger,
      );
    }

    final total =
        rate * _durationHours;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _summaryRow(
            'Hourly rate',
            _money(rate),
          ),

          _summaryRow(
            'Service duration',
            '$_durationHours hour(s)',
          ),

          _summaryRow(
            'Service charge',
            _money(total),
          ),

          const Divider(height: 24),

          _summaryRow(
            'Estimated total',
            _money(total),
            emphasis: true,
          ),

          const SizedBox(height: 12),

          _notice(
            icon: Icons.info_outline,
            message:
                'The amount is based on your selected '
                'service duration. Payment becomes available '
                'after worker approval.',
            color: primary,
          ),
        ],
      ),
    );
  }

  // ======================================================
  // BOOKING BUTTON
  // ======================================================

  Widget _bookingButton(
    Map<String, dynamic> worker,
  ) {
    final rate = _hourlyRateMinor(worker);

    final user = _auth.currentUser;

    final canBook =
        user != null &&
        user.uid != _workerId &&
        _isAvailable(worker) &&
        rate != null &&
        !_isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: line),
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
                    'Estimated Total',
                    style: TextStyle(
                      color: muted,
                      fontSize: 14,
                    ),
                  ),
                ),

                Flexible(
                  child: Text(
                    rate == null
                        ? 'Unavailable'
                        : _money(
                            rate * _durationHours,
                          ),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: ink,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: line,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                onPressed: canBook
                    ? () => _submitBooking(worker)
                    : null,

                child: _isSubmitting
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 21,
                          ),

                          SizedBox(width: 9),

                          Text(
                            'Review & Send Request',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'No payment is required until approval.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // BOOKING FORM
  // ======================================================

  Widget _bookingForm(
    Map<String, dynamic> worker,
  ) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      bottomNavigationBar:
          _bookingButton(worker),

      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              28,
            ),
            children: [
              _workerCard(worker),

              if (!_isAvailable(worker)) ...[
                const SizedBox(height: 14),

                _notice(
                  icon: Icons.info_outline,
                  message:
                      'This worker is currently offline. '
                      'Booking is unavailable.',
                  color: danger,
                ),
              ],

              if (user == null) ...[
                const SizedBox(height: 14),

                _notice(
                  icon: Icons.lock_outline,
                  message:
                      'Please sign in to make a booking.',
                  color: danger,
                ),
              ],

              if (user?.uid == _workerId) ...[
                const SizedBox(height: 14),

                _notice(
                  icon: Icons.block_outlined,
                  message:
                      'You cannot book your own worker account.',
                  color: danger,
                ),
              ],

              _sectionTitle(
                'Appointment Schedule',
                subtitle:
                    'Choose your preferred date and time.',
              ),

              _scheduleSection(),

              _sectionTitle(
                'Estimated Service Duration',
                subtitle:
                    'Select the number of hours required.',
              ),

              _durationSection(),

              _sectionTitle(
                'Service Location',
                subtitle:
                    'Provide the location where the work is required.',
              ),

              _addressField(),

              _sectionTitle(
                'Describe the Issue',
                subtitle:
                    'Help your worker understand the requested service.',
              ),

              _issueField(),

              _sectionTitle(
                'Booking Summary',
              ),

              _pricingSummary(worker),

              const SizedBox(height: 18),

              _notice(
                icon: Icons.notifications_active_outlined,
                message:
                    'The worker will receive a notification '
                    'when your request is submitted. '
                    'You will be notified when the booking '
                    'is approved or rejected.',
                color: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // LOADING AND ERROR STATES
  // ======================================================

  Widget _stateScreen({
    required String message,
    bool loading = false,
  }) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'Book Appointment',
        ),
        backgroundColor: background,
        foregroundColor: ink,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: loading
              ? const CircularProgressIndicator(
                  color: primary,
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: muted,
                      size: 45,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 20),

                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ======================================================
  // MAIN BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    if (_workerStream == null) {
      return _stateScreen(
        message: 'Invalid worker information.',
      );
    }

    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: _workerStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _stateScreen(
            message:
                'Unable to load worker details.',
          );
        }

        if (!snapshot.hasData) {
          return _stateScreen(
            message: 'Loading worker...',
            loading: true,
          );
        }

        final worker =
            snapshot.data!.data();

        if (worker == null) {
          return _stateScreen(
            message:
                'This worker is no longer available.',
          );
        }

        return _bookingForm(worker);
      },
    );
  }
}
