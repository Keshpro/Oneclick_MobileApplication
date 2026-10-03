import 'package:flutter/material.dart';

import '../services/food_order_service.dart';
import 'food_order_tracking_screen.dart';

class FoodOrderConfirmationScreen extends StatelessWidget {
  final FoodOrder order;

  const FoodOrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),

              const SizedBox(height: 25),

              const Text(
                'Order Placed!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                'Your food order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Order Number',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      order.orderId,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Divider(),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined),
                        const SizedBox(width: 10),
                        Expanded(child: Text('${order.items.length} item(s)')),
                        Text(
                          'Rs. ${order.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Icon(
                          order.isDelivery
                              ? Icons.delivery_dining
                              : Icons.storefront,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(order.isDelivery ? 'Delivery' : 'Pickup'),
                        ),
                        Text(
                          order.isDelivery
                              ? 'Rs. ${order.deliveryFee.toStringAsFixed(0)}'
                              : 'Free',
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        const Icon(Icons.payments_outlined),
                        const SizedBox(width: 10),
                        Expanded(child: Text(order.paymentMethod)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodOrderTrackingScreen(order: order),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Track My Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
