import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  static const Color _primary = Color(0xFF059669);
  static const Color _primaryDark = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  DateTime? _selectedDate;
  String? _selectedTime;
  String _consultationType = 'In-person';
  bool _isSaving = false;

  final TextEditingController _reasonController = TextEditingController();

  final List<String> _timeSlots = [
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
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  List<DateTime> get _availableDates {
    final now = DateTime.now();
    return List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day + index),
    );
  }

  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _monthName(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.month - 1];
  }

  String _fullDate(DateTime date) {
    return '${_dayName(date)}, ${date.day} ${_monthName(date)} ${date.year}';
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _continueBooking() {
    if (_selectedDate == null) {
      _showMessage('Please select an appointment date.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select an available time.');
      return;
    }

    _showReviewSheet();
  }

  Future<void> _saveAppointmentToFirestore(BuildContext sheetContext) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      _showMessage('User not logged in. Please login first.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('appointments').doc();
      final appointmentId = 'OC-${docRef.id.substring(0, 5).toUpperCase()}';

      final doctorData = widget.doctor;
      final docId = doctorData['uid'] ?? doctorData['id'] ?? 'unknown_doc';
      final doctorName = doctorData['name'] ?? 'Doctor';
      final specialty = doctorData['specialtyLabel'] ?? doctorData['specialization'] ?? 'General Physician';
      final hospital = doctorData['hospital'] ?? 'General Clinic';
      final fee = doctorData['fee'] ?? 2500;

      // 1. Write Appointment Document to Firestore Collection
      await docRef.set({
        'id': appointmentId,
        'docId': docRef.id,
        'userId': currentUser.uid,
        'userEmail': currentUser.email ?? 'Patient',
        'doctorId': docId,
        'doctorName': doctorName,
        'specialty': specialty,
        'hospital': hospital,
        'date': '${_selectedDate!.day} ${_monthName(_selectedDate!)} ${_selectedDate!.year}',
        'day': _dayName(_selectedDate!),
        'time': _selectedTime,
        'type': _consultationType,
        'fee': fee,
        'status': 'Upcoming',
        'reason': _reasonController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Add Activity Log Entry
      await FirebaseFirestore.instance.collection('activity_logs').add({
        'action': 'New Appointment Booked',
        'details': 'Appointment $appointmentId booked with $doctorName',
        'performedBy': currentUser.email ?? 'Patient',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(sheetContext); // Close modal sheet
      _confirmAppointmentSuccess();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error saving appointment: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 22),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Review Appointment',
                    style: TextStyle(
                        color: _text,
                        fontSize: 21,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _reviewRow(Icons.person_outline_rounded, 'Doctor',
                          widget.doctor['name'].toString()),
                      _reviewDivider(),
                      _reviewRow(
                          Icons.calendar_month_outlined, 'Date', _fullDate(_selectedDate!)),
                      _reviewDivider(),
                      _reviewRow(
                          Icons.schedule_rounded, 'Time', _selectedTime!),
                      _reviewDivider(),
                      _reviewRow(Icons.health_and_safety_outlined,
                          'Consultation', _consultationType),
                      _reviewDivider(),
                      _reviewRow(Icons.payments_outlined, 'Fee',
                          'LKR ${widget.doctor['fee'] ?? 2500}'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _saveAppointmentToFirestore(sheetContext),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Confirm Appointment',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reviewRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: _primary, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _muted, fontSize: 10)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      color: _text, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 11),
      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
    );
  }

  void _confirmAppointmentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5), shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      color: _primary, size: 42),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Appointment Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _text, fontSize: 21, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your appointment with ${widget.doctor['name']} has been saved successfully.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Done',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text('Book Appointment',
            style: TextStyle(
                color: _text, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Date',
                      style: TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 91,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableDates.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 9),
                      itemBuilder: (context, index) {
                        final date = _availableDates[index];
                        final selected = _selectedDate != null &&
                            _sameDate(_selectedDate!, date);

                        return InkWell(
                          onTap: () => setState(() => _selectedDate = date),
                          child: Container(
                            width: 67,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? _primary : Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                  color: selected
                                      ? _primary
                                      : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_dayName(date),
                                    style: TextStyle(
                                        color: selected ? Colors.white : _muted,
                                        fontSize: 10)),
                                Text('${date.day}',
                                    style: TextStyle(
                                        color: selected ? Colors.white : _text,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Available Time',
                      style: TextStyle(
                          color: _text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _timeSlots.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 9,
                      crossAxisSpacing: 9,
                      childAspectRatio: 2.45,
                    ),
                    itemBuilder: (context, index) {
                      final time = _timeSlots[index];
                      final selected = _selectedTime == time;

                      return InkWell(
                        onTap: () => setState(() => _selectedTime = time),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? _primary : Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                                color: selected
                                    ? _primary
                                    : const Color(0xFFDDE7E3)),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                                color: selected ? Colors.white : _text,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Review Appointment',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}