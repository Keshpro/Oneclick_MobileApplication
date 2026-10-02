import 'package:flutter/material.dart';

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

  FoodOrderItem({
    required this.foodName,
    required this.restaurantName,
    required this.foodImage,
    required this.restaurantLogo,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;
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
}

class FoodOrderService {
  FoodOrderService._();

  static final FoodOrderService instance = FoodOrderService._();

  final List<FoodOrder> orders = [];

  FoodOrder? currentOrder;

  FoodOrder placeOrder({
    required FoodFulfillmentType fulfillmentType,
    required String customerName,
    required String phone,
    required String address,
    required String deliveryNote,
    required String pickupTime,
    required String paymentMethod,
  }) {
    final cart = FoodCartService.instance;

    final orderItems = cart.items.map((item) {
      return FoodOrderItem(
        foodName: item.offer.foodName,
        restaurantName: item.offer.restaurantName,
        foodImage: item.offer.foodImage,
        restaurantLogo: item.offer.restaurantLogo,
        price: item.offer.saverPrice,
        quantity: item.quantity,
      );
    }).toList();

    final subtotal = cart.subtotal;

    final deliveryFee = fulfillmentType == FoodFulfillmentType.delivery
        ? 150.0
        : 0.0;

    final total = subtotal + deliveryFee;

    final now = DateTime.now();

    final orderId =
        'OC-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${orders.length + 1}';

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

    orders.add(order);
    currentOrder = order;

    return order;
  }

  void updateStatus(FoodOrderStatus status) {
    if (currentOrder != null) {
      currentOrder!.status = status;
    }
  }

  void submitReview({required int rating, required String review}) {
    if (currentOrder == null) return;

    currentOrder!.reviewRating = rating;
    currentOrder!.reviewText = review;
    currentOrder!.reviewSubmitted = true;
  }

  void clearCurrentOrder() {
    currentOrder = null;
  }
}
