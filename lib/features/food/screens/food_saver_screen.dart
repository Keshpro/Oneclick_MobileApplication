import 'package:flutter/material.dart';

import '../../auth/screens/provider_rules_screen.dart';

import 'dart:ui' show FontFeature;

import '../models/food_product.dart';
import '../services/food_cart_service.dart';
import 'food_cart_screen.dart';
import 'food_checkout_screen.dart';
import 'food_home_screen.dart';
import '../../auth/screens/home_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_offer_model.dart' as seller_model;

import 'dart:async';

class SaveBiteOffer extends FoodProduct {
  final String foodName;
  final String restaurantName;
  final String restaurantLogo;
  @override
  final String foodImage;

  @override
  final double originalPrice;
  final double saverPrice;

  final int quantity;

  final String endingTime;

  final DateTime? expiresAt;

  @override
  final double rating;
  final String description;
  final String category;
  final String collectionTime;
  final String allergens;

  const SaveBiteOffer({
    required super.id,
    super.firestoreOfferPath,
    required this.foodName,
    required this.restaurantName,
    required this.restaurantLogo,
    required this.foodImage,
    required this.originalPrice,
    required this.saverPrice,
    required this.quantity,
    required this.endingTime,
    required this.expiresAt,
    required this.rating,
    required this.description,
    required this.category,
    required this.collectionTime,
    required this.allergens,
  }) : super(
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
    if (originalPrice <= 0) return 0;
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

  bool _showSellerBanner = true;

  @override
  void initState() {
    super.initState();
    _loadFirestoreOffers();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSellerBanner = false;
        });
      }
    });
  }

  String selectedCategory = 'All';
  List<SaveBiteOffer> firestoreOffers = [];
  bool isLoadingFirestoreOffers = true;
  String? firestoreOffersError;

  final List<String> categories = [
    'All',
    'Meals',
    'Bakery',
    'Pizza',
    'Desserts',
    'Snacks',
    'Beverages',
    'Other',
    'Sold Out',
  ];
  DateTime? _calculateExpiry(Map<String, dynamic> data, String endingTime) {
    final createdAt = data['createdAt'];

    DateTime? createdDate;

    if (createdAt is Timestamp) {
      createdDate = createdAt.toDate();
    } else if (createdAt is DateTime) {
      createdDate = createdAt;
    }

    if (createdDate == null) return null;

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(endingTime.trim());

    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final period = match.group(3)!.toUpperCase();

    if (hour < 1 || hour > 12 || minute < 0 || minute > 59) {
      return null;
    }

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return DateTime(
      createdDate.year,
      createdDate.month,
      createdDate.day,
      hour,
      minute,
    );
  }

  final List<SaveBiteOffer> offers = const [];

  Future<void> _loadFirestoreOffers() async {
    try {
      debugPrint('SaveBite: Starting Firestore query');

      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('offers')
          .get()
          .timeout(const Duration(seconds: 15));

      debugPrint('SaveBite: Found ${snapshot.docs.length} offer documents');

      final List<SaveBiteOffer> loadedOffers = [];

      for (final document in snapshot.docs) {
        // Only read offers belonging to a food seller.
        final sellerReference = document.reference.parent.parent;
        if (sellerReference == null ||
            sellerReference.parent.id != 'food_sellers') {
          continue;
        }

        final sellerSnapshot = await sellerReference.get();
        if (!sellerSnapshot.exists) continue;

        final sellerData = sellerSnapshot.data() ?? <String, dynamic>{};

        final role = (sellerData['role'] ?? '').toString().toLowerCase();
        final sellerStatus = (sellerData['status'] ?? '')
            .toString()
            .toLowerCase();

        // Only show approved, active food sellers.
        if (role != 'foodseller' || sellerStatus != 'active') continue;

        final data = document.data();
        final offerStatus = (data['status'] ?? 'ACTIVE')
            .toString()
            .toUpperCase();

        if (offerStatus != 'ACTIVE') continue;

        final offer = seller_model.FoodOfferModel.fromFirestore(document);

        final rawExpiry = data['expiresAt'];

        final DateTime? expiresAt = rawExpiry is Timestamp
            ? rawExpiry.toDate()
            : rawExpiry is DateTime
            ? rawExpiry
            : null;

        // Do not display offers with missing or expired deadlines.
        if (expiresAt == null || !expiresAt.isAfter(DateTime.now())) {
          continue;
        }

        final originalPrice = double.tryParse(offer.originalPrice) ?? 0;
        final saverPrice = double.tryParse(offer.saverPrice) ?? 0;
        final quantity = int.tryParse(offer.quantity) ?? 0;

        if (offer.foodName.trim().isEmpty ||
            originalPrice <= 0 ||
            saverPrice < 0 ||
            quantity < 0) {
          continue;
        }

        final providerDetails =
            sellerData['providerDetails'] as Map<String, dynamic>? ?? {};

        final restaurantName =
            (providerDetails['restaurantName'] ??
                    sellerData['storeName'] ??
                    sellerData['businessName'] ??
                    'Food Seller')
                .toString();

        loadedOffers.add(
          SaveBiteOffer(
            id: document.id,
            foodName: offer.foodName,
            restaurantName: restaurantName,
            restaurantLogo:
                'assets/images/food/restaurants/cocos_bakery_logo.webp',
            foodImage: offer.imageUrl?.isNotEmpty == true
                ? offer.imageUrl!
                : 'assets/images/food/dishes/bakery_pack.webp',
            originalPrice: originalPrice,
            saverPrice: saverPrice,
            quantity: quantity,
            endingTime: offer.availableUntil,
            expiresAt: expiresAt,
            rating: 0.0,
            description: offer.description,
            category: _customerCategory(offer.category),
            collectionTime: '${offer.availableFrom} - ${offer.availableUntil}',
            allergens: offer.allergens,
            firestoreOfferPath: document.reference.path,
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        firestoreOffers = loadedOffers;
        isLoadingFirestoreOffers = false;
        firestoreOffersError = null;
      });
    } catch (error, stackTrace) {
      debugPrint('SaveBite Firestore load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        isLoadingFirestoreOffers = false;
        firestoreOffersError = 'Could not load offers. Please try again.';
      });
    }
  }

  String _customerCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'rice & curry':
      case 'rice and curry':
      case 'fast food':
        return 'Meals';
      case 'dessert':
      case 'desserts':
        return 'Desserts';
      case 'bakery':
        return 'Bakery';
      case 'pizza':
        return 'Pizza';
      case 'snacks':
        return 'Snacks';
      case 'beverages':
        return 'Beverages';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  Future<void> _refreshFirestoreOffers() async {
    if (!mounted) return;

    setState(() {
      isLoadingFirestoreOffers = true;
      firestoreOffersError = null;
    });

    await _loadFirestoreOffers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SaveBiteOffer> get filteredOffers {
    final search = _searchController.text.toLowerCase().trim();

    final allOffers = [...offers, ...firestoreOffers];

    return allOffers.where((offer) {
      final matchesCategory = selectedCategory == 'All'
          ? true
          : selectedCategory == 'Sold Out'
          ? offer.quantity == 0
          : offer.category.toLowerCase() == selectedCategory.toLowerCase();

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
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF292421)),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),

        title: const Text(
          'Save Bites',
          style: TextStyle(
            color: Color(0xFF292421),
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
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
                      color: Color(0xFF292421),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FoodCartScreen(),
                        ),
                      ).then((_) async {
                        if (!mounted) return;

                        await _refreshFirestoreOffers();
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

      body: Stack(
        children: [
          SingleChildScrollView(
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
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Fresh Deals 🍊',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF292421),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${filtered.length} offers',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF5722),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (isLoadingFirestoreOffers)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF5722),
                      ),
                    ),
                  )
                else if (firestoreOffersError != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            firestoreOffersError!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoadingFirestoreOffers = true;
                                firestoreOffersError = null;
                              });
                              _loadFirestoreOffers();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
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

          // Animated Become a Food Seller banner
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            top: _showSellerBanner ? 12 : -220,
            left: 16,
            right: 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _showSellerBanner ? 1 : 0,
              child: _showSellerBanner
                  ? Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.30),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Own a Food Business? 🍽️',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                const Text(
                                  'Join OneClick and turn surplus food into sales!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ProviderRulesScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Become a Seller',
                                          style: TextStyle(
                                            color: Color(0xFF1B5E20),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Color(0xFF1B5E20),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showSellerBanner = false;
                              });
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 210,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A35), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: -30,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '♻️  FOOD RESCUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Good food.\nAmazing deals!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Grab delicious meals for less\nbefore they disappear!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('🍕', style: TextStyle(fontSize: 85)),
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
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFE4D2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8A35).withValues(alpha: 0.07),
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
            hintText: 'Find delicious deals...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFFFF8A35),
              size: 24,
            ),
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
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
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
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFFFF8A35), Color(0xFFFF5722)],
                      )
                    : null,
                color: selected ? null : const Color(0xFFFFF5ED),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : const Color(0xFFFFE0CC),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF5722)
                              .withValues(alpha: 0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF6B5548),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
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
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFFE4D2)),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 85,
              width: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.no_food_rounded,
                size: 42,
                color: Color(0xFFFF8A35),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No tasty deals found!',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Color(0xFF292421),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try another category or search for something else.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE8D5), Color(0xFFFFF3E7)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD5B5)),
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFFFF8A35),
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good for you. Good for Earth! 🌱',
                  style: TextStyle(
                    color: Color(0xFF713B20),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Every rescued meal helps reduce food waste.',
                  style: TextStyle(
                    color: Color(0xFF875D45),
                    fontSize: 12,
                    height: 1.4,
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

class _ExpiryCountdown extends StatefulWidget {
  final DateTime expiresAt;

  const _ExpiryCountdown({required this.expiresAt});

  @override
  State<_ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<_ExpiryCountdown> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final remaining = widget.expiresAt.difference(DateTime.now());

    if (!mounted) return;

    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });

    if (_remaining == Duration.zero) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _remaining.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final urgent = totalSeconds <= 600;

    final color = urgent ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            urgent ? Icons.timer_rounded : Icons.hourglass_bottom_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalSeconds == 0
                      ? 'Collection time ended'
                      : urgent
                      ? 'Hurry! Time is running out'
                      : 'Rescue this food before',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_twoDigits(hours)}:'
                  '${_twoDigits(minutes)}:'
                  '${_twoDigits(seconds)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

