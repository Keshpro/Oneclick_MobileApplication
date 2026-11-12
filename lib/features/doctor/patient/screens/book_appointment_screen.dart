
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'appointment_success_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  // Connect the common PayHere Sandbox service here.
  final DoctorPaymentHandler? onStartPayment;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
    this.onStartPayment,
  });

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  static const Color primary = Color(0xFF059669);
  static const Color background = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color lightGreen = Color(0xFFECFDF5);

  DateTime? _selectedDate;
  String? _selectedTime;
  String _consultationType = 'In-person';

  bool _isSaving = false;

  final TextEditingController _reasonController =
      TextEditingController();

  final List<String> _timeSlots = const [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '2:00 PM',
    '2:30 PM',
    '3:30 PM',
    '4:00 PM',
    '5:00 PM',
    '6:30 PM',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(
      now.year,
      now.month,
      now.day,
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String get _doctorName {
    return widget.doctor['name']?.toString() ?? 'Doctor';
  }

  String get _specialty {
    return (widget.doctor['specialtyLabel'] ??
            widget.doctor['specialization'] ??
            widget.doctor['specialty'])
        ?.toString() ?? 'General';
  }

  String get _hospital {
    return widget.doctor['hospital']?.toString() ??
        'General Clinic';
  }

  String get _doctorId {
    return (widget.doctor['uid'] ??
            widget.doctor['id'])
        ?.toString()
        .trim() ?? '';
  }

  // LKR minor units: 2500.00 => 250000
  // Invalid or unavailable fees are not guessed.
  int? get _consultationFeeMinor {
    final raw = widget.doctor['fee'];

    if (raw == null) return null;

    final normalized = raw
        .toString()
        .replaceAll(',', '')
        .replaceAll(
          RegExp(r'(?i:lkr|rs\.?)'),
          '',
        )
        .trim();

    final match = RegExp(
      r'^(\d+)(?:\.(\d{1,2}))?$',
    ).firstMatch(normalized);

    if (match == null) return null;

    final whole =
        int.tryParse(match.group(1) ?? '');

    if (whole == null) return null;

    final fraction = (match.group(2) ?? '')
        .padRight(2, '0');

    final cents = int.tryParse(fraction) ?? 0;
    final result = whole * 100 + cents;

    return result > 0 ? result : null;
  }

  String get _formattedFee {
    final amount = _consultationFeeMinor;

    if (amount == null) return 'Fee unavailable';

    final whole = amount ~/ 100;
    final cents =
        (amount % 100).toString().padLeft(2, '0');

    return 'LKR $whole.$cents';
  }

  List<DateTime> get _availableDates {
    final now = DateTime.now();

    return List.generate(
      7,
      (index) => DateTime(
        now.year,
        now.month,
        now.day + index,
      ),
    );
  }

  String _dayName(DateTime date) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[date.weekday - 1];
  }

  String _monthName(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[date.month - 1];
  }

  String _fullDate(DateTime date) {
    return '${_dayName(date)}, '
        '${date.day} '
        '${_monthName(date)} '
        '${date.year}';
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: now.add(
        const Duration(days: 60),
      ),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedDate = picked;
      _selectedTime = null;
    });
  }

  void _continueBooking() {
    if (_selectedDate == null) {
      _showMessage('Please select an appointment date.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select an appointment time.');
      return;
    }

    if (_doctorId.isEmpty) {
      _showMessage('Doctor information is incomplete.');
      return;
    }

    if (_consultationFeeMinor == null) {
      _showMessage(
        'A valid consultation fee is required.',
      );
      return;
    }

    _showReviewSheet();
  }

  // This creates an UNCONFIRMED draft only.
  // The server must confirm it after verified payment.
  Future<void> _confirmAndOpenPayment(
    BuildContext sheetContext,
  ) async {
    if (_isSaving) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please log in first.');
      return;
    }

    final date = _selectedDate;
    final time = _selectedTime;
    final amountMinor = _consultationFeeMinor;

    if (date == null ||
        time == null ||
        amountMinor == null ||
        _doctorId.isEmpty) {
      _showMessage('Missing appointment details.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = FirebaseFirestore.instance;

      final docRef = db
          .collection('appointments')
          .doc();

      final patientName =
          user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : (user.email?.split('@').first ??
                  'Patient');

      // Amount, doctor ownership and slot availability
      // must also be validated by the trusted backend.
      await docRef.set({
        'id':
            'OC-${docRef.id.substring(0, 5).toUpperCase()}',
        'docId': docRef.id,
        'userId': user.uid,
        'patientId': user.uid,
        'userName': patientName,
        'userEmail': user.email ?? '',
        'doctorId': _doctorId,
        'doctorName': _doctorName,
        'specialty': _specialty,
        'hospital': _hospital,
        'date':
            '${date.day} ${_monthName(date)} ${date.year}',
        'day': _dayName(date),
        'appointmentDate': Timestamp.fromDate(date),
        'time': time,
        'type': _consultationType,
        'fee': amountMinor / 100,
        'amountMinor': amountMinor,
        'currency': 'LKR',
        'reason': _reasonController.text.trim(),

        // Never mark a booking approved before payment.
        'status': 'awaiting_payment',
        'paymentStatus': 'unpaid',
        'paymentId': null,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();

      // Checkout + success logic lives in this screen.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AppointmentSuccessScreen(
            doctor: widget.doctor,
            appointmentDate: date,
            appointmentTime: time,
            consultationType: _consultationType,
            appointmentId: docRef.id,
            amountMinor: amountMinor,
            onStartPayment: widget.onStartPayment,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      _showMessage(
        'Unable to prepare booking: ${error.message ?? error.code}',
      );
    } catch (_) {
      _showMessage(
        'Unable to prepare your appointment.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showReviewSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  14,
                  22,
                  28,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: border,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Review Appointment',
                            style: TextStyle(
                              color: dark,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            children: [
                              _reviewRow(
                                Icons.person_outline_rounded,
                                'Doctor',
                                _doctorName,
                              ),
                              _reviewDivider(),
                              _reviewRow(
                                Icons.calendar_month_outlined,
                                'Date',
                                _fullDate(_selectedDate!),
                              ),
                              _reviewDivider(),
                              _reviewRow(
                                Icons.schedule_rounded,
                                'Time',
                                _selectedTime!,
                              ),
                              _reviewDivider(),
                              _reviewRow(
                                Icons.health_and_safety_outlined,
                                'Consultation Mode',
                                _consultationType,
                              ),
                              if (_reasonController.text
                                  .trim()
                                  .isNotEmpty) ...[
                                _reviewDivider(),
                                _reviewRow(
                                  Icons.notes_rounded,
                                  'Reason / Notes',
                                  _reasonController.text.trim(),
                                ),
                              ],
                              _reviewDivider(),
                              _reviewRow(
                                Icons.payments_outlined,
                                'Consultation Fee',
                                _formattedFee,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Next you will review and pay through '
                          'OneClick Payment. Your appointment '
                          'is confirmed only after payment verification.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving
                                ? null
                                : () async {
                                    setSheetState(() {});
                                    await _confirmAndOpenPayment(
                                      sheetContext,
                                    );
                                  },
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_forward_rounded,
                                  ),
                            label: Text(
                              _isSaving
                                  ? 'Preparing Checkout...'
                                  : 'Confirm Booking',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _reviewRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: lightGreen,
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
                title,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: dark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: border,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: dark,
        elevation: 0,
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _doctorHeader(),
                  const SizedBox(height: 25),

                  _heading('Consultation Mode'),
                  const SizedBox(height: 12),
                  _consultationModeSelector(),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _heading('Select Date'),
                      TextButton.icon(
                        onPressed: _pickCustomDate,
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 16,
                        ),
                        label: const Text('Pick Date'),
                        style: TextButton.styleFrom(
                          foregroundColor: primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  _dateSelector(),

                  const SizedBox(height: 25),

                  _heading('Select Time Slot'),
                  const SizedBox(height: 12),
                  _timeSelector(),

                  const SizedBox(height: 25),

                  _heading('Reason for Visit (Optional)'),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText:
                          'e.g. Fever, routine checkup...',
                      hintStyle: const TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: border),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isSaving ? null : _continueBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Review Appointment',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: dark,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _doctorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: primary,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_specialty • $_hospital',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _formattedFee,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _consultationModeSelector() {
    return Row(
      children: [
        for (final mode in const [
          'In-person',
          'Video Call',
        ])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _consultationType = mode;
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _consultationType == mode
                        ? primary
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: _consultationType == mode
                          ? primary
                          : border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        mode == 'In-person'
                            ? Icons.local_hospital_outlined
                            : Icons.videocam_outlined,
                        color: _consultationType == mode
                            ? Colors.white
                            : primary,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          mode,
                          style: TextStyle(
                            color: _consultationType == mode
                                ? Colors.white
                                : dark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _dateSelector() {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDates.length,
        separatorBuilder: (_, index) =>
            const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final date = _availableDates[index];

          final selected = _selectedDate != null &&
              _sameDate(_selectedDate!, date);

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedTime = null;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              width: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? primary
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? primary : border,
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(date),
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : dark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _monthName(date),
                    style: TextStyle(
                      color: selected
                          ? Colors.white70
                          : muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _timeSelector() {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: _timeSlots.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final time = _timeSlots[index];
        final selected = _selectedTime == time;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? primary
                  : Colors.white,
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: selected ? primary : border,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : dark,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}
