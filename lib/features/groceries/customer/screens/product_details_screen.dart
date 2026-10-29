import 'package:flutter/material.dart';

import '../../controllers/grocery_controller.dart';
import '../../models/grocery_product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final GroceryProduct product;
  final GroceryController controller;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  GroceryProduct get product => widget.product;
  GroceryController get controller => widget.controller;

  int get _alreadyInCart {
    for (final item in controller.cartItems) {
      if (item.product.id == product.id) {
        return item.quantity;
      }
    }
    return 0;
  }

  int get _remainingStock => product.stock - _alreadyInCart;

  void _increaseQuantity() {
    if (_quantity < _remainingStock) {
      setState(() => _quantity++);
    }
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

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
     // Quantity selector and Add to Cart
bottomNavigationBar: ListenableBuilder(
  listenable: controller,
  builder: (context, _) {
    final remaining = _remainingStock;
    final canAdd = remaining > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? _decreaseQuantity
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: canAdd && _quantity < remaining
                          ? _increaseQuantity
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: canAdd && _quantity <= remaining
                    ? () {
                        for (int i = 0; i < _quantity; i++) {
                          controller.addToCart(product);
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$_quantity x ${product.name} added to cart',
                            ),
                            backgroundColor: _green,
                          ),
                        );

                        setState(() => _quantity = 1);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFEBEFE9),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  canAdd ? 'Add to Cart' : 'Out of Stock',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
), 
    );
  }
}