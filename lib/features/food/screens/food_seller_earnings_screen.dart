import 'package:flutter/material.dart';

class FoodSellerEarningsScreen extends StatelessWidget {
  const FoodSellerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),

      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // Total earnings
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(22),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Rs. 48,250',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 18,
                    ),

                    const SizedBox(width: 5),

                    const Text(
                      'Your completed sales',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: 'This Month',
                  value: 'Rs. 12,450',
                  icon: Icons.calendar_month_outlined,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  title: 'Orders',
                  value: '84',
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  title: 'Food Sold',
                  value: '127',
                  icon: Icons.restaurant_outlined,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  title: 'Avg. Order',
                  value: 'Rs. 575',
                  icon: Icons.analytics_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          _transaction(
            orderId: 'FC1024',
            food: 'Chocolate Cake × 2',
            amount: '+ Rs. 1,400',
          ),

          _transaction(
            orderId: 'FC1023',
            food: 'Bakery Surprise Box × 1',
            amount: '+ Rs. 450',
          ),

          _transaction(
            orderId: 'FC1022',
            food: 'Chicken Rice & Curry × 2',
            amount: '+ Rs. 780',
          ),

          _transaction(
            orderId: 'FC1021',
            food: 'Chocolate Brownies × 3',
            amount: '+ Rs. 900',
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
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
          Icon(icon, color: const Color(0xFF2E7D32), size: 27),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _transaction({
    required String orderId,
    required String food,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  orderId,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  food,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
