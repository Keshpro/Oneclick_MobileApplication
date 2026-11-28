import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/food_order_service.dart';

class FoodSellerOrdersScreen extends StatefulWidget {
  const FoodSellerOrdersScreen({super.key});

  @override
  State<FoodSellerOrdersScreen> createState() => _FoodSellerOrdersScreenState();
}

class _FoodSellerOrdersScreenState extends State<FoodSellerOrdersScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? get sellerUid => FirebaseAuth.instance.currentUser?.uid;

  FoodOrderStatus parseStatus(String? value) {
    return FoodOrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => FoodOrderStatus.orderPlaced,
    );
  }

  FoodOrder? convertOrder(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String uid,
  ) {
    final data = document.data();

    final rawItems = data['items'] as List<dynamic>? ?? [];

    // Only show the items belonging to this seller.
    final sellerItems = rawItems
        .where((rawItem) {
          final item = Map<String, dynamic>.from(rawItem as Map);
          return item['sellerUid'] == uid;
        })
        .map((rawItem) {
          final item = Map<String, dynamic>.from(rawItem as Map);

          return FoodOrderItem(
            foodName: item['foodName']?.toString() ?? '',
            restaurantName: item['restaurantName']?.toString() ?? '',
            foodImage: item['foodImage']?.toString() ?? '',
            restaurantLogo: item['restaurantLogo']?.toString() ?? '',
            price: (item['price'] as num?)?.toDouble() ?? 0,
            quantity: (item['quantity'] as num?)?.toInt() ?? 0,
            sellerUid: item['sellerUid']?.toString(),
            firestoreOfferPath: item['firestoreOfferPath']?.toString(),
          );
        })
        .toList();

    if (sellerItems.isEmpty) return null;

    final sellerSubtotal = sellerItems.fold<double>(
      0,
      (sum, item) => sum + item.total,
    );

    final sellerStatuses = Map<String, dynamic>.from(
      data['sellerStatuses'] ?? {},
    );

    final sellerStatus = sellerStatuses[uid]?.toString();

    final overallStatus = data['status']?.toString();

    final rawFulfillment = data['fulfillmentType']?.toString();

    final fulfillmentType = rawFulfillment == FoodFulfillmentType.pickup.name
        ? FoodFulfillmentType.pickup
        : FoodFulfillmentType.delivery;

    DateTime placedAt = DateTime.now();

    if (data['placedAt'] is Timestamp) {
      placedAt = (data['placedAt'] as Timestamp).toDate();
    }

    return FoodOrder(
      orderId: data['orderId']?.toString() ?? document.id,
      items: sellerItems,
      subtotal: sellerSubtotal,
      deliveryFee: 0,
      total: sellerSubtotal,
      fulfillmentType: fulfillmentType,
      customerName: data['customerName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      deliveryNote: data['deliveryNote']?.toString() ?? '',
      pickupTime: data['pickupTime']?.toString() ?? '',
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      placedAt: placedAt,
      status: parseStatus(sellerStatus ?? overallStatus),
    );
  }

  Future<void> updateStatus(
    String documentId,
    FoodOrder order,
    FoodOrderStatus status,
  ) async {
    final uid = sellerUid;

    if (uid == null) return;

    try {
      await firestore.collection('food_orders').doc(documentId).update({
        'sellerStatuses.$uid': status.name,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ${order.orderId} updated.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update order: $e')));
    }
  }

  FoodOrderStatus? nextStatus(FoodOrder order) {
    if (order.isDelivery) {
      switch (order.status) {
        case FoodOrderStatus.orderPlaced:
          return FoodOrderStatus.sellerConfirmed;
        case FoodOrderStatus.sellerConfirmed:
          return FoodOrderStatus.preparing;
        case FoodOrderStatus.preparing:
          return FoodOrderStatus.ready;
        case FoodOrderStatus.ready:
          return FoodOrderStatus.driverAssigned;
        case FoodOrderStatus.driverAssigned:
          return FoodOrderStatus.pickedUp;
        case FoodOrderStatus.pickedUp:
          return FoodOrderStatus.onTheWay;
        case FoodOrderStatus.onTheWay:
          return FoodOrderStatus.delivered;
        default:
          return null;
      }
    } else {
      switch (order.status) {
        case FoodOrderStatus.orderPlaced:
          return FoodOrderStatus.sellerConfirmed;
        case FoodOrderStatus.sellerConfirmed:
          return FoodOrderStatus.preparing;
        case FoodOrderStatus.preparing:
          return FoodOrderStatus.readyForPickup;
        case FoodOrderStatus.readyForPickup:
          return FoodOrderStatus.pickedUp;
        case FoodOrderStatus.pickedUp:
          return FoodOrderStatus.completed;
        default:
          return null;
      }
    }
  }

  String statusLabel(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.orderPlaced:
        return 'NEW';
      case FoodOrderStatus.sellerConfirmed:
        return 'ACCEPTED';
      case FoodOrderStatus.preparing:
        return 'PREPARING';
      case FoodOrderStatus.ready:
      case FoodOrderStatus.readyForPickup:
        return 'READY';
      case FoodOrderStatus.driverAssigned:
        return 'DRIVER ASSIGNED';
      case FoodOrderStatus.pickedUp:
        return 'PICKED UP';
      case FoodOrderStatus.onTheWay:
        return 'ON THE WAY';
      case FoodOrderStatus.delivered:
        return 'DELIVERED';
      case FoodOrderStatus.completed:
        return 'COMPLETED';
    }
  }

  Color statusColor(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.orderPlaced:
        return Colors.orange;
      case FoodOrderStatus.sellerConfirmed:
        return Colors.blue;
      case FoodOrderStatus.preparing:
        return Colors.deepOrange;
      case FoodOrderStatus.ready:
      case FoodOrderStatus.readyForPickup:
        return Colors.green;
      case FoodOrderStatus.driverAssigned:
        return Colors.indigo;
      case FoodOrderStatus.pickedUp:
        return Colors.teal;
      case FoodOrderStatus.onTheWay:
        return Colors.blue;
      case FoodOrderStatus.delivered:
      case FoodOrderStatus.completed:
        return Colors.grey;
    }
  }

  String orderItemsText(FoodOrder order) {
    return order.items
        .map((item) => '${item.foodName} x${item.quantity}')
        .join('\n');
  }

  String _nextActionLabel(FoodOrder order) {
    switch (order.status) {
      case FoodOrderStatus.orderPlaced:
        return 'Accept Order';
      case FoodOrderStatus.sellerConfirmed:
        return 'Start Preparing';
      case FoodOrderStatus.preparing:
        return 'Mark as Ready';
      case FoodOrderStatus.ready:
        return 'Assign Driver';
      case FoodOrderStatus.readyForPickup:
        return 'Confirm Pickup';
      case FoodOrderStatus.driverAssigned:
        return 'Confirm Driver Pickup';
      case FoodOrderStatus.pickedUp:
        return order.isDelivery ? 'Mark On the Way' : 'Complete Order';
      case FoodOrderStatus.onTheWay:
        return 'Mark as Delivered';
      default:
        return 'Update Order';
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = sellerUid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in again.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('food_orders')
            .where('sellerUids', arrayContains: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading orders: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data?.docs ?? [];

          final orders = documents
              .map((doc) => convertOrder(doc, uid))
              .whereType<FoodOrder>()
              .toList();

          orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders yet.', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Customer Orders',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage orders received from your customers.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ...documents.map((doc) {
                final order = convertOrder(doc, uid);

                if (order == null) return const SizedBox.shrink();

                return _orderCard(doc.id, order);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _orderCard(String documentId, FoodOrder order) {
    final next = nextStatus(order);
    final color = statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF2E7D32),
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ORDER #${order.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel(order.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            orderItemsText(order),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Customer: ${order.customerName}'),
          const SizedBox(height: 4),
          Text('Phone: ${order.phone}'),
          if (order.isDelivery) ...[
            const SizedBox(height: 4),
            Text('Address: ${order.address}'),
            if (order.deliveryNote.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Note: ${order.deliveryNote}'),
            ],
          ] else ...[
            const SizedBox(height: 4),
            Text('Pickup time: ${order.pickupTime}'),
          ],
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Seller Subtotal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'Rs. ${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (next != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => updateStatus(documentId, order, next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: Text(_nextActionLabel(order)),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Order Completed',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
