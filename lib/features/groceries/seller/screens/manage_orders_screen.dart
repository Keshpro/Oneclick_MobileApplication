import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);

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
        SnackBar(
          backgroundColor: _green,
          content: Text('Order updated to $newStatus'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
        ),
      );
    }
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();

    final Color color;
    final Color background;

    if (normalized == 'completed') {
      color = _green;
      background = const Color(0xFFE7F2E8);
    } else if (normalized == 'processing') {
      color = const Color(0xFF2868A6);
      background = const Color(0xFFEAF2FA);
    } else if (normalized == 'cancelled' ||
        normalized == 'rejected') {
      color = const Color(0xFFB83D3D);
      background = const Color(0xFFFBEDED);
    } else {
      color = const Color(0xFF946B17);
      background = const Color(0xFFFFF4DB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
              color: _green,
              size: 58,
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
                color: _muted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: _green,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Manage Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: user == null
            ? _message(
                Icons.login_rounded,
                'Please log in',
                'Log in to manage your customer orders.',
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('grocery_orders')
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

                  final orders = snapshot.data!.docs.where((doc) {
                    final items =
                        doc.data()['items'] as List? ?? [];

                    return items.any((item) {
                      return item is Map &&
                          item['sellerId'] == user.uid;
                    });
                  }).toList();

                  if (orders.isEmpty) {
                    return _message(
                      Icons.receipt_long_outlined,
                      'No customer orders yet',
                      'Orders containing your products '
                          'will appear here.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      28,
                    ),
                    itemCount: orders.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F2E8),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                color: _green,
                                size: 32,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your customer orders',
                                      style: TextStyle(
                                        color: _textColor,
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${orders.length} '
                                      '${orders.length == 1 ? 'order' : 'orders'}'
                                      ' in your shop',
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final doc = orders[index - 1];
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
                            ((item['totalPrice'] as num?)
                                    ?.toDouble() ??
                                0),
                      );

                      final status =
                          (data['status'] ?? 'pending').toString();

                      final normalizedStatus =
                          status.toLowerCase();

                      final shortId = doc.id.length > 8
                          ? doc.id.substring(0, 8)
                          : doc.id;

                      final orderDate = data['orderDate'];
                      final date = orderDate is Timestamp
                          ? orderDate.toDate()
                          : null;

                      final deliveryMethod =
                          (data['deliveryMethod'] ?? '').toString();

                      final address =
                          (data['deliveryAddress'] ?? '').toString();

                      final paymentMethod =
                          (data['paymentMethod'] ?? '').toString();

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE3EADF),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            // Order heading
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
                                _statusBadge(status),
                              ],
                            ),
                            if (date != null)
                              _detailRow(
                                Icons.calendar_today_outlined,
                                '${date.day}/${date.month}/${date.year}',
                              ),
                            _detailRow(
                              Icons.person_outline_rounded,
                              'Customer ID: '
                              '${data['customerId'] ?? ''}',
                            ),
                            const Divider(
                              height: 28,
                              color: Color(0xFFE3EADF),
                            ),

                            // Seller's order items
                            ...items.map((item) {
                              final name =
                                  (item['name'] ?? 'Product')
                                      .toString();

                              final quantity =
                                  (item['quantity'] ?? 0)
                                      .toString();

                              final total =
                                  (item['totalPrice'] as num?)
                                          ?.toDouble() ??
                                      0;

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        '$name × $quantity',
                                        style: const TextStyle(
                                          color: _textColor,
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        'Rs. ${total.toStringAsFixed(2)}',
                                        textAlign:
                                            TextAlign.right,
                                        style: const TextStyle(
                                          color: _green,
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Delivery and payment
                            if (deliveryMethod.isNotEmpty)
                              _detailRow(
                                Icons.local_shipping_outlined,
                                deliveryMethod == 'pickup'
                                    ? 'Store Pickup'
                                    : 'Home Delivery',
                              ),
                            if (deliveryMethod == 'delivery' &&
                                address.trim().isNotEmpty)
                              _detailRow(
                                Icons.location_on_outlined,
                                address,
                              ),
                            if (paymentMethod.isNotEmpty)
                              _detailRow(
                                Icons.payments_outlined,
                                paymentMethod,
                              ),
                            const Divider(
                              height: 28,
                              color: Color(0xFFE3EADF),
                            ),

                            // Seller total
                            Wrap(
                              alignment:
                                  WrapAlignment.spaceBetween,
                              crossAxisAlignment:
                                  WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                const Text(
                                  'Your items total',
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Rs. ${sellerTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: _green,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Order status control
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _background,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      const Color(0xFFE3EADF),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: const [
                                    'pending',
                                    'processing',
                                    'completed',
                                  ].contains(normalizedStatus)
                                      ? normalizedStatus
                                      : null,
                                  hint: const Text(
                                    'Change Status',
                                  ),
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _green,
                                  ),
                                  style: const TextStyle(
                                    color: _textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                    if (newStatus != null &&
                                        newStatus !=
                                            normalizedStatus) {
                                      _updateOrderStatus(
                                        context,
                                        doc.id,
                                        newStatus,
                                      );
                                    }
                                  },
                                ),
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