class _SaveBiteCard extends StatelessWidget {
  final SaveBiteOffer offer;
  final VoidCallback onTap;

  const _SaveBiteCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.orange.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: offer.foodImage.startsWith('http')
                      ? Image.network(
                          offer.foodImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFFFF0DF),
                              child: const Center(
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  size: 65,
                                  color: Color(0xFFFF8A35),
                                ),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          offer.foodImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFFFF0DF),
                              child: const Center(
                                child: Icon(
                                  Icons.fastfood_rounded,
                                  size: 65,
                                  color: Color(0xFFFF8A35),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Discount badge
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${offer.discountPercentage}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                // Ending time
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Color(0xFFFF5722),
                        ),
                        const SizedBox(width: 5),
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

                // Food rescue label
                Positioned(
                  bottom: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      '♻️  SAVE BITES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant
                  Row(
                    children: [
                      _RestaurantLogo(
                        imagePath: offer.restaurantLogo,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.restaurantName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${offer.rating}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2E8),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFFFF5722),
                          size: 19,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Food name
                  Text(
                    offer.foodName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF242424),
                    ),
                  ),

                  if (offer.expiresAt != null) ...[
                    const SizedBox(height: 12),
                    _ExpiryCountdown(expiresAt: offer.expiresAt!),
                  ],

                  const SizedBox(height: 14),

                  // Price section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rs. ${offer.saverPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 23,
                          color: Color(0xFFFF5722),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Rs. ${offer.originalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Remaining quantity and savings
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: 16,
                        color: offer.quantity <= 3
                            ? Colors.red
                            : const Color(0xFFFF8A35),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          offer.quantity == 0
                              ? 'Out of Stock'
                              : offer.quantity == 1
                              ? 'Last Portion!'
                              : '${offer.quantity} portions left',
                          style: TextStyle(
                            fontSize: 12,
                            color: offer.quantity == 0
                                ? Colors.grey
                                : offer.quantity <= 3
                                ? Colors.red
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Save Rs. ${offer.savings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFF5722),
                            fontWeight: FontWeight.w900,
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 5),
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

  static const Color orange = Color(0xFFFF5722);
  static const Color lightOrange = Color(0xFFFFF0E3);
  static const Color darkText = Color(0xFF292421);
  static const Color cream = Color(0xFFFFF8F2);

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;

    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkText),
          onPressed: () {
            Navigator.of(context).popUntil(
              (route) => route.isFirst || route.settings.name == '/foodSaver',
            );
          },
        ),
        title: const Text(
          'SaveBite Details',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w900),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOOD IMAGE
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Image.asset(
                    offer.foodImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFE8D9),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 90,
                            color: orange,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  top: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${offer.discountPercentage}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 18,
                  left: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      '♻️ FOOD RESCUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // MAIN INFORMATION CARD
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: orange.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RESTAURANT
                  Row(
                    children: [
                      _RestaurantLogo(
                        imagePath: offer.restaurantLogo,
                        size: 56,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.restaurantName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(height: 5),
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
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Restaurant',
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

                  const SizedBox(height: 24),

                  // FOOD NAME
                  Text(
                    offer.foodName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // PRICE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${offer.saverPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: orange,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Rs. ${offer.originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.savings_rounded,
                          color: orange,
                          size: 19,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'You save Rs. ${offer.savings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFB84620),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // DESCRIPTION
                  _SectionTitle(title: 'About this food'),

                  const SizedBox(height: 9),

                  Text(
                    offer.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // INFORMATION
                  _SectionTitle(title: 'Food information'),

                  const SizedBox(height: 16),

                  _InfoRow(
                    icon: Icons.inventory_2_rounded,
                    title: 'Availability',
                    value: offer.quantity == 0
                        ? 'Out of Stock'
                        : offer.quantity == 1
                        ? 'Last portion available'
                        : '${offer.quantity} portions left',
                  ),

                  const SizedBox(height: 15),

                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    title: 'Available until',
                    value: offer.endingTime,
                  ),

                  const SizedBox(height: 15),

                  _InfoRow(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Collection time',
                    value: offer.collectionTime,
                  ),

                  const SizedBox(height: 15),

                  _InfoRow(
                    icon: Icons.warning_amber_rounded,
                    title: 'Allergen information',
                    value: offer.allergens,
                  ),

                  const SizedBox(height: 26),

                  // FULFILMENT
                  _SectionTitle(title: 'Choose fulfilment'),

                  const SizedBox(height: 13),

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

                      const SizedBox(width: 12),

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

                  const SizedBox(height: 26),

                  // QUANTITY
                  _SectionTitle(title: 'Select quantity'),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE2CE)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Portions',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        _QuantityButton(
                          icon: Icons.remove_rounded,
                          onTap: () {
                            if (offer.quantity > 0 && quantity > 1) {
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
                              fontWeight: FontWeight.w900,
                              color: darkText,
                            ),
                          ),
                        ),

                        _QuantityButton(
                          icon: Icons.add_rounded,
                          onTap: () {
                            if (offer.quantity > 0 &&
                                quantity < offer.quantity) {
                              setState(() {
                                quantity++;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    offer.quantity <= 0
                        ? 'Currently unavailable'
                        : '${offer.quantity} portions available',
                    style: TextStyle(
                      color: offer.quantity <= 3
                          ? Colors.red.shade700
                          : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // FOOD RESCUE MESSAGE
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE8D5), Color(0xFFFFF3E7)],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFFFD5B5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco_rounded, color: orange, size: 32),
                  SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your rescue matters! 🌱',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: Color(0xFF713B20),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Enjoy great food while helping reduce food waste.',
                          style: TextStyle(
                            color: Color(0xFF875D45),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // BOTTOM ADD TO CART
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 54,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: offer.quantity <= 0
                        ? null
                        : () {
                            if (quantity > offer.quantity) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Not enough portions are available.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final added = FoodCartService.instance.addProduct(
                              offer,
                              quantity,
                            );

                            if (!added) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'This offer has expired or is no longer available.',
                                  ),
                                ),
                              );
                              return;
                            }

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
                      backgroundColor: const Color(0xFFE8F5E9),
                      foregroundColor: const Color(0xFF2E7D32),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: Text(
                      'Add to Cart • Rs. ${(offer.saverPrice * quantity).toStringAsFixed(0)}',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: offer.quantity <= 0
                        ? null
                        : () {
                            if (quantity > offer.quantity) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Not enough portions are available.',
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FoodCheckoutScreen(
                                  directItems: [
                                    FoodCartItem(
                                      product: offer,
                                      quantity: quantity,
                                    ),
                                  ],
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
                      'Buy Now • Rs. ${(offer.saverPrice * quantity).toStringAsFixed(0)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SECTION TITLE
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF292421),
      ),
    );
  }
}

// INFORMATION ROW
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
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, size: 21, color: const Color(0xFFFF5722)),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF292421),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// DELIVERY / PICKUP BUTTON
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
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFFF8A35), Color(0xFFFF5722)],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFFFE0CC),
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFFFF5722),
              size: 22,
            ),

            const SizedBox(width: 8),

            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF6B5548),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QUANTITY BUTTON
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0E3),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE0CC)),
          ),
          child: Icon(icon, color: const Color(0xFFFF5722), size: 22),
        ),
      ),
    );
  }
}
