
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/payment_request.dart';

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> processDemoPayment({
    required PaymentRequest request,
    required String method,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'Please log in before making a payment.',
      );
    }

    if (request.amountMinor <= 0) {
      throw StateError('Invalid payment amount.');
    }

    if (method != 'card' && method != 'cash') {
      throw StateError('Invalid payment method.');
    }

    // Doctor payments require an atomic transaction so
    // payment, appointment and notification stay consistent.
    if (request.module == 'doctor') {
      return _processDoctorPayment(
        request: request,
        method: method,
        user: user,
      );
    }

    // Keep the existing payment flow for all other modules.
    final paymentRef = _db.collection('payments').doc();

    final status =
        method == 'card' ? 'demo_paid' : 'pending_cash';

    await paymentRef.set({
      'paymentId': paymentRef.id,
      'bookingId': request.bookingId,
      'module': request.module,
      'title': request.title,
      'userId': user.uid,
      'userEmail': user.email ?? '',
      'amountMinor': request.amountMinor,
      'amount': request.amountMinor / 100,
      'currency': 'LKR',
      'method': method,
      'status': status,
      'provider': 'oneclick_demo',
      'environment': 'demo',
      'isRealPayment': false,
      'customer': request.customer,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return paymentRef.id;
  }

  // ------------------------------------------------------
  // DOCTOR PAYMENT + APPOINTMENT + NOTIFICATION
  // ------------------------------------------------------

  static Future<String> _processDoctorPayment({
    required PaymentRequest request,
    required String method,
    required User user,
  }) async {
    final appointmentRef =
        _db.collection('appointments').doc(request.bookingId);

    final paymentRef = _db.collection('payments').doc();

    final notificationRef = _db
        .collection('notifications')
        .doc('doctor_booking_${request.bookingId}');

    final paymentStatus =
        method == 'card' ? 'demo_paid' : 'pending_cash';

    await _db.runTransaction((transaction) async {
      // All reads must happen before transaction writes.
      final appointmentSnapshot =
          await transaction.get(appointmentRef);

      if (!appointmentSnapshot.exists) {
        throw StateError('Doctor appointment not found.');
      }

      final appointment = appointmentSnapshot.data()!;

      // Validate ownership.
      if (appointment['userId'] != user.uid) {
        throw StateError(
          'You cannot pay for this appointment.',
        );
      }

      final appointmentStatus =
          (appointment['status'] ?? '').toString();

      if (appointmentStatus != 'awaiting_payment') {
        throw StateError(
          'This appointment is not awaiting payment.',
        );
      }

      final existingPaymentId = appointment['paymentId'];

      if (existingPaymentId != null &&
          existingPaymentId.toString().isNotEmpty) {
        throw StateError(
          'This appointment already has a payment.',
        );
      }

      final doctorId =
          (appointment['doctorId'] ?? '').toString();

      if (doctorId.isEmpty) {
        throw StateError(
          'Doctor ID is missing from the appointment.',
        );
      }

      // The amount must match the stored appointment fee.
      final storedAmount = appointment['amountMinor'];

      if (storedAmount is! num ||
          storedAmount.toInt() != request.amountMinor ||
          storedAmount.toInt() <= 0) {
        throw StateError(
          'Payment amount does not match the appointment.',
        );
      }

      final patientName =
          (appointment['patientName'] ??
                  appointment['userName'] ??
                  user.displayName ??
                  user.email ??
                  'Patient')
              .toString();

      final doctorName =
          (appointment['doctorName'] ?? 'Doctor')
              .toString();

      // 1. Create payment record.
      transaction.set(paymentRef, {
        'paymentId': paymentRef.id,
        'bookingId': request.bookingId,
        'module': 'doctor',
        'title': request.title,

        // Patient information
        'userId': user.uid,
        'patientId': user.uid,
        'patientName': patientName,
        'userEmail': user.email ?? '',

        // Doctor information
        'doctorId': doctorId,
        'doctorName': doctorName,

        // Payment information
        'amountMinor': request.amountMinor,
        'amount': request.amountMinor / 100,
        'currency': 'LKR',
        'method': method,
        'status': paymentStatus,

        // Demo payment information
        'provider': 'oneclick_demo',
        'environment': 'demo',
        'isRealPayment': false,
        'customer': request.customer,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Automatically confirm appointment.
      transaction.update(appointmentRef, {
        'status': 'confirmed',
        'paymentId': paymentRef.id,
        'paymentStatus': paymentStatus,
        'paymentMethod': method,
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Create doctor's in-app notification.
      transaction.set(notificationRef, {
        'userId': doctorId,
        'doctorId': doctorId,
        'patientId': user.uid,
        'appointmentId': request.bookingId,
        'paymentId': paymentRef.id,
        'type': 'new_appointment',
        'title': 'New Appointment Confirmed',
        'message':
            '$patientName booked an appointment '
            'for ${appointment['date'] ?? 'the selected date'} '
            'at ${appointment['time'] ?? 'the selected time'}.',
        'paymentMethod': method,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return paymentRef.id;
  }

  // ------------------------------------------------------
  // USER PAYMENT HISTORY
  // ------------------------------------------------------

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      userPaymentHistory() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User not logged in.');
    }

    return _db
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }
}
