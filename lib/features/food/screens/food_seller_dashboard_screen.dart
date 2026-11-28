import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/food_seller_data_service.dart';
import 'food_add_surplus_screen.dart';
import 'food_my_offers_screen.dart';
import 'food_seller_orders_screen.dart';
import 'food_store_profile_screen.dart';
import 'food_seller_earnings_screen.dart';
import '../../auth/screens/home_screen.dart';

class FoodSellerDashboardScreen extends StatefulWidget {
  const FoodSellerDashboardScreen({super.key});

  @override
  State<FoodSellerDashboardScreen> createState() =>
      _FoodSellerDashboardScreenState();
}

class _FoodSellerDashboardScreenState extends State<FoodSellerDashboardScreen> {
  final sellerData = FoodSellerDataService.instance;

  // ------------------------------------------------------------
  // THEME COLORS
  // ------------------------------------------------------------

  static const Color primary = Color(0xFF087E8B);
  static const Color primaryDark = Color(0xFF075B63);
  static const Color accentGreen = Color(0xFF2E9D68);
  static const Color background = Color(0xFFF5F8F7);
  static const Color textDark = Color(0xFF183B40);
  static const Color textMuted = Color(0xFF75888A);
  static const Color cardColor = Colors.white;

  Future<bool> _isApprovedSeller() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    final sellerDoc = await FirebaseFirestore.instance
        .collection('food_sellers')
        .doc(user.uid)
        .get();

    if (!sellerDoc.exists) return false;

    final data = sellerDoc.data();

    final isApproved =
        data?['uid'] == user.uid &&
        data?['role'] == 'foodSeller' &&
        data?['status']?.toString().toLowerCase() == 'active';

    if (isApproved) {
      await FoodSellerDataService.instance.loadStoreProfile();
      await FoodSellerDataService.instance.loadOffers();
    }

