import 'package:flutter/material.dart';

import '../services/food_cart_service.dart';
import '../services/food_order_service.dart';
import 'food_checkout_screen.dart';

class FoodCartScreen extends StatefulWidget {
  const FoodCartScreen({super.key});

  @override
  State<FoodCartScreen> createState() => _FoodCartScreenState();
}

class _FoodCartScreenState extends State<FoodCartScreen> {
  final cart = FoodCartService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: cart.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _CartItemCard(
                        item: cart.items[index],
                        onIncrease: () {
                          setState(() {
                            cart.increaseQuantity(index);
                          });
                        },
                        onDecrease: () {
                          setState(() {
                            cart.decreaseQuantity(index);
                          });
                        },
                        onRemove: () {
                          setState(() {
                            cart.removeFromCart(index);
                          });
                        },
                      );
                    },
                  ),
                ),

                _buildBottomSummary(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 90,
              width: 90,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(30),
              ),

              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 45,
                color: Color(0xFF2E7D32),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Add some delicious SaveBites to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              child: const Text(
                'Explore SaveBites',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),

      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                Text(
                  '${cart.totalItems}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                Text(
                  'Rs. ${cart.subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 54,

              child: ElevatedButton(
                onPressed: () {
                  if (FoodCartService.instance.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Your cart is empty.')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FoodCheckoutScreen(),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                child: Text(
                  'Continue to Checkout • Rs. ${cart.subtotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final FoodCartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final offer = item.offer;

    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),

            child: Image.asset(
              offer.foodImage,
              height: 90,
              width: 90,
              fit: BoxFit.cover,

              errorBuilder: (_, __, ___) {
                return Container(
                  height: 90,
                  width: 90,

                  color: const Color(0xFFE8F5E9),

                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Color(0xFF66BB6A),
                    size: 35,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        offer.foodName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),

                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  offer.restaurantName,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Rs. ${offer.saverPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        _QuantityButton(icon: Icons.remove, onTap: onDecrease),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),

                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),

                        _QuantityButton(icon: Icons.add, onTap: onIncrease),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(9),

      child: Container(
        height: 30,
        width: 30,

        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(9),
        ),

        child: Icon(icon, size: 17, color: const Color(0xFF2E7D32)),
      ),
    );
  }
}
