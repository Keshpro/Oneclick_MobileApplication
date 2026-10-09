import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/subscription_record.dart';

class SubscriptionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged-in user found.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _subscriptionsCollection {
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
  }) async {
    final doc = _subscriptionsCollection.doc();

    final subscription = SubscriptionRecord(
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
    );

    await doc.set(subscription.toMap());
  }

  Stream<List<SubscriptionRecord>> getSubscriptions() {
    return _subscriptionsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SubscriptionRecord.fromMap(
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
  }) async {
    await _subscriptionsCollection.doc(subscriptionId).update({
      'name': name,
      'subtitle': subtitle,
      'price': price,
      'renewal': renewal,
      'usage': usage,
      'category': category,
      'status': status,
      'priceHiked': priceHiked,
    });
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    await _subscriptionsCollection.doc(subscriptionId).delete();
  }
}