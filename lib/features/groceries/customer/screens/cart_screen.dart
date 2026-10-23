import 'package:flutter/material.dart';

import '../../controllers/grocery_controller.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final GroceryController controller;

  const CartScreen({
    super.key,
    required this.controller,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _productImage(String path) {
    const placeholder = Center(
      child: Icon(
        Icons.shopping_basket_outlined,
        color: _green,
        size: 34,
      ),
    );

    return Container(
      width: 76,
      height: 84,
      padding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: path.isEmpty
          ? placeholder
          : Image.asset(
              path,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = widget.controller.cartItems;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _background,
        foregroundColor: _textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? _buildEmptyCart()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: cartItems.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeading();
                  }

                  final item = cartItems[index - 1];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE3EADF),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _productImage(item.product.imageUrl),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item.product.category,
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rs. ${item.product.finalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: _green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove item',
                              onPressed: () {
                                widget.controller.removeFromCart(
                                  item.product,
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: _muted,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          height: 1,
                          color: Color(0xFFEDF1EA),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F6EF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Decrease quantity',
                                      onPressed: () {
                                        widget.controller.decreaseQuantity(
                                          item.product,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.remove_rounded,
                                        color: _green,
                                        size: 20,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          color: _textColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Increase quantity',
                                      onPressed: () {
                                        widget.controller.increaseQuantity(
                                          item.product,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        color: _green,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rs. ${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: _textColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildCheckout(),
    );
  }

  Widget _buildHeading() {
    final count = widget.controller.cartItemCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.shopping_bag_outlined,
              color: _green,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your basket of goodness',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$count ${count == 1 ? 'item' : 'items'} in your cart',
                  style: const TextStyle(
                    color: Color(0xFF607565),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: Color(0xFFE7F2E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                color: _green,
                size: 58,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find your favourites and add them to your basket.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Browse groceries'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckout() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D203B2B),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rs. ${widget.controller.cartTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(
                      controller: widget.controller,
                    ),
                  ),
                );
              },
              child: const Text(
                'Proceed to Checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}