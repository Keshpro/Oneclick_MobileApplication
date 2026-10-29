import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/grocery_controller.dart';

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
    Widget _timeline(String status) {
    final s = status.toLowerCase();

    if (s == 'cancelled' || s == 'rejected') {
      return const Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Color(0xFFB83D3D),
            size: 18,
          ),
          SizedBox(width: 6),
          Text(
            'Order cancelled',
            style: TextStyle(
              color: Color(0xFFB83D3D),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    const steps = ['pending', 'processing', 'completed'];
    const labels = ['Pending', 'Processing', 'Completed'];
    final found = steps.indexOf(s);
    final current = found < 0 ? 0 : found;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                i <= current
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: i <= current
                    ? _green
                    : const Color(0xFFB8C4B8),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 10,
                  color: i <= current
                      ? _textColor
                      : const Color(0xFF748074),
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(
                  bottom: 16,
                  left: 4,
                  right: 4,
                ),
                color: i < current
                    ? _green
                    : const Color(0xFFE3EADF),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    String orderId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text(
          'The items will be returned to stock. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB83D3D),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final error = await GroceryController.cancelOrder(orderId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Order cancelled. Stock restored.'),
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
                      final sellerStatuses =
                          (data['sellerStatuses'] as Map?) ?? {};
                      final sellerItems = <String, List<Map>>{};
                      for (final item in items) {
                        final sellerId =
                            (item['sellerId'] ?? '').toString();
                        sellerItems.putIfAbsent(sellerId, () => []).add(item);
                      }


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
                                                final canCancel =
                          status.toLowerCase() != 'cancelled' &&
                              sellerItems.keys.every((id) =>
                                  (sellerStatuses[id] ?? 'pending')
                                      .toString()
                                      .toLowerCase() ==
                                  'pending');

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
                                    'ORDER: ${status.toUpperCase()}',
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
                            ...sellerItems.entries.map((entry) {
                              final sellerId = entry.key;
                              final sellerStatus =
                                  (sellerStatuses[sellerId] ?? status)
                                      .toString();
                              final sellerColor =
                                  _statusColor(sellerStatus);
                              final sellerName =
                                  (entry.value.first['sellerName'] ?? '')
                                      .toString().trim();
                              final sellerTotal = entry.value.fold<double>(
                                0,
                                (total, item) =>
                                    total +
                                    ((item['totalPrice'] as num?)
                                            ?.toDouble() ??
                                        0),
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _background,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE3EADF),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          sellerName.isNotEmpty
                                              ? sellerName
                                              : 'Grocery Seller',
                                          style: const TextStyle(
                                            color: _textColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: sellerColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            sellerStatus.toUpperCase(),
                                            style: TextStyle(
                                              color: sellerColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                                                        _timeline(sellerStatus),
                                    const SizedBox(height: 12),
                                    ...entry.value.map((item) {
                                      final name =
                                          (item['name'] ?? 'Product')
                                              .toString();
                                      final quantity =
                                          (item['quantity'] ?? 0).toString();
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Text(
                                          '$name × $quantity',
                                          style: const TextStyle(
                                            color: _textColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }),
                                    Text(
                                      'Seller subtotal: Rs. ${sellerTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: _green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
                                                        if (canCancel) ...[
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      const Color(0xFFB83D3D),
                                  side: const BorderSide(
                                    color: Color(0xFFB83D3D),
                                  ),
                                  minimumSize:
                                      const Size(double.infinity, 46),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () =>
                                    _confirmCancel(context, doc.id),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel Order'),
                              ),
                            ],
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