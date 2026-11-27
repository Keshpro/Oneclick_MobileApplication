import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../payment/models/payment_request.dart';
import '../../../payment/screens/checkout_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  static const Color primary = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF047857);
  static const Color background = Color(0xFFF6F8FA);
  static const Color textDark = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _consultationType = 'In-person';

  bool _isLoading = false;

  final TextEditingController _reasonController = TextEditingController();

  String get _doctorId {
    return (widget.doctor['uid'] ??
            widget.doctor['doctorId'] ??
            widget.doctor['id'] ??
            '')
        .toString();
  }

  String get _doctorName {
    return (widget.doctor['name'] ?? widget.doctor['doctorName'] ?? 'Doctor')
        .toString();
  }

  String get _specialty {
    return (widget.doctor['specialization'] ??
            widget.doctor['specialtyLabel'] ??
            widget.doctor['specialty'] ??
            'General Consultation')
        .toString();
  }

  String get _hospital {
    return (widget.doctor['hospital'] ??
            widget.doctor['clinic'] ??
            'Not specified')
        .toString();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _monthName(int month) {
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

    return months[month - 1];
  }

  String _dayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  String _appointmentDateText(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _formatAmount(int amountMinor) {
    return (amountMinor / 100).toStringAsFixed(2);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -------------------------------------------------------
  // FIRESTORE DOCTOR FEE
  // -------------------------------------------------------

  Future<int> _getConsultationFee() async {
    if (_doctorId.isEmpty) {
      throw StateError('Doctor ID is missing.');
    }

    final doctorDoc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(_doctorId)
        .get();

    if (!doctorDoc.exists) {
      throw StateError('Doctor record was not found in Firestore.');
    }

    final data = doctorDoc.data()!;

    final providerDetails = data['providerDetails'];

    dynamic rawFee = data['consultationFee'] ?? data['fee'];

    if (rawFee == null && providerDetails is Map) {
      rawFee = providerDetails['consultationFee'] ?? providerDetails['fee'];
    }

    final fee = rawFee is num
        ? rawFee.toDouble()
        : double.tryParse(
            rawFee
                    ?.toString()
                    .replaceAll(',', '')
                    .replaceAll('LKR', '')
                    .trim() ??
                '',
          );

    if (fee == null || fee <= 0) {
      throw StateError('Consultation fee is unavailable for this doctor.');
    }

    return (fee * 100).round();
  }

  // -------------------------------------------------------
  // DATE PICKER
  // -------------------------------------------------------

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Appointment Date',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
      });
    }
  }

  // -------------------------------------------------------
  // TIME PICKER
  // -------------------------------------------------------

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Appointment Time',
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // -------------------------------------------------------
  // PAYMENT REQUEST
  // -------------------------------------------------------

  PaymentRequest _buildPaymentRequest({
    required String appointmentId,
    required int amountMinor,
  }) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please log in first.');
    }

    final name = user.displayName?.trim() ?? '';

    final parts = name.isEmpty ? <String>[] : name.split(RegExp(r'\s+'));

    return PaymentRequest(
      bookingId: appointmentId,
      module: 'doctor',
      title: 'Doctor Consultation - $_doctorName',
      amountMinor: amountMinor,
      firstName: parts.isNotEmpty ? parts.first : '',
      lastName: parts.length > 1 ? parts.skip(1).join(' ') : '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      address: '',
      city: '',
    );
  }

  // -------------------------------------------------------
  // CREATE APPOINTMENT IN FIRESTORE
  // -------------------------------------------------------

  Future<String> _createAppointment({
    required DateTime appointmentDate,
    required String appointmentTime,
    required int amountMinor,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please log in first.');
    }

    if (_doctorId.isEmpty) {
      throw StateError('Doctor ID is missing.');
    }

    final appointmentRef = FirebaseFirestore.instance
        .collection('appointments')
        .doc();

    final patientName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'Patient');

    await appointmentRef.set({
      'id': 'OC-${appointmentRef.id.substring(0, 5).toUpperCase()}',
      'docId': appointmentRef.id,

      // Patient
      'userId': user.uid,
      'patientId': user.uid,
      'patientName': patientName,
      'userName': patientName,
      'userEmail': user.email ?? '',
      'patientPhone': user.phoneNumber ?? '',

      // Doctor
      'doctorId': _doctorId,
      'doctorName': _doctorName,
      'specialty': _specialty,
      'hospital': _hospital,

      // Appointment
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'date': _appointmentDateText(appointmentDate),
      'day': _dayName(appointmentDate),
      'time': appointmentTime,
      'type': _consultationType,
      'consultationType': _consultationType,
      'reason': _reasonController.text.trim(),

      // Payment
      'fee': amountMinor / 100,
      'amountMinor': amountMinor,
      'currency': 'LKR',
      'status': 'awaiting_payment',
      'paymentStatus': 'unpaid',
      'paymentMethod': null,
      'paymentId': null,

      // Timestamps
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return appointmentRef.id;
  }

  // -------------------------------------------------------
  // OPEN COMMON CHECKOUT
  // -------------------------------------------------------

  Future<void> _confirmBooking() async {
    if (_isLoading) return;

    final date = _selectedDate;
    final time = _selectedTime;

    if (date == null) {
      _showMessage('Please select an appointment date.', isError: true);
      return;
    }

    if (time == null) {
      _showMessage('Please select an appointment time.', isError: true);
      return;
    }

    final appointmentDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!appointmentDateTime.isAfter(DateTime.now())) {
      _showMessage('Please select a future date and time.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Get real fee from Firestore.
      final amountMinor = await _getConsultationFee();

      if (!mounted) return;

      // Step 2: Create pending appointment.
      final appointmentId = await _createAppointment(
        appointmentDate: appointmentDateTime,
        appointmentTime: time.format(context),
        amountMinor: amountMinor,
      );

      if (!mounted) return;

      // Step 3: Build common payment request.
      final paymentRequest = _buildPaymentRequest(
        appointmentId: appointmentId,
        amountMinor: amountMinor,
      );

      // Step 4: Open existing common checkout.
      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(request: paymentRequest),
        ),
      );

      if (!mounted) return;

      if (completed != true) {
        _showMessage(
          'Appointment draft saved. '
          'Payment has not been completed.',
        );
        return;
      }

      // Step 5: Read updated booking from Firestore.
      final booking = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!booking.exists) {
        throw StateError('Appointment record not found.');
      }

      final data = booking.data()!;

      final status = data['status']?.toString();
      final paymentStatus = data['paymentStatus']?.toString();

      final paymentId = data['paymentId']?.toString();

      final isConfirmed =
          status == 'confirmed' &&
          paymentId != null &&
          paymentId.isNotEmpty &&
          (paymentStatus == 'demo_paid' || paymentStatus == 'pending_cash');

      if (!isConfirmed) {
        throw StateError(
          'Checkout returned successfully, '
          'but appointment confirmation '
          'was not found in Firestore.',
        );
      }

      if (!mounted) return;

      // Step 6: Show actual database result.
      await _showSuccessDialog(
        appointmentId: appointmentId,
        paymentStatus: paymentStatus!,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      _showMessage('Booking failed: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // -------------------------------------------------------
  // SUCCESS DIALOG
  // -------------------------------------------------------

  Future<void> _showSuccessDialog({
    required String appointmentId,
    required String paymentStatus,
  }) async {
    final cash = paymentStatus == 'pending_cash';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                cash
                    ? Icons.pending_actions_rounded
                    : Icons.check_circle_rounded,
                color: cash ? Colors.orange : primary,
                size: 65,
              ),
              const SizedBox(height: 12),
              Text(
                cash ? 'Appointment Confirmed' : 'Booking Successful!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cash
                    ? 'Your appointment is confirmed. '
                          'Cash payment is pending.'
                    : 'Your appointment is confirmed '
                          'with a simulated card payment.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              SelectableText(
                'Booking ID:\n$appointmentId',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'The doctor will receive an '
                'in-app notification.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              const Text(
                'DEMO PAYMENT - No real money charged.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 11),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: primary),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------
  // UI COMPONENTS
  // -------------------------------------------------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
      ),
    );
  }

  Widget _doctorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFECFDF5),
            child: Icon(
              Icons.medical_services_rounded,
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _specialty,
                  style: const TextStyle(color: primaryDark, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  _hospital,
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(icon, color: primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: muted),
      ),
    );
  }

  Widget _consultationSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'In-person',
          icon: Icon(Icons.local_hospital_outlined),
          label: Text('In-person'),
        ),
        ButtonSegment(
          value: 'Video Call',
          icon: Icon(Icons.videocam_outlined),
          label: Text('Video Call'),
        ),
      ],
      selected: {_consultationType},
      onSelectionChanged: (values) {
        setState(() {
          _consultationType = values.first;
        });
      },
    );
  }

  // -------------------------------------------------------
  // MAIN UI
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Book Appointment',
          style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _doctorCard(),

                  _sectionTitle('Consultation Type'),

                  _consultationSelector(),

                  _sectionTitle('Appointment Schedule'),

                  _selectionCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Select Date',
                    subtitle: _selectedDate == null
                        ? 'Choose appointment date'
                        : _formatDate(_selectedDate!),
                    onTap: _selectDate,
                  ),

                  _selectionCard(
                    icon: Icons.access_time_rounded,
                    title: 'Select Time',
                    subtitle: _selectedTime == null
                        ? 'Choose appointment time'
                        : _selectedTime!.format(context),
                    onTap: _selectTime,
                  ),

                  _sectionTitle('Additional Information'),

                  TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    style: const TextStyle(color: textDark, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Describe your reason for consultation...',
                      hintStyle: const TextStyle(color: muted),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Card(
                    color: Color(0xFFECFDF5),
                    elevation: 0,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: primaryDark),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your appointment will be '
                              'automatically confirmed after '
                              'completing the common checkout. '
                              'Card payments are simulated.',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _confirmBooking,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(
                      _isLoading
                          ? 'Processing Booking...'
                          : 'Continue to Payment',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF9DD9C1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
