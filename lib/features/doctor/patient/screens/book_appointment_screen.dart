import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const BookAppointmentScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
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

  final TextEditingController _reasonController =
      TextEditingController();

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
        '${date.day} ${_monthName(date)} ${date.year}';
  }

  bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _continueBooking() {
    if (_selectedDate == null) {
      _showMessage(
        'Please select an appointment date.',
      );
      return;
    }

    if (_selectedTime == null) {
      _showMessage(
        'Please select an available time.',
      );
      return;
    }

    _showReviewSheet();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            12,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Review Appointment',
                        style: TextStyle(
                          color: _text,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Check the details before confirming.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _reviewRow(
                        Icons.person_outline_rounded,
                        'Doctor',
                        widget.doctor['name'].toString(),
                      ),
                      _reviewDivider(),
                      _reviewRow(
                        Icons.medical_services_outlined,
                        'Specialty',
                        widget.doctor['specialtyLabel']
                            .toString(),
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
                        'Consultation',
                        _consultationType,
                      ),
                      _reviewDivider(),
                      _reviewRow(
                        Icons.payments_outlined,
                        'Consultation Fee',
                        'LKR ${widget.doctor['fee']}',
                      ),
                    ],
                  ),
                ),

                if (_reasonController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reason for visit',
                          style: TextStyle(
                            color: _primaryDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _reasonController.text.trim(),
                          style: const TextStyle(
                            color: _text,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      _confirmAppointment();
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                    ),
                    label: const Text(
                      'Confirm Appointment',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text(
                      'Edit Appointment',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _reviewRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 18,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: _text,
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

  Widget _reviewDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 11),
      child: Divider(
        height: 1,
        color: Color(0xFFE2E8F0),
      ),
    );
  }

  void _confirmAppointment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _primary,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Appointment Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your appointment with '
                  '${widget.doctor['name']} has been '
                  'scheduled successfully.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _fullDate(_selectedDate!),
                        style: const TextStyle(
                          color: _text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedTime!,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
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
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(7),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _text,
              ),
            ),
          ),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =============================================
                  // DOCTOR CARD
                  // =============================================

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryDark,
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 78,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF6EE7B7),
                            size: 40,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                doctor['specialtyLabel']
                                    .toString(),
                                style: const TextStyle(
                                  color:
                                      Color(0xFF6EE7B7),
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .location_on_outlined,
                                    color:
                                        Color(0xFFA7F3D0),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      doctor['hospital']
                                          .toString(),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(0xFFA7F3D0),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color:
                                        Color(0xFFFBBF24),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${doctor['rating']}',
                                    style:
                                        const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${doctor['experience']}+ years',
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(0xFFA7F3D0),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =============================================
                  // CONSULTATION TYPE
                  // =============================================

                  const Text(
                    'Consultation Type',
                    style: TextStyle(
                      color: _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Choose how you want to meet the doctor.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 13),

                  Row(
                    children: [
                      Expanded(
                        child: _consultationCard(
                          title: 'In-person',
                          subtitle: 'Visit clinic',
                          icon:
                              Icons.local_hospital_outlined,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _consultationCard(
                          title: 'Video',
                          subtitle: 'Online consultation',
                          icon:
                              Icons.videocam_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // =============================================
                  // DATE
                  // =============================================

                  const Text(
                    'Select Date',
                    style: TextStyle(
                      color: _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Choose your preferred appointment date.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 91,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableDates.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 9),
                      itemBuilder: (context, index) {
                        final date =
                            _availableDates[index];

                        final selected =
                            _selectedDate != null &&
                                _sameDate(
                                  _selectedDate!,
                                  date,
                                );

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                              _selectedTime = null;
                            });
                          },
                          borderRadius:
                              BorderRadius.circular(17),
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            width: 67,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _primary
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(17),
                              border: Border.all(
                                color: selected
                                    ? _primary
                                    : const Color(
                                        0xFFE2E8F0,
                                      ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  index == 0
                                      ? 'Today'
                                      : _dayName(date),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : _muted,
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : _text,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  _monthName(date),
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(
                                            0xFFD1FAE5,
                                          )
                                        : _muted,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =============================================
                  // TIME
                  // =============================================

                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Available Time',
                          style: TextStyle(
                            color: _text,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: _primary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Available',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
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

                      final selected =
                          _selectedTime == time;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTime = time;
                          });
                        },
                        borderRadius:
                            BorderRadius.circular(13),
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? _primary
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(13),
                            border: Border.all(
                              color: selected
                                  ? _primary
                                  : const Color(
                                      0xFFDDE7E3,
                                    ),
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : _text,
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // =============================================
                  // REASON
                  // =============================================

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Reason for Visit',
                          style: TextStyle(
                            color: _text,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF1F5F9),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Optional',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Briefly tell the doctor why you are booking.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 13),

                  TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: InputDecoration(
                      hintText:
                          'Example: Headache for the past two days...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      counterStyle: const TextStyle(
                        color: _muted,
                        fontSize: 9,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: _primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.all(15),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =============================================
                  // FEE
                  // =============================================

                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius:
                          BorderRadius.circular(19),
                      border: Border.all(
                        color: const Color(0xFFD1FAE5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.payments_outlined,
                            color: _primary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Consultation Fee',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pay after confirmation',
                                style: TextStyle(
                                  color: _primaryDark,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          'LKR ${doctor['fee']}',
                          style: const TextStyle(
                            color: _primaryDark,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===============================================
          // BOTTOM CONTINUE BUTTON
          // ===============================================

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(
                      alpha: 0.04,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continueBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFA7DCC8),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'Review Appointment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _consultationCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected =
        _consultationType == title;

    return InkWell(
      onTap: () {
        setState(() {
          _consultationType = title;
        });
      },
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFECFDF5)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? _primary
                : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: selected
                    ? _primary
                    : const Color(0xFFF1F5F9),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : _muted,
                size: 20,
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? _primaryDark
                          : _text,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: _primary,
                size: 17,
              ),
          ],
        ),
      ),
    );
  }
}