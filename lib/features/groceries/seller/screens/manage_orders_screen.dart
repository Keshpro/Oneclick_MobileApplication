
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});
  Future<void> _updateOrderStatus(
  BuildContext context,
  String orderId,
  String newStatus,
) async {
  try {
    await FirebaseFirestore.instance
        .collection('grocery_orders')
        .doc(orderId)
        .update({
      'status': newStatus,
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order updated to $newStatus')),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update order: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: user == null
          ? const Center(child: Text('Please log in first'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('grocery_orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load orders: ${snapshot.error}',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final orders = snapshot.data!.docs.where((doc) {
                  final items = doc.data()['items'] as List? ?? [];

                  return items.any((item) {
                    return item is Map &&
                        item['sellerId'] == user.uid;
                  });
                }).toList();

                if (orders.isEmpty) {
                  return const Center(
                    child: Text('No customer orders yet'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final data = doc.data();

                    final items = (data['items'] as List?)
                            ?.whereType<Map>()
                            .where(
                              (item) =>
                                  item['sellerId'] == user.uid,
                            )
                            .toList() ??
                        [];

                    final sellerTotal = items.fold<double>(
  0,
  (total, item) =>
      total +
      ((item['totalPrice'] as num?)?.toDouble() ?? 0),
);
                    final status =
                        (data['status'] ?? 'pending').toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order: ${doc.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Customer ID: ${data['customerId'] ?? ''}',
                            ),
                            const SizedBox(height: 8),
                            ...items.map(
                              (item) => Text(
                                '${item['name']} × ${item['quantity']}',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total: Rs. ${sellerTotal.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Status: ${status.toUpperCase()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),

DropdownButton<String>(
  value: ['pending', 'processing', 'completed']
          .contains(status.toLowerCase())
      ? status.toLowerCase()
      : null,
  hint: const Text('Change Status'),
  isExpanded: true,
  items: const [
    DropdownMenuItem(
      value: 'pending',
      child: Text('Pending'),
    ),
    DropdownMenuItem(
      value: 'processing',
      child: Text('Processing'),
    ),
    DropdownMenuItem(
      value: 'completed',
      child: Text('Completed'),
    ),
  ],
  onChanged: (newStatus) {
    if (newStatus != null && newStatus != status.toLowerCase()) {
      _updateOrderStatus(context, doc.id, newStatus);
    }
  },
),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
