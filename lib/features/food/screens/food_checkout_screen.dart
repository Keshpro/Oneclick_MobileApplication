import 'package:flutter/material.dart';

import '../services/food_cart_service.dart';
import '../services/food_order_service.dart';
import 'food_order_confirmation_screen.dart';
import '../services/save_bite_stock_service.dart';

class FoodCheckoutScreen extends StatefulWidget {
  const FoodCheckoutScreen({super.key});

  @override
  State<FoodCheckoutScreen> createState() => _FoodCheckoutScreenState();
}

class _FoodCheckoutScreenState extends State<FoodCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final noteController = TextEditingController();

  FoodFulfillmentType fulfillmentType = FoodFulfillmentType.delivery;

  String pickupTime = '6:00 PM';

  String paymentMethod = 'Cash on Delivery';

  final List<String> pickupTimes = [
    '5:30 PM',
    '6:00 PM',
    '6:30 PM',
    '7:00 PM',
    '7:30 PM',
  ];

  List<String> get paymentMethods {
    if (fulfillmentType == FoodFulfillmentType.pickup) {
      return ['Pay at Counter', 'Card / Online Payment'];
    }

    return ['Cash on Delivery', 'Card / Online Payment', 'Oneclick Wallet'];
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = FoodCartService.instance;

    final subtotal = cart.subtotal;

    final deliveryFee = fulfillmentType == FoodFulfillmentType.delivery
        ? 150.0
        : 0.0;

    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _sectionTitle('How do you want your food?'),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _fulfillmentCard(
                    icon: Icons.delivery_dining,
                    title: 'Delivery',
                    selected: fulfillmentType == FoodFulfillmentType.delivery,
                    onTap: () {
                      setState(() {
                        fulfillmentType = FoodFulfillmentType.delivery;

                        if (paymentMethod == 'Pay at Counter') {
                          paymentMethod = 'Cash on Delivery';
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _fulfillmentCard(
                    icon: Icons.storefront,
                    title: 'Pickup',
                    selected: fulfillmentType == FoodFulfillmentType.pickup,
                    onTap: () {
                      setState(() {
                        fulfillmentType = FoodFulfillmentType.pickup;

                        if (paymentMethod == 'Cash on Delivery' ||
                            paymentMethod == 'Oneclick Wallet') {
                          paymentMethod = 'Pay at Counter';
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            _sectionTitle('Customer Details'),

            const SizedBox(height: 12),

            _textField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            _textField(
              controller: phoneController,
              label: 'Phone Number',
              hint: '07XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }

                if (value.trim().length < 9) {
                  return 'Enter a valid phone number';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            if (fulfillmentType == FoodFulfillmentType.delivery) ...[
              _sectionTitle('Delivery Details'),

              const SizedBox(height: 12),

              _textField(
                controller: addressController,
                label: 'Delivery Address',
                hint: 'House number, street, city',
                icon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your delivery address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _textField(
                controller: noteController,
                label: 'Delivery Note',
                hint: 'Example: Please call when you arrive',
                icon: Icons.note_alt_outlined,
                maxLines: 2,
              ),
            ],

            if (fulfillmentType == FoodFulfillmentType.pickup) ...[
              _sectionTitle('Pickup Time'),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: pickupTime,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: pickupTimes
                        .map(
                          (time) =>
                              DropdownMenuItem(value: time, child: Text(time)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        pickupTime = value;
                      });
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 25),

            _sectionTitle('Payment Method'),

            const SizedBox(height: 12),

            ...paymentMethods.map((method) => _paymentCard(method)),

            const SizedBox(height: 25),

            _sectionTitle('Order Summary'),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name} × ${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            'Rs. ${item.total.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(),

                  _priceRow('Subtotal', subtotal),

                  _priceRow('Delivery Fee', deliveryFee),

                  const Divider(),

                  _priceRow('Total', total, bold: true),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _placeOrder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Place Order • Rs. ${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = FoodCartService.instance;

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    try {
      await SaveBiteStockService.instance.validateAndReserveStock(cart.items);

      if (!mounted) return;

      final order = FoodOrderService.instance.placeOrder(
        fulfillmentType: fulfillmentType,
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        deliveryNote: noteController.text.trim(),
        pickupTime: pickupTime,
        paymentMethod: paymentMethod,
      );

      cart.clearCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FoodOrderConfirmationScreen(order: order),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final errorText = error.toString();
      String title = 'Unable to place your order';
      String message;

      if (errorText.contains('Not enough portions')) {
        title = 'Not enough portions available';

        final match = RegExp(
          r'Available:\s*(\d+);\s*requested:\s*(\d+)',
          caseSensitive: false,
        ).firstMatch(errorText);

        if (match != null) {
          message =
              'Sorry, only ${match.group(1)} portions are available. '
              'You requested ${match.group(2)}. '
              'Please adjust the quantity in your cart to continue.';
        } else {
          message =
              'There are not enough portions available for your order. '
              'Please review your cart and try a smaller quantity.';
        }
      } else if (errorText.contains('no longer available')) {
        message =
            'Sorry, this food offer is no longer available. '
            'Please review your cart and choose another offer.';
      } else if (errorText.contains('unavailable') ||
          errorText.contains('Unable to resolve host') ||
          errorText.contains('SocketException') ||
          errorText.contains('network')) {
        message =
            'We couldn’t connect to place your order. '
            'Please check your internet connection and try again.';
      } else {
        message =
            'Something went wrong while placing your order. '
            'Please try again. If the problem continues, contact support.';
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.orange,
            size: 40,
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('No Thanks'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Review Cart'),
            ),
          ],
        ),
      );
    }
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
    );
  }

  Widget _fulfillmentCard({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: selected ? Colors.white : Colors.black),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _paymentCard(String method) {
    final selected = paymentMethod == method;

    IconData icon;

    if (method == 'Cash on Delivery') {
      icon = Icons.payments_outlined;
    } else if (method == 'Card / Online Payment') {
      icon = Icons.credit_card_outlined;
    } else {
      icon = Icons.account_balance_wallet_outlined;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          paymentMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.black : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 17 : 14,
              ),
            ),
          ),
          Text(
            'Rs. ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: bold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
