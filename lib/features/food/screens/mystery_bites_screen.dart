import 'package:flutter/material.dart';

import '../models/mystery_bites.dart';
import '../services/food_cart_service.dart';
import 'food_cart_screen.dart';

class MysteryBitesScreen extends StatefulWidget {
  const MysteryBitesScreen({super.key});

  @override
  State<MysteryBitesScreen> createState() => _MysteryBitesScreenState();
}

class _MysteryBitesScreenState extends State<MysteryBitesScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';

  final List<MysteryBitesProduct> _boxes = [
    MysteryBitesProduct(
      id: 'MB001',
      name: 'Bakery Mystery Box',
      sellerName: 'Cocos Bakery',
      foodImage: 'assets/images/food/dishes/bakery_pack.webp',
      sellerLogo: 'assets/images/food/restaurants/cocos_bakery_logo.webp',
      price: 650,
      originalPrice: 1200,
      rating: 4.9,
      reviewCount: 124,
      availableQuantity: 3,
      availableUntil: '7:00 PM',
      description: 'A surprise box packed with suitable unsold bakery items available at the end of the day.',
      estimatedValue: 1200,
      possibleItems: ['Cakes', 'Pastries', 'Buns', 'Sweet treats'],
      allergens: ['Milk', 'Eggs', 'Wheat'],
      collectionTime: '6:00 PM - 7:00 PM',
      containsVegetarianOptions: true,
    ),

    MysteryBitesProduct(
      id: 'MB002',
      name: 'Dinner Mystery Box',
      sellerName: 'Spice Garden Restaurant',
      foodImage: 'assets/images/food/dishes/chicken_rice.webp',
      sellerLogo: 'assets/images/food/restaurants/spice_garden_logo.webp',
      price: 550,
      originalPrice: 1000,
      rating: 4.7,
      reviewCount: 89,
      availableQuantity: 5,
      availableUntil: '8:30 PM',
      description: 'A surprise dinner box created from suitable surplus food available that evening.',
      estimatedValue: 1000,
      possibleItems: ['Rice', 'Curry', 'Vegetable dishes', 'Side dishes'],
      allergens: ['May vary'],
      collectionTime: '7:30 PM - 8:30 PM',
      containsVegetarianOptions: true,
    ),

    MysteryBitesProduct(
      id: 'MB003',
      name: 'Sweet Treat Box',
      sellerName: 'Cocos Bakery',
      foodImage: 'assets/images/food/dishes/chocolate_brownies.webp',
      sellerLogo: 'assets/images/food/restaurants/cocos_bakery_logo.webp',
      price: 450,
      originalPrice: 800,
      rating: 4.9,
      reviewCount: 67,
      availableQuantity: 4,
      availableUntil: '7:30 PM',
      description: 'A sweet surprise box containing suitable bakery desserts available that day.',
      estimatedValue: 800,
      possibleItems: ['Brownies', 'Cupcakes', 'Cookies', 'Pastries'],
      allergens: ['Milk', 'Eggs', 'Wheat'],
      collectionTime: '6:30 PM - 7:30 PM',
      containsVegetarianOptions: true,
    ),
  ];

  List<MysteryBitesProduct> get _filteredBoxes {
    if (_searchText.isEmpty) {
      return _boxes;
    }

    return _boxes.where((box) {
      final query = _searchText.toLowerCase();

      return box.name.toLowerCase().contains(query) ||
          box.sellerName.toLowerCase().contains(query);
    }).toList();
  }

  int _discountPercentage(MysteryBitesProduct box) {
    if (box.originalPrice == null || box.originalPrice == 0) {
      return 0;
    }

    return ((1 - (box.price / box.originalPrice!)) * 100).round();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MysteryBites',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FoodCartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredBoxes.length,
              itemBuilder: (context, index) {
                final box = _filteredBoxes[index];

                return _MysteryBitesCard(
                  box: box,
                  discount: _discountPercentage(box),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MysteryBitesDetailsScreen(box: box),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      color: Colors.black,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A surprise worth discovering 🎁',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enjoy suitable surplus food at a special price.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search MysteryBites...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchText = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _MysteryBitesCard extends StatelessWidget {
  final MysteryBitesProduct box;
  final int discount;
  final VoidCallback onTap;

  const _MysteryBitesCard({
    required this.box,
    required this.discount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: Image.asset(
                    box.foodImage,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _RestaurantLogo(imagePath: box.sellerLogo),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              box.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              box.sellerName,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            box.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        'Rs. ${box.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (box.originalPrice != null)
                        Text(
                          'Rs. ${box.originalPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 17,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${box.availableQuantity} left',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 17,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Until ${box.availableUntil}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      child: const Text('View MysteryBites'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantLogo extends StatelessWidget {
  final String imagePath;

  const _RestaurantLogo({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(imagePath, width: 46, height: 46, fit: BoxFit.cover),
    );
  }
}

class MysteryBitesDetailsScreen extends StatefulWidget {
  final MysteryBitesProduct box;

  const MysteryBitesDetailsScreen({super.key, required this.box});

  @override
  State<MysteryBitesDetailsScreen> createState() =>
      _MysteryBitesDetailsScreenState();
}

class _MysteryBitesDetailsScreenState extends State<MysteryBitesDetailsScreen> {
  int quantity = 1;
  bool deliverySelected = true;

  @override
  Widget build(BuildContext context) {
    final box = widget.box;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      appBar: AppBar(
        title: const Text('MysteryBites'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          Image.asset(
            box.foodImage,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  box.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  box.sellerName,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 5),
                    Text(
                      '${box.rating.toStringAsFixed(1)} (${box.reviewCount} reviews)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  'Rs. ${box.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (box.originalPrice != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Estimated original value: Rs. ${box.originalPrice!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                const Text(
                  'About this MysteryBites',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  box.description,
                  style: const TextStyle(height: 1.5, color: Colors.black87),
                ),

                const SizedBox(height: 24),

                const Text(
                  'What could be inside?',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: box.possibleItems
                      .map((item) => Chip(label: Text(item)))
                      .toList(),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Allergens',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  box.allergens.join(', '),
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Collection Time',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  box.collectionTime,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Fulfilment',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _FulfilmentButton(
                        title: 'Delivery',
                        icon: Icons.delivery_dining,
                        selected: deliverySelected,
                        onTap: () {
                          setState(() {
                            deliverySelected = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FulfilmentButton(
                        title: 'Pickup',
                        icon: Icons.storefront,
                        selected: !deliverySelected,
                        onTap: () {
                          setState(() {
                            deliverySelected = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Quantity',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () {
                        if (quantity < box.availableQuantity) {
                          setState(() {
                            quantity++;
                          });
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      FoodCartService.instance.addProduct(box, quantity);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('MysteryBites added to cart'),
                          action: SnackBarAction(
                            label: 'VIEW CART',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FoodCartScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfilmentButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FulfilmentButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon),
      ),
    );
  }
}
