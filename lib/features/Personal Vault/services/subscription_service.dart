import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subscription_record.dart';

class SubscriptionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'No logged-in user found.',
      );
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>>
      get _subscriptionsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('subscriptions');
  }

  Future<void> addSubscription({
    required String name,
    required String subtitle,
    required String price,
    required String renewal,
    required String usage,
    required String category,
    String status = 'Active',
    bool priceHiked = false,

    // New structured fields.
    double? amount,
    String? currency,
    String? billingCycle,
    DateTime? renewalDate,
  }) async {
    final doc =
        _subscriptionsCollection.doc();

    final parsedAmount =
        amount ??
        double.tryParse(
          price.replaceAll(
            RegExp(r'[^0-9.]'),
            '',
          ),
        );

    final detectedCurrency =
        currency ??
        (
          price.trim().toUpperCase().startsWith(
                    'USD',
                  ) ||
                  price.trim().startsWith(r'$')
              ? 'USD'
              : 'LKR'
        );

    final detectedBillingCycle =
        billingCycle ??
        (
          subtitle.toLowerCase().contains(
                'annual',
              )
              ? 'Annual'
              : 'Monthly'
        );

    final subscription =
        SubscriptionRecord(
      id: doc.id,
      userId: _userId,
      name: name,
      subtitle: subtitle,
      price: price,
      renewal: renewal,
      usage: usage,
      category: category,
      status: status,
      priceHiked: priceHiked,
      createdAt: DateTime.now(),
      amount: parsedAmount,
      currency: detectedCurrency,
      billingCycle:
          detectedBillingCycle,
      renewalDate: renewalDate,
    );

    await doc.set(
      subscription.toMap(),
    );
  }

  Stream<List<SubscriptionRecord>>
      getSubscriptions() {
    return _subscriptionsCollection
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        SubscriptionRecord
                            .fromMap(
                      doc.id,
                      doc.data(),
                    ),
                  )
                  .toList(),
        );
  }

  Future<void> updateSubscription({
    required String subscriptionId,
    required String name,
    required String subtitle,
    required String price,
    required String renewal,
    required String usage,
    required String category,
    required String status,
    required bool priceHiked,

    // New optional structured fields.
    double? amount,
    String? currency,
    String? billingCycle,
    DateTime? renewalDate,
    DateTime? cancelledAt,
  }) async {
    final updateData =
        <String, dynamic>{
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'renewal': renewal,
      'usage': usage,
      'category': category,
      'status': status,
      'priceHiked': priceHiked,
    };

    if (amount != null) {
      updateData['amount'] = amount;
    }

    if (currency != null) {
      updateData['currency'] = currency;
    }

    if (billingCycle != null) {
      updateData['billingCycle'] =
          billingCycle;
    }

    if (renewalDate != null) {
      updateData['renewalDate'] =
          Timestamp.fromDate(
        renewalDate,
      );
    }

    if (cancelledAt != null) {
      updateData['cancelledAt'] =
          Timestamp.fromDate(
        cancelledAt,
      );
    }

    await _subscriptionsCollection
        .doc(subscriptionId)
        .update(updateData);
  }

  Future<void> cancelSubscription(
  String subscriptionId,
) async {
  await _subscriptionsCollection
      .doc(subscriptionId)
      .update({
    'status': 'Cancelled',
    'cancelledAt':
        Timestamp.fromDate(DateTime.now()),
  });
}

Future<void> keepSubscriptionRenewal({
  required String subscriptionId,
  required DateTime renewalDate,
}) async {
  await _subscriptionsCollection
      .doc(subscriptionId)
      .update({
    'renewalActionHandledFor':
        Timestamp.fromDate(renewalDate),
  });
}

  Future<void> deleteSubscription(
    String subscriptionId,
  ) async {
    await _subscriptionsCollection
        .doc(subscriptionId)
        .delete();
  }
}