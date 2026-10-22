
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Please log in first'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('grocery_orders')
                  .where('customerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load orders: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final orders = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aDate = a.data()['orderDate'];
                    final bDate = b.data()['orderDate'];

                    if (aDate is! Timestamp) return 1;
                    if (bDate is! Timestamp) return -1;

                    return bDate.compareTo(aDate);
                  });

                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your grocery orders will appear here.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
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
                            .toList() ??
                        [];

                    final total =
                        (data['totalAmount'] as num?)?.toDouble() ??
                            0.0;

                    final status =
                        (data['status'] ?? 'pending').toString();

                    final date = data['orderDate'] is Timestamp
                        ? (data['orderDate'] as Timestamp).toDate()
                        : null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${doc.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: ${status.toUpperCase()}',
                            ),
                            if (date != null)
                              Text(
                                'Date: ${date.day}/${date.month}/${date.year}',
                              ),
                            const Divider(),
                            ...items.map((item) {
                              final name =
                                  (item['name'] ?? 'Product').toString();
                              final quantity =
                                  (item['quantity'] ?? 0).toString();

                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4),
                                child: Text('$name × $quantity'),
                              );
                            }),
                            const SizedBox(height: 8),
                            Text(
                              'Total: Rs. ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
