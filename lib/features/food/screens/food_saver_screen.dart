import 'package:flutter/material.dart';

import '../models/food_product.dart';
import '../services/food_cart_service.dart';
import 'food_cart_screen.dart';

class SaveBiteOffer extends FoodProduct {
  final String foodName;
  final String restaurantName;
  final String restaurantLogo;
  final String foodImage;

  final double originalPrice;
  final double saverPrice;

  final int quantity;

  final String endingTime;
  final double rating;
  final String description;
  final String category;
  final String collectionTime;
  final String allergens;

  const SaveBiteOffer({
    required String id,
    required this.foodName,
    required this.restaurantName,
    required this.restaurantLogo,
    required this.foodImage,
    required this.originalPrice,
    required this.saverPrice,
    required this.quantity,
    required this.endingTime,
    required this.rating,
    required this.description,
    required this.category,
    required this.collectionTime,
    required this.allergens,
  }) : super(
         id: id,
         name: foodName,
         sellerName: restaurantName,
         foodImage: foodImage,
         sellerLogo: restaurantLogo,
         price: saverPrice,
         originalPrice: originalPrice,
         rating: rating,
         reviewCount: 0,
         availableQuantity: quantity,
         availableUntil: endingTime,
         type: FoodProductType.saveBite,
       );

  int get discountPercentage {
    return ((originalPrice - saverPrice) / originalPrice * 100).round();
  }

  double get savings {
    return originalPrice - saverPrice;
  }
}

class FoodSaverScreen extends StatefulWidget {
  const FoodSaverScreen({super.key});

  @override
  State<FoodSaverScreen> createState() => _FoodSaverScreenState();
}

