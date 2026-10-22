import 'package:flutter/material.dart';
import 'my_orders_screen.dart';
import '../../controllers/grocery_controller.dart';
import '../../models/grocery_product_model.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import '../../../auth/screens/provider_rules_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../seller/screens/seller_dashboard.dart';

class GroceryHomeScreen extends StatefulWidget {
  const GroceryHomeScreen({super.key});

  @override
  State<GroceryHomeScreen> createState() => _GroceryHomeScreenState();
}

class _GroceryHomeScreenState extends State<GroceryHomeScreen> {
  final GroceryController _controller = GroceryController();

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

    final status =
        (applications.first.data()['status'] ?? 'pending')
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
      appBar: AppBar(
        title: const Text('Groceries'),
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
                MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(controller: _controller),
                    ),
                  );
                },
              ),
              if (_controller.cartItemCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: CircleAvatar(
                    radius: 9,
                    child: Text(
                      '${_controller.cartItemCount}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: _controller.searchProducts,
                decoration: InputDecoration(
                  hintText: 'Search groceries...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Categories
            SizedBox(
              height: 45,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _controller.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _controller.categories[index];

                  return ChoiceChip(
                    label: Text(category),
                    selected: _controller.selectedCategory == category,
                    onSelected: (_) {
                      _controller.selectCategory(category);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Products
            Expanded(
             child: _controller.productsLoading
    ? const Center(child: CircularProgressIndicator())
    : _controller.productsError != null
        ? Center(
            child: Text(
              'Failed to load products: ${_controller.productsError}',
              textAlign: TextAlign.center,
            ),
          )
        : _controller.products.isEmpty
            ? const Center(child: Text('No approved products available'))
            : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: _controller.products.length,
                      itemBuilder: (context, index) {
                        final product = _controller.products[index];

                        return _buildProductCard(product);
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
      clipBehavior: Clip.antiAlias,
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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: product.imageUrl.isNotEmpty
    ? Image.asset(
        product.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.shopping_basket_outlined,
            size: 55,
          );
        },
      )
    : const Icon(
        Icons.shopping_basket_outlined,
        size: 55,
      ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(
                product.category,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              if (product.sellerName.isNotEmpty)
  Text(
    'Seller: ${product.sellerName}',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
      fontSize: 11,
      color: Colors.grey,
    ),
  ),

              const SizedBox(height: 5),

              Text(
                'Rs. ${product.finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: product.isAvailable
                      ? () {
                          _controller.addToCart(product);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text('${product.name} added to cart'),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    product.isAvailable ? 'Add to Cart' : 'Out of Stock',
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