    return isApproved;
  }

  Future<bool>? _approvalCheck;

  void refreshDashboard() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _approvalCheck ??= _isApprovedSeller(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: background,
            body: Center(child: CircularProgressIndicator(color: primary)),
          );
        }

        if (snapshot.hasError || snapshot.data != true) {
          return Scaffold(
            backgroundColor: background,
            appBar: AppBar(title: const Text('Seller Access')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Seller Access Restricted',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your seller account is not approved or active. '
                      'Please contact the administrator.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Return to Customer Mode'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _buildSellerDashboard();
      },
    );
  }

  // ------------------------------------------------------------
  // DASHBOARD
  // ------------------------------------------------------------

  Widget _buildSellerDashboard() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in again.')));
    }

    final activeOffers = sellerData.offers
        .where((offer) => offer.status == 'ACTIVE')
        .length;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('food_orders')
          .where('sellerUids', arrayContains: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: background,
            appBar: AppBar(title: const Text('Food Seller Dashboard')),
            body: Center(
              child: Text(
                'Failed to load dashboard statistics: ${snapshot.error}',
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: background,
            body: Center(child: CircularProgressIndicator(color: primary)),
          );
        }

        final orderDocs = snapshot.data?.docs ?? [];

        final totalOrders = orderDocs.length;

        double totalEarnings = 0;
        int foodSold = 0;

        for (final doc in orderDocs) {
          final data = doc.data();

          final rawItems = data['items'] as List<dynamic>? ?? [];

          final sellerItems = rawItems.where((rawItem) {
            final item = Map<String, dynamic>.from(rawItem as Map);
            return item['sellerUid'] == uid;
          });

          final sellerStatuses = Map<String, dynamic>.from(
            data['sellerStatuses'] ?? {},
          );

          final sellerStatus =
              sellerStatuses[uid]?.toString() ??
              data['status']?.toString() ??
              'orderPlaced';

          final isCompleted =
              sellerStatus == 'delivered' || sellerStatus == 'completed';

          if (!isCompleted) continue;

          for (final rawItem in sellerItems) {
            final item = Map<String, dynamic>.from(rawItem as Map);

            final price = (item['price'] as num?)?.toDouble() ?? 0;
            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

            totalEarnings += price * quantity;
            foodSold += quantity;
          }
        }

        return Scaffold(
          backgroundColor: background,

          // ------------------------------------------------------------
          // APP BAR
          // ------------------------------------------------------------
          appBar: AppBar(
            elevation: 0,
            backgroundColor: primary,
            foregroundColor: Colors.white,
            centerTitle: false,
            title: const Text(
              'Seller Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 19,
                letterSpacing: 0.2,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                  label: const Text(
                    'Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ------------------------------------------------------------
          // BODY
          // ------------------------------------------------------------
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------------
                // WELCOME BANNER
                // ------------------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF087E8B),
                        Color(0xFF159B82),
                        Color(0xFF2E9D68),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        top: -15,
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 110,
                          color: Colors.white.withOpacity(0.10),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'SELLER SPACE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Welcome back 👋',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            sellerData.storeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Color(0xFFCCF6D7),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Your store is ready to serve!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ------------------------------------------------------------
                // OVERVIEW HEADER
                // ------------------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F3EF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            size: 14,
                            color: primary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Live stats',
                            style: TextStyle(
                              fontSize: 11,
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ------------------------------------------------------------
                // STATISTICS
                // ------------------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.restaurant_menu_rounded,
                        title: 'Active Offers',
                        value: activeOffers.toString(),
                        color: const Color(0xFFF29B38),
                        backgroundTint: const Color(0xFFFFF3E4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.shopping_bag_rounded,
                        title: 'Orders',
                        value: totalOrders.toString(),
                        color: const Color(0xFF4B8DE5),
                        backgroundTint: const Color(0xFFEAF2FF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Earnings',
                        value: 'Rs. ${totalEarnings.toStringAsFixed(0)}',
                        color: const Color(0xFF2E9D68),
                        backgroundTint: const Color(0xFFE7F7ED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.eco_rounded,
                        title: 'Food Saved',
                        value: foodSold.toString(),
                        color: const Color(0xFF0C9A91),
                        backgroundTint: const Color(0xFFE3F6F3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ------------------------------------------------------------
                // FOOD SAVER PROMOTION
                // ------------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8ED),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFE5BD),
                      width: 1,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8C9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: Color(0xFFEA8A26),
                          size: 26,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Have surplus food?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Turn your extra food into an opportunity! '
                        'Offer discounted meals and help reduce food waste.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FoodAddSurplusScreen(),
                              ),
                            );

                            refreshDashboard();
                          },

                          icon: const Icon(Icons.add_circle_outline_rounded),

                          label: const Text(
                            'Create Food Saver Offer',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ------------------------------------------------------------
                // MANAGE STORE HEADER
                // ------------------------------------------------------------
                const Text(
                  'Manage Your Store',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Everything you need to run your store',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),

                const SizedBox(height: 16),

                // ------------------------------------------------------------
                // STORE OPTIONS
                // ------------------------------------------------------------
                _DashboardOption(
                  icon: Icons.fastfood_rounded,
                  title: 'My Offers',
                  subtitle: 'View and manage your Food Saver offers',
                  iconColor: const Color(0xFFF29B38),
                  iconBackground: const Color(0xFFFFF3E4),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodMyOffersScreen(),
                      ),
                    );

                    refreshDashboard();
                  },
                ),

                _DashboardOption(
                  icon: Icons.receipt_long_rounded,
                  title: 'Orders',
                  subtitle: 'View and manage customer orders',
                  iconColor: const Color(0xFF4B8DE5),
                  iconBackground: const Color(0xFFEAF2FF),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodSellerOrdersScreen(),
                      ),
                    );

                    refreshDashboard();
                  },
                ),

                _DashboardOption(
                  icon: Icons.store_rounded,
                  title: 'Store Profile',
                  subtitle: 'Manage your business information',
                  iconColor: primary,
                  iconBackground: const Color(0xFFE3F6F3),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodStoreProfileScreen(),
                      ),
                    );

                    refreshDashboard();
                  },
                ),

                _DashboardOption(
                  icon: Icons.payments_rounded,
                  title: 'Earnings',
                  subtitle: 'View your sales and earnings',
                  iconColor: const Color(0xFF2E9D68),
                  iconBackground: const Color(0xFFE7F7ED),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FoodSellerEarningsScreen(),
                      ),
                    );

                    refreshDashboard();
                  },
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// STATISTICS CARD
// ------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color backgroundTint;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.backgroundTint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF1F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: backgroundTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(height: 14),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF183B40),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF75888A),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// DASHBOARD OPTION
// ------------------------------------------------------------

class _DashboardOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconBackground;

  const _DashboardOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF1F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),

        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: iconColor, size: 23),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF183B40),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF75888A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF087E8B),
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
