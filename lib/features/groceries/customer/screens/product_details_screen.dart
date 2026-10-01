import 'package:flutter/material.dart';

import '../../controllers/grocery_controller.dart';
import '../../models/grocery_product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final GroceryProduct product;
  final GroceryController controller;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                size: 100,
              ),
            ),

            const SizedBox(height: 24),

            // Category
            Text(
              product.category,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 5),

            // Product name
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Price
            if (product.hasDiscount)
              Row(
                children: [
                  Text(
                    'Rs. ${product.finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Rs. ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Rs. ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              product.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              product.isAvailable
                  ? 'In Stock: ${product.stock}'
                  : 'Out of Stock',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: product.isAvailable
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(height: 30),

            // Add to cart button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: product.isAvailable
                    ? () {
                        controller.addToCart(product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} added to cart',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(
                  Icons.add_shopping_cart,
                ),
                label: Text(
                  product.isAvailable
                      ? 'Add to Cart'
                      : 'Out of Stock',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}