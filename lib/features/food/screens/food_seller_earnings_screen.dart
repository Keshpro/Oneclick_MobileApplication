import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodSellerEarningsScreen extends StatelessWidget {
  const FoodSellerEarningsScreen({super.key});

  static const Color primary = Color(0xFF087E8B);
  static const Color background = Color(0xFFF5F8F7);
  static const Color textDark = Color(0xFF183B40);
  static const Color textMuted = Color(0xFF75888A);
  static const Color green = Color(0xFF2E9D68);

  String _formatCurrency(double value) {
    return 'Rs. ${value.toStringAsFixed(0)}';
  }

  DateTime? _getDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in again.')));
    }

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        title: const Text(
          'Earnings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('food_orders')
            .where('sellerUids', arrayContains: uid)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load earnings.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          final completedOrders = <Map<String, dynamic>>[];

          double totalEarnings = 0;
          double monthlyEarnings = 0;
          int foodSold = 0;

          final now = DateTime.now();

          for (final doc in docs) {
            final data = doc.data();

            final sellerStatuses = Map<String, dynamic>.from(
              data['sellerStatuses'] ?? {},
            );

            final sellerStatus =
                sellerStatuses[uid]?.toString() ??
                data['status']?.toString() ??
                'orderPlaced';

            if (sellerStatus != 'delivered' && sellerStatus != 'completed') {
              continue;
            }

            final rawItems = data['items'] as List<dynamic>? ?? [];

            final sellerItems = rawItems
                .where((rawItem) {
                  final item = Map<String, dynamic>.from(rawItem as Map);
                  return item['sellerUid'] == uid;
                })
                .map((rawItem) {
                  return Map<String, dynamic>.from(rawItem as Map);
                })
                .toList();

            if (sellerItems.isEmpty) continue;

            double orderEarnings = 0;
            int orderQuantity = 0;

            for (final item in sellerItems) {
              final price = (item['price'] as num?)?.toDouble() ?? 0;
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;

              orderEarnings += price * quantity;
              orderQuantity += quantity;
            }

            if (orderEarnings <= 0) continue;

            totalEarnings += orderEarnings;
            foodSold += orderQuantity;

            final placedAt = _getDate(data['placedAt']);

            if (placedAt != null &&
                placedAt.year == now.year &&
                placedAt.month == now.month) {
              monthlyEarnings += orderEarnings;
            }

            completedOrders.add({
              'id': doc.id,
              'items': sellerItems,
              'amount': orderEarnings,
              'quantity': orderQuantity,
              'date': placedAt,
            });
          }

          completedOrders.sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA);
          });

          final completedOrderCount = completedOrders.length;

          final averageOrder = completedOrderCount > 0
              ? totalEarnings / completedOrderCount
              : 0.0;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

            children: [
              // ------------------------------------------------------------
              // TOTAL EARNINGS
              // ------------------------------------------------------------

              Container(
                padding: const EdgeInsets.all(24),
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
                      right: -8,
                      top: -10,
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 100,
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
                            'YOUR SALES',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Total Earnings',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _formatCurrency(totalEarnings),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFFCCF6D7),
                              size: 17,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '$completedOrderCount completed orders',
                              style: const TextStyle(
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

              const SizedBox(height: 26),

              // ------------------------------------------------------------
              // STATISTICS
              // ------------------------------------------------------------
              const Text(
                'Earnings Overview',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'This Month',
                      value: _formatCurrency(monthlyEarnings),
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFF4B8DE5),
                      tint: const Color(0xFFEAF2FF),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _StatCard(
                      title: 'Orders',
                      value: completedOrderCount.toString(),
                      icon: Icons.shopping_bag_rounded,
                      color: const Color(0xFFF29B38),
                      tint: const Color(0xFFFFF3E4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Food Sold',
                      value: foodSold.toString(),
                      icon: Icons.eco_rounded,
                      color: const Color(0xFF2E9D68),
                      tint: const Color(0xFFE7F7ED),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _StatCard(
                      title: 'Avg. Order',
                      value: _formatCurrency(averageOrder),
                      icon: Icons.analytics_rounded,
                      color: primary,
                      tint: const Color(0xFFE3F6F3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------------------
              // TRANSACTIONS
              // ------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
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
                    child: Text(
                      '$completedOrderCount orders',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (completedOrders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFEDF1F0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F6F3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 32,
                          color: primary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'No completed sales yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Your completed orders and earnings '
                        'will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...completedOrders.map((order) {
                  final items = order['items'] as List<Map<String, dynamic>>;

                  final foodNames = items
                      .map((item) {
                        final name =
                            item['foodName']?.toString() ?? 'Food item';

                        final quantity =
                            (item['quantity'] as num?)?.toInt() ?? 0;

                        return '$name × $quantity';
                      })
                      .join(', ');

                  final date = order['date'] as DateTime?;

                  return _TransactionCard(
                    orderId: order['id'].toString(),
                    food: foodNames,
                    amount: _formatCurrency(
                      (order['amount'] as num).toDouble(),
                    ),
                    date: date,
                  );
                }),

              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------
// STAT CARD
// ------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color tint;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF1F0)),
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
              color: tint,
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
              fontSize: 19,
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
// TRANSACTION CARD
// ------------------------------------------------------------

class _TransactionCard extends StatelessWidget {
  final String orderId;
  final String food;
  final String amount;
  final DateTime? date;

  const _TransactionCard({
    required this.orderId,
    required this.food,
    required this.amount,
    required this.date,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF1F0)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE7F7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Color(0xFF2E9D68),
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF183B40),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  food,
                  style: const TextStyle(
                    color: Color(0xFF75888A),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    color: Color(0xFF9AA8A8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF2E9D68),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
