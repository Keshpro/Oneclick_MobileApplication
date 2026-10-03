import 'package:flutter/material.dart';

class CartItemCard extends StatelessWidget {
  final String name;
  final String price;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_basket_outlined,
              size: 40,
              color: Colors.green,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(price),
                ],
              ),
            ),

            IconButton(
              onPressed: onDecrease,
              icon: const Icon(Icons.remove_circle_outline),
            ),

            Text(
              quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            IconButton(
              onPressed: onIncrease,
              icon: const Icon(Icons.add_circle_outline),
            ),

            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
