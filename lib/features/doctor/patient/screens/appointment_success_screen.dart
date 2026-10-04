import 'package:flutter/material.dart';
import 'my_appointments_screen.dart';

class AppointmentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String consultationType;
  final String? appointmentId;

  const AppointmentSuccessScreen({
    super.key,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.consultationType,
    this.appointmentId,
  });

  static const Color _primary = Color(0xFF059669);
  static const Color _primaryDark = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

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

  String _monthName(DateTime date) {
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

    return months[date.month - 1];
  }

  String _formattedDate() {
    return '${_dayName(appointmentDate)}, '
        '${appointmentDate.day} '
        '${_monthName(appointmentDate)} '
        '${appointmentDate.year}';
  }

  void _openMyAppointments(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyAppointmentsScreen(),
      ),
    );
  }

  void _backToHealthHome(BuildContext context) {
    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    35,
                    20,
                    30,
                  ),
                  child: Column(
                    children: [
                      // ==========================================
                      // SUCCESS ICON
                      // ==========================================

                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD1FAE5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Appointment Booked!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _text,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 9),

                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        child: Text(
                          'Your appointment has been successfully scheduled.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==========================================
                      // BOOKING REFERENCE
                      // ==========================================

                      if (appointmentId != null &&
                          appointmentId!.trim().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.confirmation_number_outlined,
                                color: _primary,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Booking #$appointmentId',
                                style: const TextStyle(
                                  color: _primaryDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // ==========================================
                      // APPOINTMENT CARD
                      // ==========================================

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: 0.035,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ====================================
                            // DOCTOR INFO
                            // ====================================

                            Container(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: _primary,
                                      size: 35,
                                    ),
                                  ),

                                  const SizedBox(width: 13),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor['name']?.toString() ??
                                              'Doctor',
                                          style: const TextStyle(
                                            color: _text,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),

                                        const SizedBox(height: 3),

                                        Text(
                                          doctor['specialtyLabel']
                                                  ?.toString() ??
                                              'General',
                                          style: const TextStyle(
                                            color: _primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 13,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                doctor['hospital']
                                                        ?.toString() ??
                                                    'Hospital',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: _muted,
                                                  fontSize: 10,
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
                            ),

                            const Divider(
                              height: 1,
                              color: Color(0xFFE2E8F0),
                            ),

                            // ====================================
                            // APPOINTMENT INFORMATION
                            // ====================================

                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  _informationRow(
                                    icon: Icons.calendar_month_outlined,
                                    label: 'Date',
                                    value: _formattedDate(),
                                  ),

                                  const SizedBox(height: 17),

                                  _informationRow(
                                    icon: Icons.schedule_rounded,
                                    label: 'Time',
                                    value: appointmentTime,
                                  ),

                                  const SizedBox(height: 17),

                                  _informationRow(
                                    icon: consultationType == 'Video'
                                        ? Icons.videocam_outlined
                                        : Icons.local_hospital_outlined,
                                    label: 'Consultation',
                                    value: consultationType,
                                  ),

                                  const SizedBox(height: 17),

                                  _informationRow(
                                    icon: Icons.payments_outlined,
                                    label: 'Consultation Fee',
                                    value: 'LKR ${doctor['fee'] ?? '0'}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==========================================
                      // REMINDER
                      // ==========================================

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFEF3C7),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFFD97706),
                              size: 22,
                            ),

                            SizedBox(width: 11),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appointment Reminder',
                                    style: TextStyle(
                                      color: Color(0xFF92400E),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    'Please be ready a few minutes before your scheduled appointment.',
                                    style: TextStyle(
                                      color: Color(0xFFA16207),
                                      fontSize: 10.5,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ==========================================
                      // BOOKING NOTE
                      // ==========================================

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: _muted,
                              size: 20,
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'You can manage, reschedule or cancel this appointment from My Appointments.',
                                style: TextStyle(
                                  color: _muted,
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

              // ================================================
              // BOTTOM ACTIONS
              // ================================================

              Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  13,
                  20,
                  13,
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
                      color: Colors.black.withValues(
                        alpha: 0.035,
                      ),
                      blurRadius: 15,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==========================================
                      // VIEW APPOINTMENTS
                      // ==========================================

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _openMyAppointments(context);
                          },
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 19,
                          ),
                          label: const Text(
                            'View My Appointments',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ==========================================
                      // BACK HOME
                      // ==========================================

                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            _backToHealthHome(context);
                          },
                          icon: const Icon(
                            Icons.home_outlined,
                            size: 18,
                          ),
                          label: const Text(
                            'Back to Health Home',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _informationRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 41,
          height: 41,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: _primary,
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
}