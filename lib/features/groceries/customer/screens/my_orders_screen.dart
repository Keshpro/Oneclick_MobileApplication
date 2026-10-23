import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _green;
      case 'processing':
        return const Color(0xFF2868A6);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFB83D3D);
      default:
        return const Color(0xFF946B17);
    }
  }

  Widget _message(
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: _green,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textColor,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF748074),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _background,
        foregroundColor: _textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: user == null
            ? _message(
                Icons.login_rounded,
                'Please log in',
                'Log in to view your grocery orders.',
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('grocery_orders')
                    .where('customerId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _message(
                      Icons.error_outline_rounded,
                      'Unable to load orders',
                      '${snapshot.error}',
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _green,
                      ),
                    );
                  }

                  final orders = snapshot.data!.docs.toList()
                    ..sort((a, b) {
                      final aDate = a.data()['orderDate'];
                      final bDate = b.data()['orderDate'];

                      final aTime = aDate is Timestamp
                          ? aDate.millisecondsSinceEpoch
                          : 0;

                      final bTime = bDate is Timestamp
                          ? bDate.millisecondsSinceEpoch
                          : 0;

                      return bTime.compareTo(aTime);
                    });

                  if (orders.isEmpty) {
                    return _message(
                      Icons.shopping_bag_outlined,
                      'No orders yet',
                      'Your grocery orders will appear here.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 14),
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

                      final statusColor = _statusColor(status);

                      final orderDate = data['orderDate'];
                      final date = orderDate is Timestamp
                          ? orderDate.toDate()
                          : null;

                      final shortId = doc.id.length > 8
                          ? doc.id.substring(0, 8)
                          : doc.id;

                      final deliveryMethod =
                          (data['deliveryMethod'] ?? '').toString();

                      final paymentMethod =
                          (data['paymentMethod'] ?? '').toString();

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE3EADF),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              alignment:
                                  WrapAlignment.spaceBetween,
                              crossAxisAlignment:
                                  WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                Text(
                                  'Order #$shortId',
                                  style: const TextStyle(
                                    color: _textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (date != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(
                                  color: Color(0xFF748074),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const Divider(
                              height: 28,
                              color: Color(0xFFE3EADF),
                            ),
                            ...items.map((item) {
                              final name =
                                  (item['name'] ?? 'Product')
                                      .toString();

                              final quantity =
                                  (item['quantity'] ?? 0).toString();

                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '$name × $quantity',
                                  style: const TextStyle(
                                    color: _textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            if (deliveryMethod.isNotEmpty)
                              Text(
                                deliveryMethod == 'pickup'
                                    ? 'Store Pickup'
                                    : 'Home Delivery',
                                style: const TextStyle(
                                  color: Color(0xFF748074),
                                  fontSize: 12,
                                ),
                              ),
                            if (paymentMethod.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                paymentMethod,
                                style: const TextStyle(
                                  color: Color(0xFF748074),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Text(
                              'Total: Rs. ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: _green,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}