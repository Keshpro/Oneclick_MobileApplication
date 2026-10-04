import 'package:flutter/material.dart';

import 'food_seller_dashboard_screen.dart';

class FoodAdminSellerApplicationsScreen extends StatelessWidget {
  const FoodAdminSellerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Applications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ------------------------------------------------------------
          // APPLICATION 1
          // ------------------------------------------------------------

          _SellerApplicationCard(
            storeName: 'Cocos Bakery',
            ownerName: 'Dilni',
            businessType: 'Bakery',
            status: 'Under Review',
            onReview: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodSellerReviewScreen(
                    storeName: 'Cocos Bakery',
                    ownerName: 'Dilni',
                    businessType: 'Bakery',
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------------------
          // APPLICATION 2
          // ------------------------------------------------------------
          _SellerApplicationCard(
            storeName: 'Urban Bites',
            ownerName: 'Kamal',
            businessType: 'Restaurant',
            status: 'Under Review',
            onReview: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodSellerReviewScreen(
                    storeName: 'Urban Bites',
                    ownerName: 'Kamal',
                    businessType: 'Restaurant',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SELLER APPLICATION CARD
// ============================================================================

class _SellerApplicationCard extends StatelessWidget {
  final String storeName;
  final String ownerName;
  final String businessType;
  final String status;
  final VoidCallback onReview;

  const _SellerApplicationCard({
    required this.storeName,
    required this.ownerName,
    required this.businessType,
    required this.status,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store name
          Text(
            storeName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // Owner
          Text('Owner: $ownerName', style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 3),

          // Business type
          Text(
            'Business Type: $businessType',
            style: const TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              // Status icon
              const Icon(Icons.pending_rounded, color: Colors.orange, size: 20),

              const SizedBox(width: 6),

              // Status
              Text(
                status,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // Review button
              ElevatedButton(onPressed: onReview, child: const Text('Review')),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SELLER REVIEW SCREEN
// ============================================================================

class FoodSellerReviewScreen extends StatelessWidget {
  final String storeName;
  final String ownerName;
  final String businessType;

  const FoodSellerReviewScreen({
    super.key,
    required this.storeName,
    required this.ownerName,
    required this.businessType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Seller')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------------------------------------
            // SELLER INFORMATION
            // ------------------------------------------------------------

            const Text(
              'Seller Information',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _InfoRow(label: 'Store Name', value: storeName),

            _InfoRow(label: 'Owner', value: ownerName),

            _InfoRow(label: 'Business Type', value: businessType),

            const SizedBox(height: 25),

            // ------------------------------------------------------------
            // DOCUMENTS
            // ------------------------------------------------------------
            const Text(
              'Submitted Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _DocumentItem(
              title: 'Identity Document',
              icon: Icons.badge_outlined,
            ),

            _DocumentItem(
              title: 'Business Registration',
              icon: Icons.business_outlined,
            ),

            _DocumentItem(
              title: 'Food / Business Permit',
              icon: Icons.description_outlined,
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------------------
            // APPROVE SELLER
            // ------------------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FoodSellerDashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Approve Seller',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------------------
            // REJECT SELLER
            // ------------------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showResultDialog(
                    context,
                    'Seller Rejected',
                    'The seller application has been rejected.',
                  );
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text(
                  'Reject Seller',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------------------
            // REQUEST CHANGES
            // ------------------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                onPressed: () {
                  _showResultDialog(
                    context,
                    'Changes Requested',
                    'The seller will need to provide additional information or documents.',
                  );
                },
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Request Changes'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Show result dialog
  void _showResultDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// INFORMATION ROW
// ============================================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DOCUMENT ITEM
// ============================================================================

class _DocumentItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DocumentItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          const Icon(Icons.visibility_outlined, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}