class _FoodSaverScreenState extends State<FoodSaverScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Meals',
    'Bakery',
    'Pizza',
    'Desserts',
  ];

  final List<SaveBiteOffer> offers = const [
    SaveBiteOffer(
      id: 'SB001',
      foodName: 'Chicken Rice & Curry',
      restaurantName: 'Spice Garden Restaurant',
      restaurantLogo: 'assets/images/food/restaurants/spice_garden_logo.webp',
      foodImage: 'assets/images/food/dishes/chicken_rice.webp',
      originalPrice: 650,
      saverPrice: 390,
      quantity: 5,
      endingTime: '7:00 PM',
      rating: 4.7,
      description: 'A delicious Sri Lankan rice and curry meal available at a special SaveBite price before closing time.',
      category: 'Meals',
      collectionTime: '6:00 PM - 7:00 PM',
      allergens: 'May contain coconut and spices.',
    ),

    SaveBiteOffer(
      id: 'SB002',
      foodName: 'Bakery Surprise Pack',
      restaurantName: 'Cocos Bakery',
      restaurantLogo: 'assets/images/food/restaurants/cocos_bakery_logo.webp',
      foodImage: 'assets/images/food/dishes/bakery_pack.webp',
      originalPrice: 800,
      saverPrice: 450,
      quantity: 3,
      endingTime: '6:30 PM',
      rating: 4.9,
      description: 'A selection of freshly baked bakery items that are available at a discounted SaveBite price.',
      category: 'Bakery',
      collectionTime: '5:30 PM - 6:30 PM',
      allergens: 'Contains wheat, eggs and dairy.',
    ),

    SaveBiteOffer(
      id: 'SB003',
      foodName: 'Pizza Slices',
      restaurantName: 'Urban Pizza',
      restaurantLogo: 'assets/images/food/restaurants/urban_pizza_logo.webp',
      foodImage: 'assets/images/food/dishes/pizza_slices.webp',
      originalPrice: 900,
      saverPrice: 500,
      quantity: 4,
      endingTime: '8:00 PM',
      rating: 4.6,
      description: 'Fresh pizza slices available near the end of the restaurant service at a reduced price.',
      category: 'Pizza',
      collectionTime: '7:00 PM - 8:00 PM',
      allergens: 'Contains wheat, dairy and possible soy.',
    ),

    SaveBiteOffer(
      id: 'SB004',
      foodName: 'Chocolate Brownies',
      restaurantName: 'Cocos Bakery',
      restaurantLogo: 'assets/images/food/restaurants/cocos_bakery_logo.webp',
      foodImage: 'assets/images/food/dishes/chocolate_brownies.webp',
      originalPrice: 600,
      saverPrice: 350,
      quantity: 6,
      endingTime: '7:30 PM',
      rating: 4.9,
      description:
          'Rich chocolate brownies rescued from the end-of-day bakery stock.',
      category: 'Desserts',
      collectionTime: '6:30 PM - 7:30 PM',
      allergens: 'Contains wheat, eggs and dairy.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SaveBiteOffer> get filteredOffers {
    final search = _searchController.text.toLowerCase().trim();

    return offers.where((offer) {
      final matchesCategory =
          selectedCategory == 'All' || offer.category == selectedCategory;

      final matchesSearch =
          search.isEmpty ||
          offer.foodName.toLowerCase().contains(search) ||
          offer.restaurantName.toLowerCase().contains(search);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredOffers;

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
          'SaveBite',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),

        actions: [
          Builder(
            builder: (context) {
              final cart = FoodCartService.instance;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FoodCartScreen(),
                        ),
                      ).then((_) {
                        setState(() {});
                      });
                    },
                  ),

                  if (cart.totalItems > 0)
                    Positioned(
                      right: 6,
                      top: 5,
                      child: Container(
                        height: 18,
                        width: 18,

                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),

                        child: Center(
                          child: Text(
                            '${cart.totalItems}',
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
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 18),

            _buildSearchBar(),

            const SizedBox(height: 16),

            _buildCategories(),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Near You',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    '${filtered.length} offers',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _SaveBiteCard(
                    offer: filtered[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SaveBiteDetailsScreen(offer: filtered[index]),
                        ),
                      );
                    },
                  );
                },
              ),

            _buildImpactCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 34),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good food. Better prices.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Rescue delicious food before it goes to waste.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,

          onChanged: (_) {
            setState(() {});
          },

          decoration: InputDecoration(
            hintText: 'Search food or restaurant...',

            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),

            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),

            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,

            border: InputBorder.none,

            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,

        separatorBuilder: (_, __) => const SizedBox(width: 8),

        itemBuilder: (context, index) {
          final category = categories[index];

          final selected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E7D32) : Colors.white,

                borderRadius: BorderRadius.circular(22),

                border: Border.all(
                  color: selected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade200,
                ),
              ),

              child: Text(
                category,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),

      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),

      child: const Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 50, color: Colors.grey),

            SizedBox(height: 12),

            Text(
              'No SaveBites found',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 5),

            Text(
              'Try another food or restaurant.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(Icons.eco_rounded, color: Color(0xFF2E7D32)),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Every rescued meal helps reduce food waste. 🌱',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBiteCard extends StatelessWidget {
  final SaveBiteOffer offer;
  final VoidCallback onTap;

  const _SaveBiteCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Stack(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,

                  child: Image.asset(
                    offer.foodImage,
                    fit: BoxFit.cover,

                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('IMAGE ERROR: ${offer.foodImage}');

                      debugPrint('ERROR DETAILS: $error');

                      return Container(
                        color: const Color(0xFFE8F5E9),

                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              const Icon(
                                Icons.restaurant_rounded,
                                size: 55,
                                color: Color(0xFF66BB6A),
                              ),

                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  'Image not found\n${offer.foodImage}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  top: 12,
                  left: 12,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      '${offer.discountPercentage}% OFF',

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.orange,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          'Until ${offer.endingTime}',

                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
                      _RestaurantLogo(
                        imagePath: offer.restaurantLogo,
                        size: 40,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              offer.restaurantName,

                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: Colors.amber,
                                ),

                                const SizedBox(width: 3),

                                Text(
                                  '${offer.rating}',

                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: Colors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    offer.foodName,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      Text(
                        'Rs. ${offer.saverPrice.toStringAsFixed(0)}',

                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'Rs. ${offer.originalPrice.toStringAsFixed(0)}',

                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 15,
                        color: offer.quantity <= 3 ? Colors.red : Colors.orange,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        '${offer.quantity} portions left',

                        style: TextStyle(
                          fontSize: 12,
                          color: offer.quantity <= 3
                              ? Colors.red
                              : Colors.orange.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        'Save Rs. ${offer.savings.toStringAsFixed(0)}',

                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
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
    );
  }
}

class _RestaurantLogo extends StatelessWidget {
  final String imagePath;
  final double size;

  const _RestaurantLogo({required this.imagePath, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(5),

      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,

        border: Border.all(color: Colors.grey.shade200, width: 1),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 5),
        ],
      ),

      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,

          errorBuilder: (context, error, stackTrace) {
            debugPrint('LOGO ERROR: $imagePath');

            debugPrint('LOGO ERROR DETAILS: $error');

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storefront_rounded,
                  color: Colors.grey.shade500,
                  size: size * 0.45,
                ),

                if (size >= 50)
                  Text(
                    'Logo not found',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 7, color: Colors.grey.shade600),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SaveBiteDetailsScreen extends StatefulWidget {
  final SaveBiteOffer offer;

  const SaveBiteDetailsScreen({super.key, required this.offer});

  @override
  State<SaveBiteDetailsScreen> createState() => _SaveBiteDetailsScreenState();
}

class _SaveBiteDetailsScreenState extends State<SaveBiteDetailsScreen> {
  int quantity = 1;
  bool delivery = true;

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

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
          'SaveBite Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Stack(
              children: [
                SizedBox(
                  height: 260,
                  width: double.infinity,

                  child: Image.asset(
                    offer.foodImage,
                    fit: BoxFit.cover,

                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('DETAIL IMAGE ERROR: ${offer.foodImage}');

                      debugPrint('ERROR DETAILS: $error');

                      return Container(
                        color: const Color(0xFFE8F5E9),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(
                              Icons.restaurant_rounded,
                              size: 80,
                              color: Color(0xFF66BB6A),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              'Image not found\n${offer.foodImage}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  left: 16,
                  bottom: 16,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      '${offer.discountPercentage}% OFF',

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      _RestaurantLogo(
                        imagePath: offer.restaurantLogo,
                        size: 54,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              offer.restaurantName,

                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 17,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  '${offer.rating}',

                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                Text(
                                  '  Restaurant',

                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    offer.foodName,

                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,

                    children: [
                      Text(
                        'Rs. ${offer.saverPrice.toStringAsFixed(0)}',

                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),

                        child: Text(
                          'Rs. ${offer.originalPrice.toStringAsFixed(0)}',

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'You save Rs. ${offer.savings.toStringAsFixed(0)}',

                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'About this food',

                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    offer.description,

                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    title: 'Availability',
                    value: '${offer.quantity} portions left',
                  ),

                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    title: 'Available until',
                    value: offer.endingTime,
                  ),

                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Collection time',
                    value: offer.collectionTime,
                  ),

                  const SizedBox(height: 12),

                  _InfoRow(
                    icon: Icons.warning_amber_rounded,
                    title: 'Allergen information',
                    value: offer.allergens,
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Fulfilment',

                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _FulfilmentButton(
                          icon: Icons.delivery_dining_rounded,
                          title: 'Delivery',
                          selected: delivery,

                          onTap: () {
                            setState(() {
                              delivery = true;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _FulfilmentButton(
                          icon: Icons.storefront_rounded,
                          title: 'Pickup',
                          selected: !delivery,

                          onTap: () {
                            setState(() {
                              delivery = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Quantity',

                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _QuantityButton(
                        icon: Icons.add,

                        onTap: () {
                          if (quantity < offer.quantity) {
                            setState(() {
                              quantity++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),

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
          child: SizedBox(
            height: 54,
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () {
                FoodCartService.instance.addProduct(offer, quantity);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$quantity × ${offer.foodName} added to cart',
                    ),
                    behavior: SnackBarBehavior.floating,

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

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),

              child: Text(
                'Add to Cart • Rs. ${(offer.saverPrice * quantity).toStringAsFixed(0)}',

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          height: 38,
          width: 38,

          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 2),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FulfilmentButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FulfilmentButton({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F5E9) : Colors.white,

          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: selected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              icon,

              color: selected ? const Color(0xFF2E7D32) : Colors.grey,

              size: 21,
            ),

            const SizedBox(width: 7),

            Text(
              title,

              style: TextStyle(
                fontWeight: FontWeight.bold,

                color: selected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade700,
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

      borderRadius: BorderRadius.circular(12),

      child: Container(
        height: 40,
        width: 40,

        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Icon(icon, color: const Color(0xFF2E7D32)),
      ),
    );
  }
}
