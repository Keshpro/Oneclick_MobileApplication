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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174D38), Color(0xFF286B4D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              '♻️  FOOD RESCUE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Good food.\nGreat surprises. 🎁',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Discover surprise food boxes at amazing prices while helping reduce food waste.',
            style: TextStyle(
              color: Color(0xFFDDEEE3),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.savings_rounded,
                color: Color(0xFFFFD58A),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Save money • Save food • Enjoy!',
                style: TextStyle(
                  color: Color(0xFFFFD58A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Find a surprise box...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF286B4D),
          ),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF174D38).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.asset(
                    box.foodImage,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 210,
                      color: const Color(0xFFF1E8D8),
                      child: const Center(
                        child: Icon(
                          Icons.fastfood_rounded,
                          size: 60,
                          color: Color(0xFF286B4D),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF174D38),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 17,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          box.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _RestaurantLogo(imagePath: box.sellerLogo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              box.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              box.sellerName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${box.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF174D38),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (box.originalPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Rs. ${box.originalPrice!.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.inventory_2_outlined,
                          text: '${box.availableQuantity} boxes left',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoPill(
                          icon: Icons.access_time_rounded,
                          text: 'Until ${box.availableUntil}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF174D38),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Discover your box',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF286B4D)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF345845),
              ),
            ),
          ),
        ],
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
