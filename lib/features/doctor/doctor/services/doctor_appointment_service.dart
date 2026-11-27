import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorAppointmentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in.');
    }
    return user.uid;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> doctorAppointments() {
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> patientAppointments() {
    return _db
        .collection('appointments')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> doctorPayments() {
    return _db
        .collection('payments')
        .where('doctorId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> notifications() {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  static DateTime? appointmentDateTime(Map<String, dynamic> data) {
    final value = data['appointmentDate'];

    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }

    // Legacy appointments may store date and time separately.
    final dateText = data['date']?.toString() ?? '';
    final timeText = data['time']?.toString() ?? '';

    DateTime? date = DateTime.tryParse(dateText);

    if (date == null) {
      final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$')
          .firstMatch(dateText);

      if (match != null) {
        date = DateTime(
          int.parse(match.group(3)!),
          int.parse(match.group(2)!),
          int.parse(match.group(1)!),
        );
      }
    }

    if (date == null) return null;

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(timeText.trim());

    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)?.toUpperCase();

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    if (hour > 23 || minute > 59) return null;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static bool isOverdue(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString().toLowerCase();

    if (!['confirmed', 'approved', 'rescheduled'].contains(status)) {
      return false;
    }

    final date = appointmentDateTime(data);
    return date != null && DateTime.now().isAfter(date);
  }

  static Future<void> completeAppointment(String appointmentId) async {
    await _finishAppointment(
      appointmentId: appointmentId,
      newStatus: 'completed',
    );
  }

  static Future<void> markNoShow(String appointmentId) async {
    await _finishAppointment(
      appointmentId: appointmentId,
      newStatus: 'no_show',
    );
  }

  static Future<void> _finishAppointment({
    required String appointmentId,
    required String newStatus,
  }) async {
    final doctorId = uid;

    final appointmentRef = _db.collection('appointments').doc(appointmentId);

    final notificationRef = _db.collection('notifications').doc();

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(appointmentRef);

      if (!snapshot.exists) {
        throw StateError('Appointment not found.');
      }

      final data = snapshot.data()!;

      if (data['doctorId'] != doctorId) {
        throw StateError(
          'Only the assigned doctor can update this appointment.',
        );
      }

      final currentStatus = (data['status'] ?? '').toString().toLowerCase();

      if (!['confirmed', 'approved', 'rescheduled'].contains(currentStatus)) {
        throw StateError('This appointment cannot be updated.');
      }

      final scheduledTime = appointmentDateTime(data);

      if (scheduledTime == null) {
        throw StateError('Appointment date or time is missing.');
      }

      final now = DateTime.now();

      if (now.isBefore(scheduledTime)) {
        throw StateError('The scheduled appointment time has not arrived.');
      }

      // Allow a 30-minute grace period before no-show.
      if (newStatus == 'no_show' &&
          now.isBefore(scheduledTime.add(const Duration(minutes: 30)))) {
        throw StateError(
          'Wait at least 30 minutes after the appointment time.',
        );
      }

      final patientId = (data['userId'] ?? data['patientId'] ?? '').toString();

      if (patientId.isEmpty) {
        throw StateError('Patient ID is missing.');
      }

      transaction.update(appointmentRef, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        if (newStatus == 'completed')
          'completedAt': FieldValue.serverTimestamp(),
        if (newStatus == 'no_show') 'noShowAt': FieldValue.serverTimestamp(),
        'statusUpdatedBy': doctorId,
      });

      transaction.set(notificationRef, {
        'userId': patientId,
        'patientId': patientId,
        'doctorId': doctorId,
        'appointmentId': appointmentId,
        'type': newStatus == 'completed'
            ? 'appointment_completed'
            : 'appointment_no_show',
        'title': newStatus == 'completed'
            ? 'Appointment Completed'
            : 'Missed Appointment',
        'message': newStatus == 'completed'
            ? 'Your doctor has marked your consultation as completed.'
            : 'Your doctor has marked your appointment as missed.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    await _updateAppointment(
      appointmentId: appointmentId,
      newStatus: 'cancelled',
    );
  }

  static Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime date,
    required String time,
  }) async {
    if (!date.isAfter(DateTime.now())) {
      throw StateError('Choose a future appointment time.');
    }

    await _updateAppointment(
      appointmentId: appointmentId,
      newStatus: 'rescheduled',
      date: date,
      time: time,
    );
  }

  static Future<void> _updateAppointment({
    required String appointmentId,
    required String newStatus,
    DateTime? date,
    String? time,
  }) async {
    final doctorId = uid;

    final appointmentRef = _db.collection('appointments').doc(appointmentId);

    final notificationRef = _db.collection('notifications').doc();

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(appointmentRef);

      if (!snapshot.exists) {
        throw StateError('Appointment not found.');
      }

      final data = snapshot.data()!;

      if (data['doctorId'] != doctorId) {
        throw StateError(
          'Only the assigned doctor can manage this appointment.',
        );
      }

      final currentStatus = (data['status'] ?? '').toString().toLowerCase();

      if (!['confirmed', 'approved', 'rescheduled'].contains(currentStatus)) {
        throw StateError('This appointment cannot be changed.');
      }

      final patientId = (data['userId'] ?? data['patientId'] ?? '').toString();

      if (patientId.isEmpty) {
        throw StateError('Patient ID is missing.');
      }

      transaction.update(appointmentRef, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusUpdatedBy': doctorId,
        if (newStatus == 'cancelled')
          'cancelledAt': FieldValue.serverTimestamp(),
        if (date != null) 'appointmentDate': Timestamp.fromDate(date),
        if (date != null)
          'date':
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': ?time,
      });

      transaction.set(notificationRef, {
        'userId': patientId,
        'patientId': patientId,
        'doctorId': doctorId,
        'appointmentId': appointmentId,
        'type': newStatus == 'cancelled'
            ? 'appointment_cancelled'
            : 'appointment_rescheduled',
        'title': newStatus == 'cancelled'
            ? 'Appointment Cancelled'
            : 'Appointment Rescheduled',
        'message': newStatus == 'cancelled'
            ? 'Your doctor has cancelled your appointment.'
            : 'Your appointment has been rescheduled to '
                  '${date?.day}/${date?.month}/${date?.year} '
                  'at ${time ?? ''}.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
