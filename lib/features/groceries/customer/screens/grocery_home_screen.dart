import 'package:flutter/material.dart';
import 'my_orders_screen.dart';
import '../../controllers/grocery_controller.dart';
import '../../models/grocery_product_model.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';
import '../../../auth/screens/provider_rules_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceries'),
        actions: [
          IconButton(
  tooltip: 'Become a Seller',
  icon: const Icon(Icons.storefront_outlined),
 onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ProviderRulesScreen(),
    ),
  );
},
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
              child: _controller.products.isEmpty
                  ? const Center(child: Text('No products found'))
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
                  child: const Icon(Icons.shopping_basket_outlined, size: 55),
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
