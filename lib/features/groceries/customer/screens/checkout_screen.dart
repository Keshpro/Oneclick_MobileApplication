import 'package:flutter/material.dart';

import '../../controllers/grocery_controller.dart';
import '../../models/grocery_order_model.dart';

class CheckoutScreen extends StatefulWidget {
  final GroceryController controller;

  const CheckoutScreen({
    super.key,
    required this.controller,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  DeliveryMethod _deliveryMethod = DeliveryMethod.delivery;
  String _paymentMethod = 'Cash on Delivery';

  final TextEditingController _addressController =
      TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    final success = widget.controller.placeOrder(
      deliveryMethod: _deliveryMethod,
      paymentMethod: _paymentMethod,
      deliveryAddress: _deliveryMethod == DeliveryMethod.delivery
          ? _addressController.text.trim()
          : null,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please check your cart and delivery address.',
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Order Placed'),
          content: const Text(
            'Your grocery order has been placed successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                // Return to grocery home screen
                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...widget.controller.cartItems.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.product.name),
                subtitle: Text(
                  'Quantity: ${item.quantity}',
                ),
                trailing: Text(
                  'Rs. ${item.totalPrice.toStringAsFixed(2)}',
                ),
              ),
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rs. ${widget.controller.cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Delivery method
            const Text(
              'Delivery Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            RadioListTile<DeliveryMethod>(
              title: const Text('Home Delivery'),
              value: DeliveryMethod.delivery,
              groupValue: _deliveryMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _deliveryMethod = value;
                  });
                }
              },
            ),

            RadioListTile<DeliveryMethod>(
              title: const Text('Store Pickup'),
              value: DeliveryMethod.pickup,
              groupValue: _deliveryMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _deliveryMethod = value;
                  });
                }
              },
            ),

            if (_deliveryMethod == DeliveryMethod.delivery) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  hintText: 'Enter your delivery address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Payment method
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'Cash on Delivery',
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _paymentMethod = value;
                  });
                }
              },
            ),

            RadioListTile<String>(
              title: const Text('Card Payment'),
              value: 'Card Payment',
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _paymentMethod = value;
                  });
                }
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _placeOrder,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'Place Order - Rs. '
                  '${widget.controller.cartTotal.toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}