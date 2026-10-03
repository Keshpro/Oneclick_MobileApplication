import 'package:flutter/material.dart';

import '../services/food_seller_data_service.dart';

class FoodSellerOrdersScreen extends StatefulWidget {
  const FoodSellerOrdersScreen({super.key});

  @override
  State<FoodSellerOrdersScreen> createState() => _FoodSellerOrdersScreenState();
}

class _FoodSellerOrdersScreenState extends State<FoodSellerOrdersScreen> {
  final sellerData = FoodSellerDataService.instance;

  void updateStatus(String orderId, String status) {
    setState(() {
      sellerData.updateOrderStatus(orderId, status);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order #$orderId is now $status.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),

      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
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

          ...sellerData.orders.map((order) => _orderCard(order)),
        ],
      ),
    );
  }

  Widget _orderCard(FoodSellerOrder order) {
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  order.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            order.foodName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text('Customer: ${order.customerName}'),

          const SizedBox(height: 4),

          Text('Quantity: ${order.quantity}'),

          const SizedBox(height: 4),

          Text('Collection: ${order.collectionTime}'),

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

          // NEW → PREPARING
          if (order.status == 'NEW')
            _actionButton(
              label: 'Accept Order',
              color: const Color(0xFF2E7D32),
              onPressed: () {
                updateStatus(order.orderId, 'PREPARING');
              },
            ),

          // PREPARING → READY
          if (order.status == 'PREPARING')
            _actionButton(
              label: 'Mark as Ready',
              color: Colors.blue,
              onPressed: () {
                updateStatus(order.orderId, 'READY');
              },
            ),

          // READY → COMPLETED
          if (order.status == 'READY')
            _actionButton(
              label: 'Complete Order',
              color: Colors.green,
              onPressed: () {
                updateStatus(order.orderId, 'COMPLETED');
              },
            ),

          // COMPLETED
          if (order.status == 'COMPLETED')
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

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),

        child: Text(label),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'NEW':
        return Colors.orange;

      case 'PREPARING':
        return Colors.blue;

      case 'READY':
        return Colors.green;

      case 'COMPLETED':
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }
}
