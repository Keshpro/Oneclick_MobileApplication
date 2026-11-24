import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/doctor_appointment_service.dart';
import 'doctor_patient_detail_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState
    extends State<DoctorDashboardScreen> {
  // Palette (UI only)
  static const Color brand = Color(0xFF087F6D);
  static const Color brandDark = Color(0xFF065F52);
  static const Color brandSoft = Color(0xFFE6F4F1);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color line = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF4F7F6);
  static const Color amber = Color(0xFFB45309);
  static const Color amberSoft = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color blueSoft = Color(0xFFEFF6FF);

  int _tab = 0;
  String _filter = 'All';

  String get uid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  final Set<String> _busyIds = {};

  static const Set<String> _activeStatuses = {
    'confirmed',
    'approved',
    'rescheduled',
  };

  static const Set<String> _finishedStatuses = {
    'completed',
    'no_show',
    'cancelled',
  };

  String _status(Map<String, dynamic> data) =>
      (data['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

  DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return null;

    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    final slash = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(raw);

    if (slash != null) {
      return DateTime(
        int.parse(slash.group(3)!),
        int.parse(slash.group(2)!),
        int.parse(slash.group(1)!),
      );
    }

    // Supports legacy dates such as "25 Nov 2026".
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    final named = RegExp(
      r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$',
    ).firstMatch(raw);

    if (named != null) {
      final monthName =
          named.group(2)!.toLowerCase();

      final month = months[
          monthName.substring(0, 3)];

      if (month != null) {
        return DateTime(
          int.parse(named.group(3)!),
          month,
          int.parse(named.group(1)!),
        );
      }
    }

    return null;
  }

  DateTime? _appointmentDate(
    Map<String, dynamic> data,
  ) {
    final primary = _date(data['appointmentDate']);

    if (primary != null) {
      return primary;
    }

    final date = _date(data['date']);
    if (date == null) return null;

    return date;
  }

  DateTime? _appointmentDateTime(
    Map<String, dynamic> data,
  ) {
    final primary = _date(data['appointmentDate']);

    if (primary != null) {
      // Timestamp is the authoritative full datetime.
      return primary;
    }

    final date = _date(data['date']);
    if (date == null) return null;

    final rawTime =
        (data['time'] ?? '').toString().trim();

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(rawTime);

    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)?.toUpperCase();

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    if (hour > 23 || minute > 59) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  String _dateText(DateTime? date) {
    if (date == null) return 'Date unavailable';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;

    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isUpcoming(Map<String, dynamic> data) {
    final status = _status(data);

    if (_finishedStatuses.contains(status)) {
      return false;
    }

    final date = _appointmentDateTime(data);

    if (date == null) return false;

    return !date.isBefore(DateTime.now());
  }

  bool _isOverdue(Map<String, dynamic> data) {
    if (!_activeStatuses.contains(_status(data))) {
      return false;
    }

    final date = _appointmentDateTime(data);

    return date != null &&
        DateTime.now().isAfter(date);
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _runAction(
    String id,
    Future<void> Function() action,
    String success,
  ) async {
    if (_busyIds.contains(id)) return;

    setState(() => _busyIds.add(id));

    try {
      await action();

      if (!mounted) return;
      _message(success);
    } catch (error) {
      if (!mounted) return;
      _message('Action failed: $error');
    } finally {
      if (mounted) {
        setState(() => _busyIds.remove(id));
      }
    }
  }

  Future<void> _complete(String id) async {
    final confirmed = await _confirm(
      title: 'Complete Appointment?',
      message:
          'Confirm that the patient was examined '
          'and the consultation is finished.',
      action: 'Complete',
    );

    if (!confirmed) return;

    await _runAction(
      id,
      () => DoctorAppointmentService
          .completeAppointment(id),
      'Appointment completed successfully.',
    );
  }

  Future<void> _noShow(String id) async {
    final confirmed = await _confirm(
      title: 'Mark as No-show?',
      message:
          'Confirm that the patient did not attend '
          'the scheduled appointment.',
      action: 'Mark No-show',
    );

    if (!confirmed) return;

    await _runAction(
      id,
      () => DoctorAppointmentService.markNoShow(id),
      'Appointment marked as no-show.',
    );
  }

  Future<void> _cancel(String id) async {
    final confirmed = await _confirm(
      title: 'Cancel Appointment?',
      message:
          'The patient will receive an in-app '
          'notification about the cancellation.',
      action: 'Cancel Appointment',
    );

    if (!confirmed) return;

    await _runAction(
      id,
      () => DoctorAppointmentService
          .cancelAppointment(id),
      'Appointment cancelled.',
    );
  }

  Future<void> _reschedule(String id) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: now.add(
        const Duration(days: 365),
      ),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!selected.isAfter(DateTime.now())) {
      _message('Select a future date and time.');
      return;
    }

    final timeText = time.format(context);

    await _runAction(
      id,
      () => DoctorAppointmentService
          .rescheduleAppointment(
        appointmentId: id,
        date: selected,
        time: timeText,
      ),
      'Appointment rescheduled.',
    );
  }

  // ===========================================================================
  // UI ONLY. Nothing below changes data, queries, conditions or actions.
  // ===========================================================================

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', //
  ];

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _filters = [
    'All',
    'Upcoming',
    'Overdue',
    'Confirmed',
    'Approved',
    'Rescheduled',
    'Completed',
    'No_show',
    'Cancelled',
    'Awaiting_payment',
    'Pending_cash',
    'Pending',
    'Requested',
  ];

  String _prettyDate(DateTime? date) {
    if (date == null) return 'Date unavailable';

    final day = '${date.day} ${_months[date.month - 1]}';

    if (_isToday(date)) return 'Today, $day';

    return '${_weekdays[date.weekday - 1]}, $day ${date.year}';
  }

  /// 250000 -> "2,500.00"
  String _money(int minor) {
    final whole = minor ~/ 100;
    final cents = (minor % 100).toString().padLeft(2, '0');
    final digits = whole.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return '$buffer.$cents';
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';

    final text = status.replaceAll('_', ' ');

    return text[0].toUpperCase() + text.substring(1);
  }

  /// (foreground, background)
  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'confirmed':
      case 'approved':
      case 'completed':
        return (brand, brandSoft);
      case 'rescheduled':
        return (blue, blueSoft);
      case 'cancelled':
        return (danger, dangerSoft);
      case 'no_show':
      case 'awaiting_payment':
      case 'pending':
      case 'requested':
      case 'pending_cash':
        return (amber, amberSoft);
      default:
        return (muted, const Color(0xFFF1F5F9));
    }
  }

  ButtonStyle get _outlinedStyle => OutlinedButton.styleFrom(
        foregroundColor: brand,
        minimumSize: const Size(0, 44),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );

  ButtonStyle get _filledStyle => FilledButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );

  ButtonStyle _quietStyle(Color color) => TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      );

  Widget _pill(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _notice(IconData icon, String text, Color fg, Color bg) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value, Color dot) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: ink,
                fontSize: 26,
                height: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: muted, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsPanel({
    required int today,
    required int confirmed,
    required int completed,
    required int cancelled,
    required int noShow,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$today',
                  style: const TextStyle(
                    color: brand,
                    fontSize: 44,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    today == 1 ? 'Appointment today' : 'Appointments today',
                    style: const TextStyle(
                      color: ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: line),
          IntrinsicHeight(
            child: Row(
              children: [
                _statCell('Confirmed', '$confirmed', brand),
                Container(width: 1, color: line),
                _statCell('Completed', '$completed', brandDark),
              ],
            ),
          ),
          const Divider(height: 1, color: line),
          IntrinsicHeight(
            child: Row(
              children: [
                _statCell('Cancelled', '$cancelled', danger),
                Container(width: 1, color: line),
                _statCell('No-show', '$noShow', amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _income() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: DoctorAppointmentService.doctorPayments(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Income error: ${snapshot.error}',
            style: const TextStyle(color: danger, fontSize: 13),
          );
        }

        if (!snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              minHeight: 4,
              color: brand,
              backgroundColor: brandSoft,
            ),
          );
        }

        final payments = snapshot.data!.docs.where((doc) {
          final data = doc.data();

          return data['module'] == 'doctor' &&
              data['method'] == 'card' &&
              data['status'] == 'demo_paid' &&
              data['environment'] == 'demo';
        }).toList();

        final amountMinor = payments.fold<int>(
          0,
          (total, doc) =>
              total + ((doc.data()['amountMinor'] as num?)?.toInt() ?? 0),
        );

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: brandSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                    color: brandDark,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Demo card income',
                    style: TextStyle(
                      color: brandDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'LKR',
                    style: TextStyle(
                      color: brandDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _money(amountMinor),
                        style: const TextStyle(
                          color: ink,
                          fontSize: 28,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${payments.length} simulated card payments. '
                'Not actual bank revenue.',
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(
    String title, {
    int? count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (count != null)
            _pill(
              '$count',
              count > 0 ? brand : muted,
              count > 0 ? brandSoft : const Color(0xFFF1F5F9),
            ),
        ],
      ),
    );
  }

  Widget _empty(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_available_outlined, size: 20, color: muted),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotCell(IconData icon, String label, String value, String? sub) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: muted),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(color: muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ink,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (sub != null && sub.isNotEmpty)
            Text(sub, style: const TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _bookingCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final status = _status(data);

    final manageable = _activeStatuses.contains(status);

    final scheduled = _appointmentDateTime(data);

    final now = DateTime.now();

    final canComplete =
        manageable && scheduled != null && !now.isBefore(scheduled);

    final canNoShow = manageable &&
        scheduled != null &&
        !now.isBefore(
          scheduled.add(
            const Duration(minutes: 30),
          ),
        );

    final overdue = _isOverdue(data);
    final busy = _busyIds.contains(doc.id);

    final patientName = (data['patientName'] ??
            data['userName'] ??
            data['userEmail'] ??
            'Patient')
        .toString();

    final isNew =
        status == 'awaiting_payment' || status == 'pending' || status == 'requested';

    final isCompleted = status == 'completed';

    final isNoShow = status == 'no_show';

    final (statusFg, statusBg) = _statusColors(status);
    final initial = patientName.trim().isEmpty
        ? 'P'
        : patientName.trim().characters.first.toUpperCase();
    final time = (data['time'] ?? '').toString();
    final paymentText =
        (data['paymentStatus'] ?? 'unpaid').toString().replaceAll('_', ' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: brandSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: brand,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Booking ${data['id'] ?? doc.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(width: 8),
                  _pill('New', amber, amberSoft),
                ],
              ],
            ),
          ),
          Container(
            color: surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _slotCell(
                  Icons.calendar_today_rounded,
                  'When',
                  _prettyDate(_appointmentDate(data)),
                  time,
                ),
                const SizedBox(width: 12),
                _slotCell(
                  Icons.medical_services_outlined,
                  'Consultation',
                  '${data['consultationType'] ?? data['type'] ?? 'Not specified'}',
                  null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(_statusLabel(status), statusFg, statusBg),
                _pill(
                  'Payment: $paymentText',
                  muted,
                  const Color(0xFFF1F5F9),
                ),
              ],
            ),
          ),
          if (overdue)
            _notice(
              Icons.schedule_rounded,
              'Overdue. Action required.',
              amber,
              amberSoft,
            ),
          if (isCompleted)
            _notice(
              Icons.check_circle_outline_rounded,
              'Consultation completed',
              brand,
              brandSoft,
            ),
          if (isNoShow)
            _notice(
              Icons.person_off_outlined,
              'Patient did not attend',
              muted,
              const Color(0xFFF1F5F9),
            ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: line),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (busy)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        color: brand,
                        backgroundColor: brandSoft,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: _outlinedStyle,
                        onPressed: busy
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DoctorPatientDetailScreen(
                                      appointmentData: {
                                        ...data,
                                        'docId': doc.id,
                                      },
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.person_search_outlined, size: 18),
                        label: const Text('Patient profile'),
                      ),
                    ),
                    if (canComplete) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: _filledStyle,
                          onPressed: busy ? null : () => _complete(doc.id),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Complete'),
                        ),
                      ),
                    ],
                  ],
                ),
                if (canNoShow || manageable)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 2,
                      children: [
                        if (canNoShow)
                          TextButton.icon(
                            style: _quietStyle(muted),
                            onPressed: busy ? null : () => _noShow(doc.id),
                            icon: const Icon(Icons.person_off_outlined, size: 17),
                            label: const Text('No-show'),
                          ),
                        if (manageable)
                          TextButton.icon(
                            style: _quietStyle(brand),
                            onPressed: busy ? null : () => _reschedule(doc.id),
                            icon: const Icon(Icons.edit_calendar_outlined, size: 17),
                            label: const Text('Reschedule'),
                          ),
                        if (manageable)
                          TextButton.icon(
                            style: _quietStyle(danger),
                            onPressed: busy ? null : () => _cancel(doc.id),
                            icon: const Icon(Icons.cancel_outlined, size: 17),
                            label: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doctorHeader() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('doctors').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Doctor profile unavailable',
            style: TextStyle(color: muted),
          );
        }

        if (!snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              minHeight: 4,
              color: brand,
              backgroundColor: brandSoft,
            ),
          );
        }

        final doctor = snapshot.data!.data();

        if (doctor == null) {
          return const Text(
            'Doctor profile not found',
            style: TextStyle(color: muted),
          );
        }

        final available = doctor['isAvailable'] == true;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: brand,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doctor workspace',
                style: TextStyle(
                  color: Color(0xFFBFE6DF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                (doctor['name'] ?? 'Doctor').toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(left: 14, right: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1FFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: available
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Available for consultations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: doctor['isAvailable'] == true,
                      activeTrackColor: const Color(0xFF34D399),
                      inactiveTrackColor: const Color(0x33FFFFFF),
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                      trackOutlineColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      onChanged: (value) async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('doctors')
                              .doc(uid)
                              .update({
                            'isAvailable': value,
                          });
                        } catch (error) {
                          _message(
                            'Update failed: $error',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _home(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final today = docs.where((doc) {
      return _isToday(
        _appointmentDate(doc.data()),
      );
    }).toList();

    final upcoming = docs.where((doc) {
      return _isUpcoming(doc.data());
    }).toList()
      ..sort((a, b) {
        final x = _appointmentDateTime(a.data());
        final y = _appointmentDateTime(b.data());

        return (x ?? DateTime(2100)).compareTo(y ?? DateTime(2100));
      });

    final newBookings = docs.where((doc) {
      final status = _status(doc.data());

      return !_finishedStatuses.contains(status) &&
          (status == 'awaiting_payment' ||
              status == 'pending' ||
              status == 'requested' ||
              (_activeStatuses.contains(status) && _isUpcoming(doc.data())));
    }).toList()
      ..sort((a, b) {
        final x = _appointmentDateTime(a.data());
        final y = _appointmentDateTime(b.data());

        return (x ?? DateTime(2100)).compareTo(y ?? DateTime(2100));
      });

    final confirmed = docs.where((doc) {
      return _activeStatuses.contains(
        _status(doc.data()),
      );
    }).length;

    final completed = docs.where((doc) {
      return _status(doc.data()) == 'completed';
    }).length;

    final noShow = docs.where((doc) {
      return _status(doc.data()) == 'no_show';
    }).length;

    final cancelled = docs.where((doc) {
      return _status(doc.data()) == 'cancelled';
    }).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _doctorHeader(),
        const SizedBox(height: 16),
        _statsPanel(
          today: today.length,
          confirmed: confirmed,
          completed: completed,
          cancelled: cancelled,
          noShow: noShow,
        ),
        const SizedBox(height: 16),
        _income(),
        _sectionTitle(
          'New Appointments',
          count: newBookings.length,
        ),
        if (newBookings.isEmpty)
          _empty('No new appointments')
        else
          ...newBookings.map(_bookingCard),
        _sectionTitle(
          'Upcoming Appointments',
          count: upcoming.length,
        ),
        if (upcoming.isEmpty)
          _empty('No upcoming appointments')
        else
          ...upcoming.map(_bookingCard),
        _sectionTitle(
          "Today's Appointments",
          count: today.length,
        ),
        if (today.isEmpty)
          _empty('No appointments today')
        else
          ...today.map(_bookingCard),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: _outlinedStyle.copyWith(
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
          ),
          onPressed: () {
            setState(() {
              _tab = 1;
              _filter = 'All';
            });
          },
          icon: const Icon(
            Icons.calendar_month_outlined,
            size: 20,
          ),
          label: const Text(
            'View All Appointments',
          ),
        ),
      ],
    );
  }

  Widget _bookings(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered = docs.where((doc) {
      if (_filter == 'All') return true;

      if (_filter == 'Upcoming') {
        return _isUpcoming(doc.data());
      }

      if (_filter == 'Overdue') {
        return _isOverdue(doc.data());
      }

      return _status(doc.data()) == _filter.toLowerCase();
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final value = _filters[index];
              final selected = _filter == value;

              return ChoiceChip(
                label: Text(value.replaceAll('_', ' ')),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) {
                  setState(() {
                    _filter = value;
                  });
                },
                selectedColor: brand,
                backgroundColor: Colors.white,
                side: BorderSide(color: selected ? brand : line),
                shape: const StadiumBorder(),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              filtered.length == 1
                  ? '1 appointment'
                  : '${filtered.length} appointments',
              style: const TextStyle(color: muted, fontSize: 13),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_busy_outlined, size: 36, color: muted),
                      SizedBox(height: 10),
                      Text(
                        'No appointments found',
                        style: TextStyle(color: muted, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (_, index) => _bookingCard(
                    filtered[index],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _notifications() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: DoctorAppointmentService.notifications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Notification error: ${snapshot.error}',
              style: const TextStyle(color: danger),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: brand),
          );
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final x = _date(
              a.data()['timestamp'],
            );

            final y = _date(
              b.data()['timestamp'],
            );

            return (y ?? DateTime(1970)).compareTo(x ?? DateTime(1970));
          });

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none_rounded, size: 40, color: muted),
                SizedBox(height: 10),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: muted, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: docs.length,
          itemBuilder: (_, index) {
            final doc = docs[index];
            final data = doc.data();
            final unread = data['isRead'] != true;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: unread ? brandSoft : Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    try {
                      await doc.reference.update({
                        'isRead': true,
                      });
                    } catch (error) {
                      _message(
                        'Could not mark as read: $error',
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: unread ? const Color(0xFFBFE6DF) : line,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: unread ? Colors.white : brandSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 20,
                            color: brand,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (data['title'] ?? '').toString(),
                                style: TextStyle(
                                  color: ink,
                                  fontSize: 15,
                                  fontWeight:
                                      unread ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                (data['message'] ?? '').toString(),
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 10),
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              color: brand,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: Text(
            'Please sign in.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
        title: const Text(
          'OneClick Doctor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Icon(
              _tab == 2
                  ? Icons.notifications_rounded
                  : Icons.notifications_outlined,
              color: _tab == 2 ? brand : ink,
            ),
            onPressed: () {
              setState(() => _tab = 2);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: DoctorAppointmentService.doctorAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Firestore error: ${snapshot.error}',
                style: const TextStyle(color: danger),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: brand),
            );
          }

          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final x = _appointmentDateTime(a.data());

              final y = _appointmentDateTime(b.data());

              return (x ?? DateTime(2100)).compareTo(
                y ?? DateTime(2100),
              );
            });

          if (_tab == 0) {
            return _home(docs);
          }

          if (_tab == 1) {
            return _bookings(docs);
          }

          return _notifications();
        },
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: line)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: brandSoft,
          elevation: 0,
          selectedIndex: _tab,
          onDestinationSelected: (index) {
            setState(() => _tab = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: brand),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: brand),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications_rounded, color: brand),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}