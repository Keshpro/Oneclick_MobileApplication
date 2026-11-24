
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
      throw Exception('Please log in before making a payment.');
    }

    if (request.amountMinor <= 0) {
      throw Exception('Invalid payment amount.');
    }

    if (method != 'card' && method != 'cash') {
      throw Exception('Invalid payment method.');
    }

    final paymentRef = _db.collection('payments').doc();

    final status = method == 'card'
        ? 'demo_paid'
        : 'pending_cash';

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

    // Demo-only: no real payment gateway is contacted.
    // Link the payment to an existing doctor appointment.
    if (request.module == 'doctor') {
      final appointmentRef =
          _db.collection('appointments').doc(request.bookingId);

      final appointment = await appointmentRef.get();

      if (!appointment.exists) {
        throw Exception('Appointment not found.');
      }

      final data = appointment.data()!;

      if (data['userId'] != user.uid) {
        throw Exception('Unauthorized appointment.');
      }

      await appointmentRef.update({
        'paymentId': paymentRef.id,
        'paymentStatus': status,
        'paymentMethod': method,
        'status': method == 'card'
            ? 'confirmed'
            : 'pending_cash',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return paymentRef.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      userPaymentHistory() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    return _db
        .collection('payments')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }
}
