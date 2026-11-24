
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'doctor_schedule_manage_screen.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() =>
      _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState
    extends State<DoctorScheduleScreen> {
  static const Color _green = Color(0xFF059669);
  static const Color _darkGreen = Color(0xFF064E3B);
  static const Color _background = Color(0xFFF7FAF9);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _blue = Color(0xFF0284C7);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _orange = Color(0xFFD97706);
  static const Color _red = Color(0xFFDC2626);

  DateTime _selectedDate = DateTime.now();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _displayDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _dayLabel(DateTime date) {
    if (_sameDay(date, DateTime.now())) return 'Today';

    final tomorrow = DateTime.now().add(
      const Duration(days: 1),
    );

    if (_sameDay(date, tomorrow)) return 'Tomorrow';

    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];

    return days[date.weekday - 1];
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return _green;
      case 'completed':
        return _blue;
      case 'rescheduled':
        return _purple;
      case 'cancelled':
        return _red;
      default:
        return _orange;
    }
  }

  int _timeMinutes(dynamic raw) {
    final value = raw.toString().trim().toUpperCase();

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
    ).firstMatch(value);

    if (match == null) return 9999;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3);

    if (minute > 59 || hour > 23) return 9999;

    if (period != null) {
      if (hour < 1 || hour > 12) return 9999;
      hour = hour % 12;
      if (period == 'PM') hour += 12;
    }

    return hour * 60 + minute;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
      helpText: 'Select schedule date',
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _changeDay(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(
        Duration(days: days),
      );
    });
  }

  void _openManageSchedule() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DoctorScheduleManageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        toolbarHeight: 68,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Schedule',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Doctor workspace',
              style: TextStyle(
                color: _muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Manage schedule',
            onPressed: _openManageSchedule,
            icon: const Icon(
              Icons.settings_rounded,
              color: _purple,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: uid == null
          ? const Center(
              child: Text('Please sign in as a doctor.'),
            )
          : StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _emptyState(
                    'Unable to load schedule',
                    'Check your connection and permissions.',
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: _green,
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final now = DateTime.now();

                final todayCount = docs.where((doc) {
                  final date = _parseDate(doc.data()['date']);
                  final status = (doc.data()['status'] ?? '')
                      .toString()
                      .toLowerCase();

                  return date != null &&
                      _sameDay(date, now) &&
                      status != 'cancelled';
                }).length;

                final upcomingCount = docs.where((doc) {
                  final date = _parseDate(doc.data()['date']);
                  final status = (doc.data()['status'] ?? '')
                      .toString()
                      .toLowerCase();

                  return date != null &&
                      !date.isBefore(
                        DateTime(now.year, now.month, now.day),
                      ) &&
                      !['cancelled', 'completed']
                          .contains(status);
                }).length;

                final completedCount = docs.where((doc) {
                  return (doc.data()['status'] ?? '')
                          .toString()
                          .toLowerCase() ==
                      'completed';
                }).length;

                final selectedDocs = docs.where((doc) {
                  final date = _parseDate(doc.data()['date']);
                  return date != null &&
                      _sameDay(date, _selectedDate);
                }).toList();

                selectedDocs.sort((a, b) {
                  return _timeMinutes(a.data()['time'])
                      .compareTo(
                    _timeMinutes(b.data()['time']),
                  );
                });

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    18, 20, 18, 35,
                  ),
                  children: [
                    _hero(),
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'Schedule Overview',
                      'Your appointments at a glance',
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Today',
                            '$todayCount',
                            Icons.today_rounded,
                            _blue,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _statCard(
                            'Upcoming',
                            '$upcomingCount',
                            Icons.event_available_rounded,
                            _orange,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _statCard(
                            'Completed',
                            '$completedCount',
                            Icons.task_alt_rounded,
                            _green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    _sectionTitle(
                      'Daily Schedule',
                      'Select a day to view appointments',
                    ),
                    const SizedBox(height: 13),
                    _dateSelector(),
                    const SizedBox(height: 16),
                    Text(
                      '${selectedDocs.length} appointments',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedDocs.isEmpty)
                      _emptyState(
                        'No appointments',
                        'There are no bookings for this date.',
                      )
                    else
                      ...selectedDocs.map(_appointmentCard),
                    const SizedBox(height: 20),
                    _manageButton(),
                  ],
                );
              },
            ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _darkGreen,
            _green,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Plan your day\nwith confidence.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'View upcoming consultations and keep track '
            'of your daily patient appointments.',
            style: TextStyle(
              color: Color(0xFFD1FAE5),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            onPressed: () => _changeDay(-1),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: _green,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Text(
                    _dayLabel(_selectedDate),
                    style: const TextStyle(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _displayDate(_selectedDate),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            onPressed: () => _changeDay(1),
            icon: const Icon(
              Icons.chevron_right_rounded,
              color: _green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final name = (data['patientName'] ??
            data['userEmail'] ??
            'Patient')
        .toString();

    final status =
        (data['status'] ?? 'Upcoming').toString();

    final time =
        (data['time'] ?? 'Time not set').toString();

    final type =
        (data['type'] ?? 'In-person').toString();

    final reason =
        (data['reason'] ?? '').toString().trim();

    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(
                Icons.person_rounded,
                _blue,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 13),
          Wrap(
            spacing: 15,
            runSpacing: 10,
            children: [
              _detail(
                Icons.access_time_rounded,
                time,
                _purple,
              ),
              _detail(
                Icons.medical_services_outlined,
                type,
                _green,
              ),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    color: _orange,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detail(
    IconData icon,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(icon, color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: _text,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _manageButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _openManageSchedule,
        icon: const Icon(Icons.settings_rounded),
        label: const Text(
          'Manage Schedule & Availability',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_available_rounded,
            color: _green,
            size: 37,
          ),
          const SizedBox(height: 13),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
