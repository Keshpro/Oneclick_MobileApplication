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

  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);

  Widget _productImage() {
    const placeholder = Center(
      child: Icon(
        Icons.shopping_basket_outlined,
        color: _green,
        size: 80,
      ),
    );

    return Container(
      height: 260,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE3EADF),
        ),
      ),
      child: product.imageUrl.isEmpty
          ? placeholder
          : Image.asset(
              product.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = product.isAvailable;
    final stockColor = available
        ? _green
        : const Color(0xFFB83D3D);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Product Details',
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
              _productImage(),
              const SizedBox(height: 22),

              // Category and availability
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F2E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        color: _green,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: available
                          ? const Color(0xFFE7F2E8)
                          : const Color(0xFFFBEDED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      available ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        color: stockColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product name
              Text(
                product.name,
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),

              // Price
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Rs. ${product.finalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: _green,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (product.hasDiscount)
                    Text(
                      'Rs. ${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),

              // Seller
              if (product.sellerName.isNotEmpty) ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE3EADF),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 23,
                        backgroundColor: Color(0xFFE7F2E8),
                        child: Icon(
                          Icons.storefront_outlined,
                          color: _green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sold by',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.sellerName,
                              style: const TextStyle(
                                color: _textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),

              // Description
              Container(
                padding: const EdgeInsets.all(20),
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
                    const Text(
                      'About this product',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description.trim().isEmpty
                          ? 'No description available.'
                          : product.description,
                      style: const TextStyle(
                        color: Color(0xFF607565),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const Divider(
                      height: 30,
                      color: Color(0xFFE3EADF),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: stockColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            available
                                ? '${product.stock} available in stock'
                                : 'Currently out of stock',
                            style: TextStyle(
                              color: stockColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Add to cart
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFEBEFE9),
              disabledForegroundColor: _muted,
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
            onPressed: available
                ? () {
                    controller.addToCart(product);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _green,
                        content: Text(
                          '${product.name} added to cart',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: Text(
              available ? 'Add to Cart' : 'Out of Stock',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}