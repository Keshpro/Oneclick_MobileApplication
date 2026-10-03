import 'package:flutter/material.dart';

import '../services/food_seller_data_service.dart';
import 'food_add_surplus_screen.dart';
import 'food_my_offers_screen.dart';
import 'food_seller_orders_screen.dart';
import 'food_store_profile_screen.dart';
import 'food_seller_earnings_screen.dart';

class FoodSellerDashboardScreen extends StatefulWidget {
  const FoodSellerDashboardScreen({super.key});

  @override
  State<FoodSellerDashboardScreen> createState() =>
      _FoodSellerDashboardScreenState();
}

class _FoodSellerDashboardScreenState extends State<FoodSellerDashboardScreen> {
  final sellerData = FoodSellerDataService.instance;

  // ------------------------------------------------------------
  // REFRESH DASHBOARD
  // ------------------------------------------------------------

  void refreshDashboard() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Count active offers
    final activeOffers = sellerData.offers
        .where((offer) => offer.status == 'ACTIVE')
        .length;

    // Count all orders
    final totalOrders = sellerData.orders.length;

    // Calculate completed earnings
    final totalEarnings = sellerData.totalEarnings;

    // Calculate completed food quantity
    final foodSaved = sellerData.foodSold;

    return Scaffold(
      appBar: AppBar(title: const Text('Food Seller Dashboard')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ------------------------------------------------------------
            // WELCOME SECTION
            // ------------------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Welcome back 👋',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 6),

                  // DYNAMIC STORE NAME
                  Text(
                    sellerData.storeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Your Food Seller account is ready.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ------------------------------------------------------------
            // OVERVIEW
            // ------------------------------------------------------------
            const Text(
              'Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            // ------------------------------------------------------------
            // STATISTICS - ROW 1
            // ------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Active Offers',
                    value: activeOffers.toString(),
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Orders',
                    value: totalOrders.toString(),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------------------
            // STATISTICS - ROW 2
            // ------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.attach_money_rounded,
                    title: 'Earnings',
                    value: 'Rs. ${totalEarnings.toStringAsFixed(0)}',
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatCard(
                    icon: Icons.eco_rounded,
                    title: 'Food Saved',
                    value: foodSaved.toString(),
                    color: Colors.teal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ------------------------------------------------------------
            // ADD SURPLUS FOOD
            // ------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade100),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.orange.shade700,
                    size: 32,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Have surplus food?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Create a discounted Food Saver offer and help reduce food waste.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 46,

                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FoodAddSurplusScreen(),
                          ),
                        );

                        refreshDashboard();
                      },

                      icon: const Icon(Icons.add),

                      label: const Text(
                        'Add Surplus Food',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ------------------------------------------------------------
            // MANAGE YOUR STORE
            // ------------------------------------------------------------
            const Text(
              'Manage Your Store',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            // ------------------------------------------------------------
            // MY OFFERS
            // ------------------------------------------------------------
            _DashboardOption(
              icon: Icons.restaurant_menu_rounded,
              title: 'My Offers',
              subtitle: 'View and manage your Food Saver offers',

              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodMyOffersScreen()),
                );

                refreshDashboard();
              },
            ),

            // ------------------------------------------------------------
            // ORDERS
            // ------------------------------------------------------------
            _DashboardOption(
              icon: Icons.shopping_bag_outlined,
              title: 'Orders',
              subtitle: 'View and manage customer orders',

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

            // ------------------------------------------------------------
            // STORE PROFILE
            // ------------------------------------------------------------
            _DashboardOption(
              icon: Icons.storefront_outlined,
              title: 'Store Profile',
              subtitle: 'Manage your business information',

              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoodStoreProfileScreen(),
                  ),
                );

                // Refresh dashboard after returning
                refreshDashboard();
              },
            ),

            // ------------------------------------------------------------
            // EARNINGS
            // ------------------------------------------------------------
            _DashboardOption(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Earnings',
              subtitle: 'View your sales and earnings',

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

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// STAT CARD
// ------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  const _DashboardOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

        leading: Icon(icon, color: Colors.green.shade700, size: 30),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}
