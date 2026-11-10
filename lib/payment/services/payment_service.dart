import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<void> processPaymentAndBooking(PaymentModel paymentData) async {
    try {
      // 1. Save Payment Record to 'payments' collection
      await _firestore.collection('payments').add(paymentData.toMap());

      // 2. Update the respective Service Status based on Service Type
      if (paymentData.serviceType == 'Doctor') {
        await _firestore
            .collection('appointments')
            .doc(paymentData.serviceId)
            .update({'paymentStatus': 'Paid', 'status': 'Approved'});
      } else if (paymentData.serviceType == 'Driver') {
        await _firestore
            .collection('rides')
            .doc(paymentData.serviceId)
            .update({'paymentStatus': 'Paid', 'status': 'Confirmed'});
      }
      
      
    } catch (e) {
      throw Exception('Payment processing failed: $e');
    }
  }
}