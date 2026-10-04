import 'package:flutter/material.dart';

class RescheduleAppointmentScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const RescheduleAppointmentScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  static const Color _primary = Color(0xFF059669);
  static const Color _primaryDark = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  DateTime? _selectedDate;
  String? _selectedTime;

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

  String _dayShort(DateTime date) {
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

  String _dayFull(DateTime date) {
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

  String _monthShort(DateTime date) {
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

  String _formattedDate(DateTime date) {
    return '${_dayFull(date)}, '
        '${date.day} ${_monthShort(date)} ${date.year}';
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  void _continueReschedule() {
    if (_selectedDate == null) {
      _showMessage('Please select a new date.');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select a new time.');
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Review New Schedule',
                    style: TextStyle(
                      color: _text,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your current appointment will be updated.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _reviewRow(
                        Icons.person_outline_rounded,
                        'Doctor',
                        widget.appointment['doctor']?.toString() ??
                            'Doctor',
                      ),
                      _divider(),
                      _reviewRow(
                        Icons.calendar_month_outlined,
                        'New Date',
                        _formattedDate(_selectedDate!),
                      ),
                      _divider(),
                      _reviewRow(
                        Icons.schedule_rounded,
                        'New Time',
                        _selectedTime!,
                      ),
                      _divider(),
                      _reviewRow(
                        Icons.health_and_safety_outlined,
                        'Consultation',
                        widget.appointment['type']?.toString() ??
                            'In-person',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmReschedule();
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                    ),
                    label: const Text(
                      'Confirm Reschedule',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text(
                      'Edit Selection',
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

  void _confirmReschedule() {
    // Temporary local update.
    // Later replace this section with Firestore update.

    widget.appointment['date'] =
        '${_selectedDate!.day} '
        '${_monthShort(_selectedDate!)} '
        '${_selectedDate!.year}';

    widget.appointment['day'] =
        _dayFull(_selectedDate!);

    widget.appointment['time'] = _selectedTime;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(27),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: _primary,
                    size: 39,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Appointment Rescheduled!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Your appointment has been moved to the new date and time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formattedDate(_selectedDate!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _selectedTime!,
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      // Returns true so MyAppointmentsScreen
                      // knows the appointment was changed.
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
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
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 11),
      child: Divider(
        height: 1,
        color: Color(0xFFE2E8F0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: _background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(7),
          child: InkWell(
            onTap: () => Navigator.pop(context),
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
          'Reschedule',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CURRENT APPOINTMENT

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _primaryDark,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.event_repeat_rounded,
                              color: Color(0xFF6EE7B7),
                              size: 19,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Current Appointment',
                              style: TextStyle(
                                color: Color(0xFFA7F3D0),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          appointment['doctor']?.toString() ??
                              'Doctor',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          appointment['specialty']?.toString() ??
                              'General',
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: _currentInfo(
                                Icons.calendar_month_outlined,
                                appointment['date']?.toString() ??
                                    '-',
                              ),
                            ),
                            Expanded(
                              child: _currentInfo(
                                Icons.schedule_rounded,
                                appointment['time']?.toString() ??
                                    '-',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 29),

                  const Text(
                    'Choose New Date',
                    style: TextStyle(
                      color: _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Select a new date for your appointment.',
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
                        final date = _availableDates[index];

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
                          borderRadius: BorderRadius.circular(17),
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            width: 67,
                            padding: const EdgeInsets.symmetric(
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
                                      : _dayShort(date),
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
                                  _monthShort(date),
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

                  const Text(
                    'Choose New Time',
                    style: TextStyle(
                      color: _text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Available times for the selected date.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
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
                        onTap: _selectedDate == null
                            ? null
                            : () {
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
                                : _selectedDate == null
                                    ? const Color(
                                        0xFFF1F5F9,
                                      )
                                    : Colors.white,
                            borderRadius:
                                BorderRadius.circular(13),
                            border: Border.all(
                              color: selected
                                  ? _primary
                                  : const Color(
                                      0xFFE2E8F0,
                                    ),
                            ),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : _selectedDate == null
                                      ? const Color(
                                          0xFFCBD5E1,
                                        )
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

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: const Color(0xFFFEF3C7),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your original appointment remains unchanged until you confirm the new schedule.',
                            style: TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 10.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _continueReschedule,
                  icon: const Icon(
                    Icons.event_repeat_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Review New Schedule',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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

  Widget _currentInfo(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFA7F3D0),
          size: 15,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}