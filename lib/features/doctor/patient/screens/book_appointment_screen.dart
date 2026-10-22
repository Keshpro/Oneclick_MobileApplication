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
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _lightGreen = Color(0xFFECFDF5);

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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: _primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _continueBooking() {
    if (_selectedDate == null) {
      _showMessage('Please select an appointment date.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select an available time slot.');
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
      final doctorUid = doctorData['uid'] ?? doctorData['id'] ?? 'unknown_doc';
      final doctorName = doctorData['name'] ?? 'Dr. Specialist';
      final specialty = doctorData['specialtyLabel'] ?? doctorData['specialization'] ?? 'General Physician';
      final hospital = doctorData['hospital'] ?? 'General Clinic';
      final fee = doctorData['fee'] ?? 2500;
      final formattedDate = '${_selectedDate!.day} ${_monthName(_selectedDate!)} ${_selectedDate!.year}';
      final patientName = currentUser.displayName ?? currentUser.email?.split('@').first ?? 'Patient';

      // 1. Save Appointment Record
      await docRef.set({
        'id': appointmentId,
        'docId': docRef.id,
        'userId': currentUser.uid,
        'patientId': currentUser.uid,
        'userName': patientName,
        'userEmail': currentUser.email ?? 'Patient',
        'doctorId': doctorUid,
        'doctorName': doctorName,
        'specialty': specialty,
        'hospital': hospital,
        'date': formattedDate,
        'day': _dayName(_selectedDate!),
        'time': _selectedTime,
        'type': _consultationType,
        'fee': fee,
        'status': 'Approved',
        'reason': _reasonController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Dispatch Real-time Notification to Doctor
      if (doctorUid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': doctorUid,
          'type': 'NEW_APPOINTMENT',
          'title': 'New Appointment Booking! 📅',
          'message': '$patientName booked an appointment for $formattedDate at $_selectedTime.',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pop(sheetContext);
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
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
                  decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(20)),
                ),
                const SizedBox(height: 22),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Review Appointment', style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
                  child: Column(
                    children: [
                      _reviewRow(Icons.person_outline_rounded, 'Doctor', widget.doctor['name'].toString()),
                      _reviewDivider(),
                      _reviewRow(Icons.calendar_month_outlined, 'Date', _fullDate(_selectedDate!)),
                      _reviewDivider(),
                      _reviewRow(Icons.schedule_rounded, 'Time', _selectedTime!),
                      _reviewDivider(),
                      _reviewRow(Icons.health_and_safety_outlined, 'Consultation Mode', _consultationType),
                      if (_reasonController.text.trim().isNotEmpty) ...[
                        _reviewDivider(),
                        _reviewRow(Icons.notes_rounded, 'Reason / Notes', _reasonController.text.trim()),
                      ],
                      _reviewDivider(),
                      _reviewRow(Icons.payments_outlined, 'Consultation Fee', 'LKR ${widget.doctor['fee'] ?? 2500}'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : () => _saveAppointmentToFirestore(sheetContext),
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(_isSaving ? 'Processing Booking...' : 'Confirm Booking', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: _primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _textMuted, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewDivider() {
    return const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1, color: _border));
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(color: _lightGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: _primary, size: 42),
                ),
                const SizedBox(height: 20),
                const Text('Appointment Confirmed! 🎉', textAlign: TextAlign.center, style: TextStyle(color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Your appointment with ${widget.doctor['name']} has been successfully scheduled. The doctor has been notified.', textAlign: TextAlign.center, style: const TextStyle(color: _textMuted, fontSize: 13, height: 1.5)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
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
    final doctorName = widget.doctor['name'] ?? 'Doctor';
    final specialty = widget.doctor['specialtyLabel'] ?? widget.doctor['specialty'] ?? 'Specialist';
    final hospital = widget.doctor['hospital'] ?? 'General Clinic';
    final fee = widget.doctor['fee'] ?? 2500;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _textPrimary,
        title: const Text('Book Appointment', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(color: _lightGreen, borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.person_rounded, color: _primary, size: 34),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctorName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _textPrimary)),
                              const SizedBox(height: 2),
                              Text('$specialty • $hospital', style: const TextStyle(fontSize: 12, color: _textMuted)),
                              const SizedBox(height: 6),
                              Text('Fee: LKR $fee', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Consultation Mode Selector
                  const Text('Consultation Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
                  const SizedBox(height: 10),
                  Row(
                    children: ['In-person', 'Video Call'].map((mode) {
                      final isSelected = _consultationType == mode;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _consultationType = mode),
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? _primary : _surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSelected ? _primary : _border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(mode == 'In-person' ? Icons.local_hospital_outlined : Icons.videocam_outlined, size: 18, color: isSelected ? Colors.white : _primary),
                                  const SizedBox(width: 8),
                                  Text(mode, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isSelected ? Colors.white : _textPrimary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Date Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
                      TextButton.icon(
                        onPressed: _pickCustomDate,
                        icon: const Icon(Icons.calendar_month_rounded, size: 16, color: _primary),
                        label: const Text('Pick Date', style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableDates.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 9),
                      itemBuilder: (context, index) {
                        final date = _availableDates[index];
                        final selected = _selectedDate != null && _sameDate(_selectedDate!, date);

                        return InkWell(
                          onTap: () => setState(() => _selectedDate = date),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 68,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? _primary : _surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: selected ? _primary : _border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_dayName(date), style: TextStyle(color: selected ? Colors.white : _textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${date.day}', style: TextStyle(color: selected ? Colors.white : _textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Time Slots Grid
                  const Text('Available Time Slots', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _timeSlots.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.4,
                    ),
                    itemBuilder: (context, index) {
                      final time = _timeSlots[index];
                      final selected = _selectedTime == time;

                      return InkWell(
                        onTap: () => setState(() => _selectedTime = time),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? _primary : _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selected ? _primary : _border),
                          ),
                          child: Text(time, style: TextStyle(color: selected ? Colors.white : _textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Reason Note Field
                  const Text('Reason for Visit (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textPrimary)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Fever, Sore Throat, Routine Checkup...',
                      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                      filled: true,
                      fillColor: _surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _primary)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Review Appointment', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}