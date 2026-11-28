import 'package:flutter/material.dart';

import '../services/food_order_service.dart';

class FoodSellerOrdersScreen extends StatefulWidget {
  const FoodSellerOrdersScreen({super.key});

  @override
  State<FoodSellerOrdersScreen> createState() => _FoodSellerOrdersScreenState();
}

class _FoodSellerOrdersScreenState extends State<FoodSellerOrdersScreen> {
  final orderService = FoodOrderService.instance;

  void updateStatus(FoodOrder order, FoodOrderStatus status) {
    setState(() {
      orderService.updateSpecificOrderStatus(order, status);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order ${order.orderId} updated.')));
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

  @override
  Widget build(BuildContext context) {
    final orders = orderService.orders.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text('No orders yet.', style: TextStyle(fontSize: 16)),
            )
          : ListView(
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
                ...orders.map(_orderCard),
              ],
            ),
    );
  }

  Widget _orderCard(FoodOrder order) {
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
                'Total',
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
                onPressed: () => updateStatus(order, next),
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
}
