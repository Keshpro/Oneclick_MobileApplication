import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String serviceId;       // Appointment ID හෝ Ride ID
  final String serviceType;     // 'Doctor', 'Driver', 'Lab Test' etc.
  final String title;           // e.g. "Dr. Perera Consultation" or "City Taxi Ride"
  final String subtitle;        // e.g. "General Hospital • 10:30 AM"
  final double amount;          // LKR 2500.0
  final String userId;          // Customer UID
  final String providerId;      // Doctor UID හෝ Driver UID

  PaymentModel({
    required this.serviceId,
    required this.serviceType,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.userId,
    required this.providerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceType': serviceType,
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'userId': userId,
      'providerId': providerId,
      'status': 'Success',
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}