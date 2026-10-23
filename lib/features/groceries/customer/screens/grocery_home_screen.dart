import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'my_orders_screen.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import '../../controllers/grocery_controller.dart';
import '../../models/grocery_product_model.dart';
import '../../seller/screens/seller_dashboard.dart';
import '../../../auth/screens/provider_rules_screen.dart';

class GroceryHomeScreen extends StatefulWidget {
  const GroceryHomeScreen({super.key});

  @override
  State<GroceryHomeScreen> createState() => _GroceryHomeScreenState();
}

class _GroceryHomeScreenState extends State<GroceryHomeScreen> {
  final GroceryController _controller = GroceryController();

  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openSellerArea() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    try {
      final applicationSnapshot = await FirebaseFirestore.instance
          .collection('seller_applications')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (!mounted) return;

      if (applicationSnapshot.docs.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProviderRulesScreen(),
          ),
        );
        return;
      }

      final applications = applicationSnapshot.docs.toList()
        ..sort((a, b) {
          final aDate = a.data()['createdAt'] as Timestamp?;
          final bDate = b.data()['createdAt'] as Timestamp?;

          return (bDate?.millisecondsSinceEpoch ?? 0)
              .compareTo(aDate?.millisecondsSinceEpoch ?? 0);
        });

      final status = (applications.first.data()['status'] ?? 'pending')
          .toString()
          .toLowerCase();

      if (status == 'active') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SellerDashboard(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'rejected'
                  ? 'Your seller application was rejected.'
                  : 'Your seller application is pending approval.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to check seller status: $e')),
      );
    }
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
          'Groceries',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Become a Seller',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: _openSellerArea,
          ),
          IconButton(
            tooltip: 'My Orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyOrdersScreen(),
                ),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'My Cart',
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        controller: _controller,
                      ),
                    ),
                  );
                },
              ),
              if (_controller.cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 19,
                        minHeight: 19,
                      ),
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_controller.cartItemCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF175C38),
          Color(0xFF2E8B57),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FRESH PICKS, EVERY DAY',
                style: TextStyle(
                  color: Color(0xFFCDEBD5),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Good food.\nMade simple.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your everyday essentials,\nall in one basket.',
                style: TextStyle(
                  color: Color(0xFFE1F2E5),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF439667),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.shopping_basket_outlined,
            color: Colors.white,
            size: 44,
          ),
        ),
      ],
    ),
  ),
),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                onChanged: _controller.searchProducts,
                style: const TextStyle(color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Search groceries...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF7A887D),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: _green,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E8DD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E8DD),
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
            ),
            SizedBox(
              height: 52,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _controller.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _controller.categories[index];
                  final selected =
                      _controller.selectedCategory == category;

                  return Center(
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      showCheckmark: false,
                      backgroundColor: Colors.white,
                      selectedColor: _green,
                      surfaceTintColor: Colors.transparent,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : _textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: selected
                            ? _green
                            : const Color(0xFFE0E8DD),
                      ),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      onSelected: (_) {
                        _controller.selectCategory(category);
                      },
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Text(
                'Explore groceries',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: _controller.productsLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: _green,
                      ),
                    )
                  : _controller.productsError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              'Failed to load products: '
                              '${_controller.productsError}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _controller.products.isEmpty
                          ? const Center(
                              child: Text(
                                'No approved products available',
                                style: TextStyle(
                                  color: Color(0xFF69796D),
                                ),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final columns =
                                    constraints.maxWidth < 340
                                        ? 1
                                        : constraints.maxWidth >= 700
                                            ? 3
                                            : 2;

                                final textScale =
                                    MediaQuery.textScalerOf(context)
                                        .scale(1);

                                return GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    12,
                                    20,
                                    20,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 310 +
                                        (textScale > 1
                                            ? (textScale - 1) * 180
                                            : 0),
                                  ),
                                  itemCount:
                                      _controller.products.length,
                                  itemBuilder: (context, index) {
                                    return _buildProductCard(
                                      _controller.products[index],
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(GroceryProduct product) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE3EADF),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(
                product: product,
                controller: _controller,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6EF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.asset(
                          product.imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (_, _, _) {
                            return const Icon(
                              Icons.shopping_basket_outlined,
                              size: 48,
                              color: _green,
                            );
                          },
                        )
                      : const Icon(
                          Icons.shopping_basket_outlined,
                          size: 48,
                          color: _green,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                product.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF78877A),
                  fontSize: 12,
                ),
              ),
              if (product.sellerName.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  'Seller: ${product.sellerName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF78877A),
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Rs. ${product.finalPrice.toStringAsFixed(2)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _green,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFEBEFE9),
                    disabledForegroundColor:
                        const Color(0xFF748074),
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: product.isAvailable
                      ? () {
                          _controller.addToCart(product);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: _green,
                              duration: const Duration(seconds: 1),
                              content: Text(
                                '${product.name} added to cart',
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    product.isAvailable
                        ? 'Add to Cart'
                        : 'Out of Stock',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
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