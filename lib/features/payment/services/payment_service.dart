import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/payment_request.dart';

class PaymentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ======================================================
  // COMMON PAYMENT PROCESS
  // ======================================================

  static Future<String> processDemoPayment({
    required PaymentRequest request,
    required String method,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Please log in before making a payment.');
    }

    if (request.amountMinor <= 0) {
      throw StateError('Invalid payment amount.');
    }

    if (method != 'card' && method != 'cash') {
      throw StateError('Invalid payment method.');
    }

    // Doctor module
    if (request.module == 'doctor') {
      return _processDoctorPayment(
        request: request,
        method: method,
        user: user,
      );
    }

    // QuickFix module
    if (request.module == 'quickfix') {
      return _processQuickFixPayment(
        request: request,
        method: method,
        user: user,
      );
    }

    // Existing generic payment flow
    // Grocery, Food, Drink & Drive and other modules

    final paymentRef = _db.collection('payments').doc();

    final status = method == 'card' ? 'demo_paid' : 'pending_cash';

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

  // ======================================================
  // DOCTOR PAYMENT
  // EXISTING LOGIC PRESERVED
  // ======================================================

  static Future<String> _processDoctorPayment({
    required PaymentRequest request,
    required String method,
    required User user,
  }) async {
    final appointmentRef = _db
        .collection('appointments')
        .doc(request.bookingId);

    final paymentRef = _db.collection('payments').doc();

    final notificationRef = _db
        .collection('notifications')
        .doc('doctor_booking_${request.bookingId}');

    final paymentStatus = method == 'card' ? 'demo_paid' : 'pending_cash';

    await _db.runTransaction((transaction) async {
      final appointmentSnapshot = await transaction.get(appointmentRef);

      if (!appointmentSnapshot.exists) {
        throw StateError('Doctor appointment not found.');
      }

      final appointment = appointmentSnapshot.data()!;

      if (appointment['userId'] != user.uid) {
        throw StateError('You cannot pay for this appointment.');
      }

      final appointmentStatus = (appointment['status'] ?? '').toString();

      if (appointmentStatus != 'awaiting_payment') {
        throw StateError('This appointment is not awaiting payment.');
      }

      final existingPaymentId = appointment['paymentId'];

      if (existingPaymentId != null &&
          existingPaymentId.toString().isNotEmpty) {
        throw StateError('This appointment already has a payment.');
      }

      final doctorId = (appointment['doctorId'] ?? '').toString();

      if (doctorId.isEmpty) {
        throw StateError('Doctor ID is missing from the appointment.');
      }

      final storedAmount = appointment['amountMinor'];

      if (storedAmount is! num ||
          storedAmount.toInt() != request.amountMinor ||
          storedAmount.toInt() <= 0) {
        throw StateError('Payment amount does not match the appointment.');
      }

      final patientName =
          (appointment['patientName'] ??
                  appointment['userName'] ??
                  user.displayName ??
                  user.email ??
                  'Patient')
              .toString();

      final doctorName = (appointment['doctorName'] ?? 'Doctor').toString();

      // Create payment record

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

        // Demo information
        'provider': 'oneclick_demo',
        'environment': 'demo',
        'isRealPayment': false,
        'customer': request.customer,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Confirm doctor appointment

      transaction.update(appointmentRef, {
        'status': 'confirmed',
        'paymentId': paymentRef.id,
        'paymentStatus': paymentStatus,
        'paymentMethod': method,
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify doctor

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

  // ======================================================
  // QUICKFIX PAYMENT
  // ======================================================

  static Future<String> _processQuickFixPayment({
    required PaymentRequest request,
    required String method,
    required User user,
  }) async {
    final bookingId = request.bookingId.trim();

    if (bookingId.isEmpty || bookingId.contains('/')) {
      throw StateError('Invalid QuickFix booking ID.');
    }

    final bookingRef = _db.collection('work_appointments').doc(bookingId);

    // Deterministic payment ID.
    // One payment record per QuickFix booking.

    final paymentRef = _db.collection('payments').doc('quickfix_$bookingId');

    final notificationRef = _db
        .collection('quickfix_notifications')
        .doc('payment_$bookingId');

    final paymentStatus = method == 'card' ? 'demo_paid' : 'pending_cash';

    return _db.runTransaction<String>((transaction) async {
      // ------------------------------------------------
      // 1. AUTHENTICATION VALIDATION
      // ------------------------------------------------

      if (_auth.currentUser?.uid != user.uid) {
        throw StateError('Your session has changed. Please try again.');
      }

      // ------------------------------------------------
      // 2. READ BOOKING
      // ------------------------------------------------

      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists) {
        throw StateError('QuickFix booking not found.');
      }

      final booking = bookingSnapshot.data()!;

      // ------------------------------------------------
      // 3. CUSTOMER OWNERSHIP VALIDATION
      // ------------------------------------------------

      final customerId = (booking['customerId'] ?? '').toString().trim();

      if (customerId.isEmpty || customerId != user.uid) {
        throw StateError('You cannot pay for this booking.');
      }

      // ------------------------------------------------
      // 4. SERVICE VALIDATION
      // ------------------------------------------------

      if (booking['serviceType'] != 'quickfix') {
        throw StateError('Invalid or outdated QuickFix booking.');
      }

      // ------------------------------------------------
      // 5. DUPLICATE PAYMENT PREVENTION
      // ------------------------------------------------

      final existingPaymentId = (booking['paymentId'] ?? '').toString().trim();

      final existingPaymentStatus = (booking['paymentStatus'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (existingPaymentId.isNotEmpty ||
          existingPaymentStatus == 'demo_paid' ||
          existingPaymentStatus == 'pending_cash' ||
          existingPaymentStatus == 'paid') {
        throw StateError('This booking already has a payment record.');
      }

      // ------------------------------------------------
      // 6. BOOKING STATUS VALIDATION
      // ------------------------------------------------

      final bookingStatus = (booking['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (bookingStatus != 'accepted' && bookingStatus != 'approved') {
        throw StateError(
          'The worker must approve your booking '
          'before you can make a payment.',
        );
      }

      // ------------------------------------------------
      // 7. WORKER VALIDATION
      // ------------------------------------------------

      final workerId = (booking['workerId'] ?? '').toString().trim();

      if (workerId.isEmpty) {
        throw StateError('Worker information is missing.');
      }

      if (workerId == user.uid) {
        throw StateError('You cannot pay for your own worker booking.');
      }

      // ------------------------------------------------
      // 8. PAYMENT AMOUNT VALIDATION
      // ------------------------------------------------

      final storedAmount = booking['amountMinor'];

      if (storedAmount is! num ||
          !storedAmount.isFinite ||
          storedAmount <= 0 ||
          storedAmount != storedAmount.toInt()) {
        throw StateError('The booking does not have a valid payment amount.');
      }

      final amountMinor = storedAmount.toInt();

      if (amountMinor != request.amountMinor) {
        throw StateError('Payment amount does not match the booking.');
      }

      // ------------------------------------------------
      // 9. BOOKING INFORMATION
      // ------------------------------------------------

      final workerName = (booking['workerName'] ?? 'Worker').toString();

      final customerName =
          (booking['customerName'] ??
                  user.displayName ??
                  user.email ??
                  'Customer')
              .toString();

      final category = (booking['category'] ?? 'QuickFix Service').toString();

      final title = 'QuickFix - $category';

      // ------------------------------------------------
      // 10. CREATE PAYMENT RECORD
      // ------------------------------------------------

      transaction.set(paymentRef, {
        // Payment identification
        'paymentId': paymentRef.id,
        'bookingId': bookingId,
        'appointmentId': bookingId,

        // Service information
        'module': 'quickfix',
        'serviceType': 'quickfix',
        'title': title,
        'category': category,

        // Customer information
        // userId is required for Personal Vault
        'userId': user.uid,
        'customerId': user.uid,
        'customerName': customerName,
        'userEmail': user.email ?? '',

        // Worker information
        // workerId is required for Worker Income
        'workerId': workerId,
        'workerName': workerName,

        // Payment information
        'amountMinor': amountMinor,
        'amount': amountMinor / 100,
        'currency': 'LKR',
        'method': method,
        'status': paymentStatus,

        // Demo payment information
        'provider': 'oneclick_demo',
        'environment': 'demo',
        'isRealPayment': false,

        // Timestamps
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        if (method == 'card') 'paidAt': FieldValue.serverTimestamp(),
      });

      // ------------------------------------------------
      // 11. UPDATE EXISTING BOOKING
      // ------------------------------------------------

      // Preserve Accepted / Approved appointment status.
      // Payment does not mean the service is completed.

      transaction.update(bookingRef, {
        'paymentId': paymentRef.id,
        'paymentStatus': paymentStatus,
        'paymentMethod': method,
        'paymentEnvironment': 'demo',
        'isRealPayment': false,
        'updatedAt': FieldValue.serverTimestamp(),

        if (method == 'card') 'paidAt': FieldValue.serverTimestamp(),

        if (method == 'cash') 'cashSelectedAt': FieldValue.serverTimestamp(),
      });

      // ------------------------------------------------
      // 12. WORKER PAYMENT NOTIFICATION
      // ------------------------------------------------

      transaction.set(notificationRef, {
        'receiverId': workerId,
        'senderId': user.uid,
        'appointmentId': bookingId,
        'paymentId': paymentRef.id,

        'title': method == 'card'
            ? 'Demo Payment Received'
            : 'Cash Payment Selected',

        'message': method == 'card'
            ? 'A demo card payment of '
                  'LKR ${(amountMinor / 100).toStringAsFixed(2)} '
                  'was recorded for your QuickFix booking.'
            : 'The customer has selected cash payment '
                  'for your QuickFix booking.',

        'type': method == 'card' ? 'payment_received' : 'cash_payment_selected',

        'paymentStatus': paymentStatus,
        'paymentMethod': method,
        'amountMinor': amountMinor,
        'isRead': false,

        'createdAt': FieldValue.serverTimestamp(),
      });

      return paymentRef.id;
    });
  }

  // ======================================================
  // LOGGED-IN USER PAYMENT HISTORY
  // PERSONAL VAULT
  // ======================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> userPaymentHistory() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User not logged in.');
    }

    return _db
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  // ======================================================
  // QUICKFIX WORKER PAYMENT HISTORY
  // ======================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>> workerPaymentHistory() {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Worker not logged in.');
    }

    return _db
        .collection('payments')
        .where('workerId', isEqualTo: user.uid)
        .where('module', isEqualTo: 'quickfix')
        .snapshots();
  }
}
