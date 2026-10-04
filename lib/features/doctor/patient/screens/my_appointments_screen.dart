import 'package:flutter/material.dart';
import 'reschedule_appointment_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState
    extends State<MyAppointmentsScreen> {
  static const Color _primary = Color(0xFF059669);
  static const Color _primaryDark = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);

  String _selectedTab = 'Upcoming';

  final List<String> _tabs = [
    'Upcoming',
    'Completed',
    'Cancelled',
  ];

  // Temporary local data.
  // Later replace this with Firestore appointments.
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': 'OC-1048',
      'doctor': 'Dr. Amali Silva',
      'specialty': 'Cardiologist',
      'hospital': 'City Heart Centre',
      'date': '08 Oct 2026',
      'day': 'Thursday',
      'time': '5:00 PM',
      'type': 'In-person',
      'fee': 3500,
      'status': 'Upcoming',
    },
    {
      'id': 'OC-1031',
      'doctor': 'Dr. Sachini Jayawardena',
      'specialty': 'Paediatrician',
      'hospital': 'Children Medical Centre',
      'date': '12 Oct 2026',
      'day': 'Monday',
      'time': '6:30 PM',
      'type': 'Video',
      'fee': 2800,
      'status': 'Upcoming',
    },
    {
      'id': 'OC-0975',
      'doctor': 'Dr. Nimal Perera',
      'specialty': 'General Physician',
      'hospital': 'Central Medical Centre',
      'date': '18 Sep 2026',
      'day': 'Friday',
      'time': '3:30 PM',
      'type': 'In-person',
      'fee': 2500,
      'status': 'Completed',
    },
    {
      'id': 'OC-0912',
      'doctor': 'Dr. Kasun Fernando',
      'specialty': 'Dermatologist',
      'hospital': 'Health Care Hospital',
      'date': '02 Sep 2026',
      'day': 'Wednesday',
      'time': '9:00 AM',
      'type': 'Video',
      'fee': 3000,
      'status': 'Cancelled',
    },
  ];

  List<Map<String, dynamic>> get _filteredAppointments {
    return _appointments
        .where(
          (appointment) =>
              appointment['status'] == _selectedTab,
        )
        .toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return _primary;

      case 'Completed':
        return const Color(0xFF2563EB);

      case 'Cancelled':
        return const Color(0xFFDC2626);

      default:
        return _muted;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFFECFDF5);

      case 'Completed':
        return const Color(0xFFEFF6FF);

      case 'Cancelled':
        return const Color(0xFFFEF2F2);

      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Upcoming':
        return Icons.schedule_rounded;

      case 'Completed':
        return Icons.check_circle_outline_rounded;

      case 'Cancelled':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline_rounded;
    }
  }

  void _openAppointmentDetails(
    Map<String, dynamic> appointment,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final status =
            appointment['status'].toString();

        return DraggableScrollableSheet(
          initialChildSize: 0.77,
          minChildSize: 0.55,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  22,
                  13,
                  22,
                  30,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFE2E8F0),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Appointment Details',
                          style: TextStyle(
                            color: _text,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _statusBackground(status),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _statusIcon(status),
                              color:
                                  _statusColor(status),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                color:
                                    _statusColor(status),
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Booking #${appointment['id']}',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 23),

                  // Doctor information

                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: _primaryDark,
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 65,
                          height: 69,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color:
                                Color(0xFF6EE7B7),
                            size: 37,
                          ),
                        ),

                        const SizedBox(width: 13),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                appointment['doctor'],
                                style:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                appointment[
                                    'specialty'],
                                style:
                                    const TextStyle(
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
                                    color: Color(
                                      0xFFA7F3D0,
                                    ),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      appointment[
                                          'hospital'],
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        color: Color(
                                          0xFFA7F3D0,
                                        ),
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

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFF8FAFC),
                      borderRadius:
                          BorderRadius.circular(19),
                      border: Border.all(
                        color:
                            const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          icon: Icons
                              .calendar_month_outlined,
                          label: 'Date',
                          value:
                              '${appointment['day']}, ${appointment['date']}',
                        ),

                        _divider(),

                        _detailRow(
                          icon: Icons.schedule_rounded,
                          label: 'Time',
                          value: appointment['time'],
                        ),

                        _divider(),

                        _detailRow(
                          icon:
                              appointment['type'] ==
                                      'Video'
                                  ? Icons
                                      .videocam_outlined
                                  : Icons
                                      .local_hospital_outlined,
                          label: 'Consultation',
                          value: appointment['type'],
                        ),

                        _divider(),

                        _detailRow(
                          icon: Icons.payments_outlined,
                          label: 'Consultation Fee',
                          value:
                              'LKR ${appointment['fee']}',
                        ),
                      ],
                    ),
                  ),

                  if (status == 'Upcoming') ...[
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );

                          // Later connect to:
                          // RescheduleAppointmentScreen
                        },
                        icon: const Icon(
                          Icons
                              .edit_calendar_outlined,
                        ),
                        label: const Text(
                          'Reschedule Appointment',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );

                          _showCancelConfirmation(
                            appointment,
                          );
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Cancel Appointment',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              const Color(
                            0xFFDC2626,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (status == 'Completed') ...[
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(sheetContext);

                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RescheduleAppointmentScreen(
                                appointment: appointment,
                              ),
                            ),
                          );

                          if (updated == true && mounted) {
                            setState(() {});
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                        ),
                        label: const Text(
                          'Book Again',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelConfirmation(
    Map<String, dynamic> appointment,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Cancel appointment?',
            style: TextStyle(
              color: _text,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel your appointment with ${appointment['doctor']}?',
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Keep Appointment',
                style: TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  appointment['status'] =
                      'Cancelled';

                  if (_selectedTab ==
                      'Upcoming') {
                    // Automatically disappears
                    // from Upcoming after cancel.
                  }
                });

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Appointment cancelled.',
                    ),
                    behavior:
                        SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(12),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
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
      padding: EdgeInsets.symmetric(
        vertical: 11,
      ),
      child: Divider(
        height: 1,
        color: Color(0xFFE2E8F0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments =
        _filteredAppointments;

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
                borderRadius:
                    BorderRadius.circular(13),
                border: Border.all(
                  color:
                      const Color(0xFFE2E8F0),
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
          'My Appointments',
          style: TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Column(
        children: [
          // =============================================
          // HEADER
          // =============================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              0,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _primaryDark,
                borderRadius:
                    BorderRadius.circular(24),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your appointments',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'View and manage your healthcare appointments.',
                          style: TextStyle(
                            color:
                                Color(0xFFA7F3D0),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12),

                  Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF6EE7B7),
                    size: 38,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =============================================
          // TABS
          // =============================================

          SizedBox(
            height: 43,
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final selected =
                    _selectedTab == tab;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  borderRadius:
                      BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? _primary
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(30),
                      border: Border.all(
                        color: selected
                            ? _primary
                            : const Color(
                                0xFFE2E8F0,
                              ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : _muted,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 17),

          // =============================================
          // APPOINTMENTS
          // =============================================

          Expanded(
            child: appointments.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),
                    itemCount:
                        appointments.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(
                      height: 11,
                    ),
                    itemBuilder:
                        (context, index) {
                      return _appointmentCard(
                        appointments[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard(
    Map<String, dynamic> appointment,
  ) {
    final status =
        appointment['status'].toString();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: () {
          _openAppointmentDetails(
            appointment,
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 62,
                    height: 68,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFECFDF5),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: _primary,
                      size: 34,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment[
                                    'doctor'],
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color: _text,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),

                            const SizedBox(width: 7),

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    _statusBackground(
                                  status,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color:
                                      _statusColor(
                                    status,
                                  ),
                                  fontSize: 8,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        Text(
                          appointment['specialty'],
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 10.5,
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
                              color: Color(
                                0xFF94A3B8,
                              ),
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                appointment[
                                    'hospital'],
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color: _muted,
                                  fontSize: 9.5,
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

              const SizedBox(height: 14),

              const Divider(
                height: 1,
                color: Color(0xFFE2E8F0),
              ),

              const SizedBox(height: 13),

              Row(
                children: [
                  Expanded(
                    child: _miniInfo(
                      icon: Icons
                          .calendar_month_outlined,
                      value:
                          appointment['date'],
                    ),
                  ),

                  Container(
                    height: 27,
                    width: 1,
                    color:
                        const Color(0xFFE2E8F0),
                  ),

                  Expanded(
                    child: _miniInfo(
                      icon:
                          Icons.schedule_rounded,
                      value:
                          appointment['time'],
                    ),
                  ),

                  Container(
                    height: 27,
                    width: 1,
                    color:
                        const Color(0xFFE2E8F0),
                  ),

                  Expanded(
                    child: _miniInfo(
                      icon:
                          appointment['type'] ==
                                  'Video'
                              ? Icons
                                  .videocam_outlined
                              : Icons
                                  .local_hospital_outlined,
                      value:
                          appointment['type'],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              Row(
                children: [
                  Text(
                    'Booking #${appointment['id']}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 9,
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'View Details',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(width: 3),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: _primary,
                    size: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniInfo({
    required IconData icon,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: _primary,
          size: 16,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _text,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 35,
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
                Icons
                    .calendar_month_outlined,
                color: _primary,
                size: 36,
              ),
            ),

            const SizedBox(height: 17),

            Text(
              'No $_selectedTab appointments',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Your appointments will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}