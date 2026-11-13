
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

import '../models/payment_request.dart';

class PaymentService {
  PaymentService._();

  static final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(
    region: 'asia-south1',
  );

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Start a PayHere Sandbox payment.
  ///
  /// Returns the internal Firestore payment ID
  /// after the PayHere SDK reports completion.
  ///
  /// IMPORTANT:
  /// This does NOT mean the payment is verified.
  /// The backend must confirm the payment status.
  static Future<String> startPayment(
    PaymentRequest request,
  ) async {
    if (request.module != 'doctor') {
      throw UnsupportedError(
        'Payment is not enabled for this module yet.',
      );
    }

    if (request.bookingId.trim().isEmpty) {
      throw ArgumentError(
        'Booking ID cannot be empty.',
      );
    }

    // Step 1: Create payment session using Firebase.
    final callable = _functions.httpsCallable(
      'createPayHerePayment',
    );

    final response = await callable.call(
      <String, dynamic>{
        'bookingId': request.bookingId,
        'customer': request.customer,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    final paymentId = data['paymentId']?.toString() ?? '';
    final merchantId = data['merchantId']?.toString() ?? '';
    final merchantSecret =
        data['merchantSecret']?.toString() ?? '';
    final orderId = data['orderId']?.toString() ?? '';
    final amount = data['amount']?.toString() ?? '';
    final currency = data['currency']?.toString() ?? 'LKR';
    final notifyUrl = data['notifyUrl']?.toString() ?? '';

    if (paymentId.isEmpty ||
        merchantId.isEmpty ||
        merchantSecret.isEmpty ||
        orderId.isEmpty ||
        amount.isEmpty ||
        notifyUrl.isEmpty) {
      throw StateError(
        'Incomplete PayHere payment configuration.',
      );
    }

    // Step 2: Prepare PayHere Sandbox payment.
    //
    // Sandbox only: The official SDK requires
    // merchant_secret in its payment object.
    // Never use a production secret this way.
    final paymentObject = <String, dynamic>{
      'sandbox': true,
      'merchant_id': merchantId,
      'merchant_secret': merchantSecret,
      'notify_url': notifyUrl,
      'order_id': orderId,
      'items': request.title,
      'amount': amount,
      'currency': currency,
      'first_name': request.firstName,
      'last_name': request.lastName,
      'email': request.email,
      'phone': request.phone,
      'address': request.address,
      'city': request.city,
      'country': 'Sri Lanka',
      'delivery_address': request.address,
      'delivery_city': request.city,
      'delivery_country': 'Sri Lanka',
      'custom_1': request.module,
      'custom_2': request.bookingId,
    };

    // Step 3: Launch PayHere payment gateway.
    final completer = Completer<void>();

    try {
      PayHere.startPayment(
        paymentObject,
        (gatewayPaymentId) {
          // SDK success does not mean that the
          // backend has verified the payment.
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        (error) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception('PayHere payment failed: $error'),
            );
          }
        },
        () {
          if (!completer.isCompleted) {
            completer.completeError(
              StateError('Payment was cancelled.'),
            );
          }
        },
      );
    } catch (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    await completer.future;

    // Return payment ID for server verification.
    return paymentId;
  }

  /// Listen to payment status changes in Firestore.
  static Stream<DocumentSnapshot<Map<String, dynamic>>>
      watchPayment(String paymentId) {
    if (paymentId.trim().isEmpty) {
      throw ArgumentError(
        'Payment ID cannot be empty.',
      );
    }

    return _firestore
        .collection('payments')
        .doc(paymentId)
        .snapshots();
  }

  /// Check whether a payment has been verified
  /// by the backend.
  static Future<bool> isPaymentVerified(
    String paymentId,
  ) async {
    if (paymentId.trim().isEmpty) {
      return false;
    }

    final payment = await _firestore
        .collection('payments')
        .doc(paymentId)
        .get();

    if (!payment.exists) {
      return false;
    }

    final data = payment.data();

    return data?['status'] == 'paid' &&
        data?['provider'] == 'payhere' &&
        data?['environment'] == 'sandbox';
  }
}
