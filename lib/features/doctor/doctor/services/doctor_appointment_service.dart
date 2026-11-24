
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorAppointmentService {
  DoctorAppointmentService._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in first.');
    }
    return user.uid;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      doctorAppointments() {
    return db
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      patientAppointments() {
    return db
        .collection('appointments')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      doctorPayments() {
    return db
        .collection('payments')
        .where('doctorId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      notifications() {
    return db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  static Future<String> createAppointment({
    required String doctorId,
    required String doctorName,
    required DateTime appointmentDate,
    required String time,
    required String consultationType,
    required int amountMinor,
    required String reason,
  }) async {
    if (doctorId.isEmpty || amountMinor <= 0) {
      throw StateError('Invalid doctor or consultation fee.');
    }

    final user = FirebaseAuth.instance.currentUser!;
    final ref = db.collection('appointments').doc();

    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email ?? 'Patient');

    await ref.set({
      'docId': ref.id,
      'id': 'OC-${ref.id.substring(0, 5).toUpperCase()}',
      'userId': user.uid,
      'patientId': user.uid,
      'patientName': name,
      'userName': name,
      'userEmail': user.email ?? '',
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'date':
          '${appointmentDate.day.toString().padLeft(2, '0')} '
          '${_month(appointmentDate.month)} ${appointmentDate.year}',
      'time': time,
      'type': consultationType,
      'reason': reason,
      'amountMinor': amountMinor,
      'fee': amountMinor / 100,
      'currency': 'LKR',
      'status': 'awaiting_payment',
      'paymentStatus': 'unpaid',
      'paymentId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  static String _month(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  static Future<String> completeDemoCheckout({
    required String appointmentId,
    required String method,
  }) async {
    if (method != 'card' && method != 'cash') {
      throw StateError('Invalid payment method.');
    }

    final appointmentRef =
        db.collection('appointments').doc(appointmentId);
    final paymentRef = db.collection('payments').doc();
    final notificationRef = db
        .collection('notifications')
        .doc('doctor_booking_$appointmentId');

    final paymentStatus =
        method == 'card' ? 'demo_paid' : 'pending_cash';

    await db.runTransaction((tx) async {
      final snapshot = await tx.get(appointmentRef);

      if (!snapshot.exists) {
        throw StateError('Appointment not found.');
      }

      final data = snapshot.data()!;

      if (data['userId'] != uid) {
        throw StateError('Unauthorized appointment.');
      }

      if (data['status'] != 'awaiting_payment' ||
          data['paymentId'] != null) {
        throw StateError('Appointment already checked out.');
      }

      final doctorId = data['doctorId']?.toString() ?? '';
      final amount = data['amountMinor'];

      if (doctorId.isEmpty ||
          amount is! int ||
          amount <= 0) {
        throw StateError('Invalid appointment data.');
      }

      tx.set(paymentRef, {
        'bookingId': appointmentId,
        'orderId': paymentRef.id,
        'userId': uid,
        'patientId': uid,
        'doctorId': doctorId,
        'module': 'doctor',
        'title': 'Doctor Consultation',
        'method': method,
        'status': paymentStatus,
        'amountMinor': amount,
        'currency': 'LKR',
        'environment': 'demo',
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(appointmentRef, {
        'status': 'confirmed',
        'paymentId': paymentRef.id,
        'paymentMethod': method,
        'paymentStatus': paymentStatus,
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      tx.set(notificationRef, {
        'userId': doctorId,
        'doctorId': doctorId,
        'appointmentId': appointmentId,
        'type': 'new_appointment',
        'title': 'New Appointment',
        'message':
            '${data['patientName']} booked an appointment '
            'for ${data['date']} at ${data['time']}.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });

    return paymentRef.id;
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    await _doctorUpdate(
      appointmentId: appointmentId,
      newStatus: 'cancelled',
    );
  }

  static Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime date,
    required String time,
  }) async {
    await _doctorUpdate(
      appointmentId: appointmentId,
      newStatus: 'rescheduled',
      date: date,
      time: time,
    );
  }

  static Future<void> _doctorUpdate({
    required String appointmentId,
    required String newStatus,
    DateTime? date,
    String? time,
  }) async {
    final ref = db.collection('appointments').doc(appointmentId);
    final notificationRef = db.collection('notifications').doc();

    await db.runTransaction((tx) async {
      final snapshot = await tx.get(ref);

      if (!snapshot.exists) {
        throw StateError('Appointment not found.');
      }

      final data = snapshot.data()!;

      if (data['doctorId'] != uid) {
        throw StateError('Only the assigned doctor can manage this.');
      }

      final currentStatus =
          (data['status'] ?? '').toString().toLowerCase();

      if (!['confirmed', 'rescheduled', 'approved']
          .contains(currentStatus)) {
        throw StateError('Appointment cannot be modified.');
      }

      final patientId = data['userId']?.toString() ?? '';
      if (patientId.isEmpty) {
        throw StateError('Patient ID missing.');
      }

      final changes = <String, dynamic>{
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == 'rescheduled') {
        if (date == null || time == null) {
          throw StateError('Date and time required.');
        }

        changes['appointmentDate'] = Timestamp.fromDate(date);
        changes['date'] =
            '${date.day.toString().padLeft(2, '0')} '
            '${_month(date.month)} ${date.year}';
        changes['time'] = time;
        changes['rescheduledBy'] = uid;
      } else {
        changes['cancelledBy'] = uid;
        changes['cancelledAt'] = FieldValue.serverTimestamp();
      }

      tx.update(ref, changes);

      tx.set(notificationRef, {
        'userId': patientId,
        'appointmentId': appointmentId,
        'type': 'appointment_$newStatus',
        'title': newStatus == 'cancelled'
            ? 'Appointment Cancelled'
            : 'Appointment Rescheduled',
        'message': newStatus == 'cancelled'
            ? 'Your doctor cancelled your appointment.'
            : 'Your appointment was moved to '
                '${changes['date']} at $time.',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }
}
