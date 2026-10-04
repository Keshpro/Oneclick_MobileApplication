import 'package:flutter/material.dart';

import '../services/food_order_service.dart';
import 'food_review_screen.dart';

class FoodOrderTrackingScreen extends StatefulWidget {
  final FoodOrder order;

  const FoodOrderTrackingScreen({super.key, required this.order});

  @override
  State<FoodOrderTrackingScreen> createState() =>
      _FoodOrderTrackingScreenState();
}

class _FoodOrderTrackingScreenState extends State<FoodOrderTrackingScreen> {
  late FoodOrder order;

  @override
  void initState() {
    super.initState();

    order = widget.order;
  }

  List<FoodOrderStatus> get statuses {
    if (order.isDelivery) {
      return [
        FoodOrderStatus.orderPlaced,
        FoodOrderStatus.sellerConfirmed,
        FoodOrderStatus.preparing,
        FoodOrderStatus.ready,
        FoodOrderStatus.driverAssigned,
        FoodOrderStatus.pickedUp,
        FoodOrderStatus.onTheWay,
        FoodOrderStatus.delivered,
      ];
    }

    return [
      FoodOrderStatus.orderPlaced,
      FoodOrderStatus.sellerConfirmed,
      FoodOrderStatus.preparing,
      FoodOrderStatus.readyForPickup,
      FoodOrderStatus.pickedUp,
      FoodOrderStatus.completed,
    ];
  }

  int get currentIndex {
    return statuses.indexOf(order.status);
  }

  String statusTitle(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.orderPlaced:
        return 'Order Placed';

      case FoodOrderStatus.sellerConfirmed:
        return 'Seller Confirmed';

      case FoodOrderStatus.preparing:
        return 'Preparing Your Food';

      case FoodOrderStatus.ready:
        return 'Ready for Pickup';

      case FoodOrderStatus.driverAssigned:
        return 'Driver Assigned';

      case FoodOrderStatus.pickedUp:
        return order.isDelivery ? 'Picked Up by Driver' : 'Order Picked Up';

      case FoodOrderStatus.onTheWay:
        return 'On the Way';

      case FoodOrderStatus.delivered:
        return 'Delivered';

      case FoodOrderStatus.readyForPickup:
        return 'Ready for Pickup';

      case FoodOrderStatus.completed:
        return 'Completed';
    }
  }

  IconData statusIcon(FoodOrderStatus status) {
    switch (status) {
      case FoodOrderStatus.orderPlaced:
        return Icons.receipt_long;

      case FoodOrderStatus.sellerConfirmed:
        return Icons.storefront;

      case FoodOrderStatus.preparing:
        return Icons.restaurant;

      case FoodOrderStatus.ready:
      case FoodOrderStatus.readyForPickup:
        return Icons.inventory_2;

      case FoodOrderStatus.driverAssigned:
        return Icons.person_pin_circle;

      case FoodOrderStatus.pickedUp:
        return Icons.local_shipping;

      case FoodOrderStatus.onTheWay:
        return Icons.delivery_dining;

      case FoodOrderStatus.delivered:
      case FoodOrderStatus.completed:
        return Icons.check_circle;
    }
  }

  void moveToNextStatus() {
    final index = currentIndex;

    if (index == -1 || index >= statuses.length - 1) {
      return;
    }

    final nextStatus = statuses[index + 1];

    setState(() {
      order.status = nextStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed =
        order.status == FoodOrderStatus.delivered ||
        order.status == FoodOrderStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Track Order',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORDER NUMBER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  order.orderId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Icon(
                      order.isDelivery
                          ? Icons.delivery_dining
                          : Icons.storefront,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      order.isDelivery ? 'Delivery' : 'Pickup',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Order Status',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: List.generate(statuses.length, (index) {
                final status = statuses[index];

                final isCompleted = index <= currentIndex;

                final isCurrent = index == currentIndex;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.black
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            statusIcon(status),
                            color: isCompleted ? Colors.white : Colors.grey,
                            size: 20,
                          ),
                        ),

                        if (index < statuses.length - 1)
                          Container(
                            width: 2,
                            height: 45,
                            color: index < currentIndex
                                ? Colors.black
                                : Colors.grey.shade300,
                          ),
                      ],
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              statusTitle(status),
                              style: TextStyle(
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: isCurrent ? 16 : 14,
                              ),
                            ),

                            if (isCurrent)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Current status',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 35),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          if (!completed)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Demo mode: use the button below to simulate the next order update.',
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 15),

          if (!completed)
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: moveToNextStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Simulate Next Update',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          if (completed) ...[
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your order has been completed!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            if (!order.reviewSubmitted)
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodReviewScreen(order: order),
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
                    'Rate Your Experience',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
