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
  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);

  DeliveryMethod _deliveryMethod = DeliveryMethod.delivery;
  String _paymentMethod = 'Cash on Delivery';
    bool _isPlacing = false;

  final TextEditingController _addressController =
      TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_isPlacing) return;
    setState(() => _isPlacing = true);
    final success = await widget.controller.placeOrder(
      deliveryMethod: _deliveryMethod,
      paymentMethod: _paymentMethod,
      deliveryAddress: _deliveryMethod == DeliveryMethod.delivery
          ? _addressController.text.trim()
          : null,
    );

    if (!mounted) return;
     setState(() => _isPlacing = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
                        'Could not place the order. Please check your delivery '
            'address, and make sure the items are still in stock.',
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: _green,
            size: 54,
          ),
          title: const Text(
            'Order Placed',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Your grocery order has been placed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: _green,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();

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

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: _green,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _textColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard(Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE3EADF),
        ),
      ),
      child: Material(
  color: Colors.transparent,
  borderRadius: BorderRadius.circular(20),
  clipBehavior: Clip.antiAlias,
  child: child,
),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: _green,
                        size: 26,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'One step closer!',
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Review your basket and choose your options.',
                            style: TextStyle(
                              color: Color(0xFF607565),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Order summary
              _sectionTitle(
                'Order Summary',
                Icons.receipt_long_outlined,
              ),
              _whiteCard(
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...widget.controller.cartItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 9,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        color: _textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Quantity: ${item.quantity}',
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  'Rs. ${item.totalPrice.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: _textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 30,
                        color: Color(0xFFE3EADF),
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment:
                            WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. ${widget.controller.cartTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: _green,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Delivery
              _sectionTitle(
                'Delivery Method',
                Icons.local_shipping_outlined,
              ),
              _whiteCard(
                RadioGroup<DeliveryMethod>(
                  groupValue: _deliveryMethod,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _deliveryMethod = value;
                      });
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<DeliveryMethod>(
                        activeColor: _green,
                        title: Text(
                          'Home Delivery',
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Receive your groceries at your address',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
                        ),
                        value: DeliveryMethod.delivery,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          color: Color(0xFFEDF1EA),
                        ),
                      ),
                      RadioListTile<DeliveryMethod>(
                        activeColor: _green,
                        title: Text(
                          'Store Pickup',
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Collect your order from the store',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                          ),
                        ),
                        value: DeliveryMethod.pickup,
                      ),
                    ],
                  ),
                ),
              ),
              if (_deliveryMethod == DeliveryMethod.delivery) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: _textColor,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Delivery Address',
                    hintText: 'Enter your delivery address',
                    labelStyle: const TextStyle(color: _muted),
                    hintStyle: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: _green,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFE3EADF),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: _green,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 26),

              // Payment
              _sectionTitle(
                'Payment Method',
                Icons.payments_outlined,
              ),
              _whiteCard(
                RadioGroup<String>(
                  groupValue: _paymentMethod,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _paymentMethod = value;
                      });
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        activeColor: _green,
                        title: Text(
                          'Cash on Delivery',
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: 'Cash on Delivery',
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          color: Color(0xFFEDF1EA),
                        ),
                      ),
                      RadioListTile<String>(
                        activeColor: _green,
                        title: Text(
                          'Card Payment',
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: 'Card Payment',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Place order
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                                onPressed: _isPlacing ? null : _placeOrder,
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                ),
                label: Text(
                  'Place Order - Rs. '
                  '${widget.controller.cartTotal.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}