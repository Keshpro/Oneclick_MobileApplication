import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_product_screen.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);

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
          'Seller Dashboard',
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
              // Welcome banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF175C38),
                      Color(0xFF2E8B57),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: Color(0xFF439667),
                      child: Icon(
                        Icons.storefront_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'YOUR GROCERY SHOP',
                      style: TextStyle(
                        color: Color(0xFFCDEBD5),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome, Seller!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Manage your products and keep your '
                      'customer orders moving.',
                      style: TextStyle(
                        color: Color(0xFFE1F2E5),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
                            const SizedBox(height: 24),

              const _SellerStats(),
              const SizedBox(height: 28),

              const Text(
                'Manage your shop',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Everything you need, in one place.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),

              _dashboardCard(
                title: 'Add Product',
                subtitle: 'Add something new to your shop',
                icon: Icons.add_box_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddProductScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _dashboardCard(
                title: 'Manage Products',
                subtitle: 'Review your listings, prices and stock',
                icon: Icons.inventory_2_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageProductsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              _dashboardCard(
                title: 'Manage Orders',
                subtitle: 'View orders and update their progress',
                icon: Icons.receipt_long_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageOrdersScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE3EADF),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F2E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: _green,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: _green,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _SellerStats extends StatefulWidget {
  const _SellerStats();

  @override
  State<_SellerStats> createState() => _SellerStatsState();
}

class _SellerStatsState extends State<_SellerStats> {
  static const int _lowStockLimit = 5;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _ordersStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _productsStream;
  String? _uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _uid = user.uid;
    _ordersStream = FirebaseFirestore.instance
        .collection('grocery_orders')
        .snapshots();
    _productsStream = FirebaseFirestore.instance
        .collection('grocery_products')
        .where('sellerId', isEqualTo: user.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null || _ordersStream == null || _productsStream == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _ordersStream,
      builder: (context, orderSnap) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _productsStream,
          builder: (context, productSnap) {
            if (orderSnap.hasError || productSnap.hasError) {
              return Text(
                'Unable to load statistics: '
                '${orderSnap.error ?? productSnap.error}',
                style: const TextStyle(color: Color(0xFFB83D3D)),
              );
            }

            final loading = !orderSnap.hasData || !productSnap.hasData;

            double totalSales = 0;
            int pending = 0;
            int completed = 0;
            int lowStock = 0;

            if (!loading) {
              for (final doc in orderSnap.data!.docs) {
                final data = doc.data();
                final items = (data['items'] as List? ?? [])
                    .whereType<Map>()
                    .where((item) => item['sellerId'] == uid)
                    .toList();
                if (items.isEmpty) continue;

                final statuses =
                    data['sellerStatuses'] as Map<String, dynamic>? ?? {};
                final status =
                    (statuses[uid] ?? 'pending').toString().toLowerCase();

                if (status == 'pending') pending++;
                if (status == 'completed') {
                  completed++;
                  for (final item in items) {
                    totalSales +=
                        (item['totalPrice'] as num?)?.toDouble() ?? 0;
                  }
                }
              }

              for (final doc in productSnap.data!.docs) {
                final stock = (doc.data()['stock'] as num?)?.toInt() ?? 0;
                if (stock <= _lowStockLimit) lowStock++;
              }
            }

            String v(String value) => loading ? '...' : value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Shop overview',
                  style: TextStyle(
                    color: SellerDashboard._textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        Icons.payments_outlined,
                        'Total Sales',
                        v('Rs. ${totalSales.toStringAsFixed(2)}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        Icons.hourglass_empty_rounded,
                        'Pending Orders',
                        v('$pending'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        Icons.check_circle_outline_rounded,
                        'Completed Orders',
                        v('$completed'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        Icons.warning_amber_rounded,
                        'Low Stock Products',
                        v('$lowStock'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3EADF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: SellerDashboard._green, size: 24),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: SellerDashboard._textColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: SellerDashboard._muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}