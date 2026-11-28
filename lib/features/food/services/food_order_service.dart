import 'package:cloud_firestore/cloud_firestore.dart';

import 'food_cart_service.dart';

enum FoodFulfillmentType { delivery, pickup }

enum FoodOrderStatus {
  orderPlaced,
  sellerConfirmed,
  preparing,
  ready,
  driverAssigned,
  pickedUp,
  onTheWay,
  delivered,
  readyForPickup,
  completed,
}

class FoodOrderItem {
  final String foodName;
  final String restaurantName;
  final String foodImage;
  final String restaurantLogo;
  final double price;
  final int quantity;
  final String? sellerUid;
  final String? firestoreOfferPath;

  FoodOrderItem({
    required this.foodName,
    required this.restaurantName,
    required this.foodImage,
    required this.restaurantLogo,
    required this.price,
    required this.quantity,
    this.sellerUid,
    this.firestoreOfferPath,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'restaurantName': restaurantName,
      'foodImage': foodImage,
      'restaurantLogo': restaurantLogo,
      'price': price,
      'quantity': quantity,
      'sellerUid': sellerUid,
      'firestoreOfferPath': firestoreOfferPath,
    };
  }
}

class FoodOrder {
  final String orderId;
  final List<FoodOrderItem> items;

  final double subtotal;
  final double deliveryFee;
  final double total;

  final FoodFulfillmentType fulfillmentType;

  final String customerName;
  final String phone;
  final String address;
  final String deliveryNote;
  final String pickupTime;
  final String paymentMethod;

  final DateTime placedAt;

  FoodOrderStatus status;

  int? reviewRating;
  String reviewText = '';
  bool reviewSubmitted = false;

  FoodOrder({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.fulfillmentType,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.deliveryNote,
    required this.pickupTime,
    required this.paymentMethod,
    required this.placedAt,
    this.status = FoodOrderStatus.orderPlaced,
  });

  bool get isDelivery => fulfillmentType == FoodFulfillmentType.delivery;

  bool get isPickup => fulfillmentType == FoodFulfillmentType.pickup;

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'sellerUids': items
          .map((item) => item.sellerUid)
          .where((uid) => uid != null)
          .toSet()
          .toList(),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'fulfillmentType': fulfillmentType.name,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'deliveryNote': deliveryNote,
      'pickupTime': pickupTime,
      'paymentMethod': paymentMethod,
      'placedAt': Timestamp.fromDate(placedAt),
      'status': status.name,
      'reviewRating': reviewRating,
      'reviewText': reviewText,
      'reviewSubmitted': reviewSubmitted,
    };
  }
}

class FoodOrderService {
  FoodOrderService._();

  static final FoodOrderService instance = FoodOrderService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<FoodOrder> orders = [];

  FoodOrder? currentOrder;

  // Extract the seller UID from a Firestore offer path.
  // Example: food_sellers/SELLER_UID/offers/OFFER_ID
  String? _extractSellerUid(String? path) {
    if (path == null || path.trim().isEmpty) return null;

    final segments = path.split('/');

    if (segments.length >= 2 && segments[0] == 'food_sellers') {
      return segments[1];
    }

    return null;
  }

  Future<FoodOrder> placeOrder({
    required FoodFulfillmentType fulfillmentType,
    required String customerName,
    required String phone,
    required String address,
    required String deliveryNote,
    required String pickupTime,
    required String paymentMethod,
    List<FoodCartItem>? checkoutItems,
  }) async {
    final cart = FoodCartService.instance;

    final selectedItems = checkoutItems ?? cart.items;

    if (selectedItems.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final orderItems = selectedItems.map((item) {
      final product = item.product;
      final offerPath = product.firestoreOfferPath;

      return FoodOrderItem(
        foodName: product.name,
        restaurantName: product.sellerName,
        foodImage: product.foodImage,
        restaurantLogo: product.sellerLogo,
        price: product.price,
        quantity: item.quantity,
        firestoreOfferPath: offerPath,
        sellerUid: _extractSellerUid(offerPath),
      );
    }).toList();

    final subtotal = selectedItems.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

    final deliveryFee = fulfillmentType == FoodFulfillmentType.delivery
        ? 150.0
        : 0.0;

    final total = subtotal + deliveryFee;

    final now = DateTime.now();

    // Generate a Firestore document reference first.
    final orderRef = _firestore.collection('food_orders').doc();

    final orderId =
        'OC-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${orderRef.id.substring(0, 6).toUpperCase()}';

    final order = FoodOrder(
      orderId: orderId,
      items: orderItems,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      fulfillmentType: fulfillmentType,
      customerName: customerName,
      phone: phone,
      address: address,
      deliveryNote: deliveryNote,
      pickupTime: pickupTime,
      paymentMethod: paymentMethod,
      placedAt: now,
    );

    // Save the order permanently to Firestore.
    await orderRef.set({...order.toMap(), 'documentId': orderRef.id});

    orders.add(order);
    currentOrder = order;

    return order;
  }

  Future<void> updateStatus(FoodOrderStatus status) async {
    if (currentOrder == null) return;

    currentOrder!.status = status;

    await _updateOrderInFirestore(currentOrder!);
  }

  Future<void> submitReview({
    required int rating,
    required String review,
  }) async {
    if (currentOrder == null) return;

    currentOrder!.reviewRating = rating;
    currentOrder!.reviewText = review;
    currentOrder!.reviewSubmitted = true;

    await _updateOrderInFirestore(currentOrder!);
  }

  void clearCurrentOrder() {
    currentOrder = null;
  }

  Future<void> updateSpecificOrderStatus(
    FoodOrder order,
    FoodOrderStatus status,
  ) async {
    order.status = status;

    await _updateOrderInFirestore(order);
  }

  Future<void> _updateOrderInFirestore(FoodOrder order) async {
    final query = await _firestore
        .collection('food_orders')
        .where('orderId', isEqualTo: order.orderId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Order not found in Firestore.');
    }

    await query.docs.first.reference.update(order.toMap());
  }
}
