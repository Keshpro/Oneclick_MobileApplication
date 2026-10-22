import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/food_offer_model.dart';

class FoodSellerDataService {
  FoodSellerDataService._();

  static final FoodSellerDataService instance = FoodSellerDataService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // CURRENT SELLER'S OFFERS
  // ------------------------------------------------------------

  String get _sellerUid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Please sign in before managing food offers.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _offersCollection => _firestore
      .collection('food_sellers')
      .doc(_sellerUid)
      .collection('offers');

  // Local cache used by the existing seller screens.
  final List<FoodOfferModel> offers = [];

  // Listen to Firestore for this seller's offers.
  Stream<List<FoodOfferModel>> watchOffers() {
    return _offersCollection.snapshots().map((snapshot) {
      final loadedOffers = snapshot.docs
          .map((doc) => FoodOfferModel.fromFirestore(doc))
          .toList();

      offers
        ..clear()
        ..addAll(loadedOffers);

      return loadedOffers;
    });
  }

  // Load the current seller's offers once.
  Future<void> loadOffers() async {
    final snapshot = await _offersCollection.get();

    offers
      ..clear()
      ..addAll(snapshot.docs.map((doc) => FoodOfferModel.fromFirestore(doc)));
  }

  // Create a new offer in Firestore.
  Future<void> addOffer(FoodOfferModel offer) async {
    final docRef = await _offersCollection.add({
      ...offer.toFirestore(),
      'sellerUid': _sellerUid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final savedOffer = FoodOfferModel(
      id: docRef.id,
      foodName: offer.foodName,
      category: offer.category,
      originalPrice: offer.originalPrice,
      saverPrice: offer.saverPrice,
      quantity: offer.quantity,
      availableFrom: offer.availableFrom,
      availableUntil: offer.availableUntil,
      description: offer.description,
      allergens: offer.allergens,
      status: offer.status,
    );

    final index = offers.indexWhere((item) => item.id == savedOffer.id);

    if (index == -1) {
      offers.add(savedOffer);
    } else {
      offers[index] = savedOffer;
    }
  }

  // Update an existing offer.
  Future<void> updateOffer(FoodOfferModel offer) async {
    final id = offer.id;

    if (id == null || id.isEmpty) {
      throw StateError('Cannot update an offer without a document ID.');
    }

    await _offersCollection.doc(id).update({
      ...offer.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final index = offers.indexWhere((item) => item.id == id);

    if (index != -1) {
      offers[index] = offer;
    }
  }

  // Pause or resume an offer.
  Future<void> setOfferStatus(FoodOfferModel offer, String status) async {
    final id = offer.id;

    if (id == null || id.isEmpty) {
      throw StateError('Cannot change an offer without a document ID.');
    }

    if (status != 'ACTIVE' && status != 'PAUSED') {
      throw ArgumentError('Offer status must be ACTIVE or PAUSED.');
    }

    await _offersCollection.doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    offer.status = status;

    final index = offers.indexWhere((item) => item.id == id);

    if (index != -1) {
      offers[index].status = status;
    }
  }

  // Delete an offer.
  Future<void> deleteOffer(FoodOfferModel offer) async {
    final id = offer.id;

    if (id == null || id.isEmpty) {
      throw StateError('Cannot delete an offer without a document ID.');
    }

    await _offersCollection.doc(id).delete();

    offers.removeWhere((item) => item.id == id);
  }

  // ------------------------------------------------------------
  // STORE PROFILE (existing local values retained for now)
  // ------------------------------------------------------------

  String storeName = '';
  String ownerName = '';
  String phone = '';
  String email = '';
  String address = '';
  String description = '';

  Future<void> loadStoreProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in first.');
    }

    final doc = await _firestore.collection('food_sellers').doc(user.uid).get();

    final data = doc.data() ?? <String, dynamic>{};
    final providerDetails =
        data['providerDetails'] as Map<String, dynamic>? ?? {};

    storeName =
        (providerDetails['restaurantName'] ??
                data['storeName'] ??
                data['businessName'] ??
                '')
            .toString();

    ownerName = (data['name'] ?? user.displayName ?? '').toString();
    phone = (data['phone'] ?? '').toString();
    email = (data['email'] ?? user.email ?? '').toString();
    address = (data['address'] ?? data['businessAddress'] ?? '').toString();
    description = (data['description'] ?? '').toString();
  }

  Future<void> saveStoreProfile({
    required String newStoreName,
    required String newOwnerName,
    required String newPhone,
    required String newEmail,
    required String newAddress,
    required String newDescription,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Please sign in first.');
    }

    final cleanStoreName = newStoreName.trim();
    if (cleanStoreName.isEmpty) {
      throw ArgumentError('Store name cannot be empty.');
    }

    await _firestore.collection('food_sellers').doc(user.uid).set({
      'uid': user.uid,
      'name': newOwnerName.trim(),
      'phone': newPhone.trim(),
      'email': newEmail.trim(),
      'address': newAddress.trim(),
      'description': newDescription.trim(),
      'providerDetails.restaurantName': cleanStoreName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    storeName = cleanStoreName;
    ownerName = newOwnerName.trim();
    phone = newPhone.trim();
    email = newEmail.trim();
    address = newAddress.trim();
    description = newDescription.trim();
  }
  // ------------------------------------------------------------
  // ORDERS (existing sample data retained for now)
  // ------------------------------------------------------------

  final List<FoodSellerOrder> orders = [
    FoodSellerOrder(
      orderId: 'FC1024',
      foodName: 'Chocolate Cake',
      customerName: 'Dilni',
      quantity: 2,
      total: 1400,
      collectionTime: '6:00 PM',
      status: 'NEW',
    ),
    FoodSellerOrder(
      orderId: 'FC1023',
      foodName: 'Bakery Surprise Box',
      customerName: 'Kamal',
      quantity: 1,
      total: 450,
      collectionTime: '5:30 PM',
      status: 'PREPARING',
    ),
    FoodSellerOrder(
      orderId: 'FC1022',
      foodName: 'Chicken Rice & Curry',
      customerName: 'Nimal',
      quantity: 2,
      total: 780,
      collectionTime: '7:00 PM',
      status: 'READY',
    ),
    FoodSellerOrder(
      orderId: 'FC1021',
      foodName: 'Chocolate Brownies',
      customerName: 'Sarah',
      quantity: 3,
      total: 900,
      collectionTime: '6:30 PM',
      status: 'COMPLETED',
    ),
  ];

  void updateOrderStatus(String orderId, String newStatus) {
    final index = orders.indexWhere((order) => order.orderId == orderId);

    if (index != -1) {
      orders[index].status = newStatus;
    }
  }

  double get totalEarnings {
    return orders
        .where((order) => order.status == 'COMPLETED')
        .fold(0, (sum, order) => sum + order.total);
  }

  int get completedOrders {
    return orders.where((order) => order.status == 'COMPLETED').length;
  }

  int get foodSold {
    return orders
        .where((order) => order.status == 'COMPLETED')
        .fold(0, (sum, order) => sum + order.quantity);
  }
}

// ------------------------------------------------------------
// ORDER MODEL
// ------------------------------------------------------------

class FoodSellerOrder {
  final String orderId;
  final String foodName;
  final String customerName;
  final int quantity;
  final double total;
  final String collectionTime;

  String status;

  FoodSellerOrder({
    required this.orderId,
    required this.foodName,
    required this.customerName,
    required this.quantity,
    required this.total,
    required this.collectionTime,
    required this.status,
  });
}
