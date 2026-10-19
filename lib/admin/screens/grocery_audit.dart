import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryAudit extends StatefulWidget {
  const GroceryAudit({super.key});

  @override
  State<GroceryAudit> createState() => _GroceryAuditState();
}

class _GroceryAuditState extends State<GroceryAudit> {
  final Set<String> _updatingIds = {};

  Future<void> _updateProductStatus(
    String productId,
    String status,
  ) async {
    if (_updatingIds.contains(productId)) return;

    setState(() => _updatingIds.add(productId));

    try {
      await FirebaseFirestore.instance
          .collection('grocery_products')
          .doc(productId)
          .update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'active'
                ? 'Grocery product approved'
                : 'Grocery product rejected',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingIds.remove(productId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 4 - Grocery Items Audit'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('grocery_products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load grocery products'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(
              child: Text('No grocery products available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final doc = items[index];
              final item = doc.data();

              final status =
                  (item['status'] ?? 'pending').toString();

              final price =
                  (item['price'] as num?)?.toDouble() ?? 0.0;

              final isUpdating = _updatingIds.contains(doc.id);

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Item ${doc.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _status(status),
                        ],
                      ),
                      const Divider(),
                      Text(
                        'Seller: ${item['sellerName'] ?? 'Unknown Seller'}',
                      ),
                      Text(
                        'Item: ${item['name'] ?? 'Unknown Product'}',
                      ),
                      Text(
                        'Category: ${item['category'] ?? 'Unknown'}',
                      ),
                      Text('Price: Rs. ${price.toStringAsFixed(2)}'),
                      const SizedBox(height: 15),
                      if (isUpdating)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  _updateProductStatus(
                                    doc.id,
                                    'rejected',
                                  ),
                              child: const Text(
                                'Reject',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () =>
                                  _updateProductStatus(
                                    doc.id,
                                    'active',
                                  ),
                              child: const Text('Approve'),
                            ),
                          ],
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

  Widget _status(String status) {
    final approved = status == 'active';
    final rejected = status == 'rejected';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: approved
            ? Colors.green.withValues(alpha: 0.15)
            : rejected
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        approved
            ? 'Approved'
            : rejected
                ? 'Rejected'
                : 'Pending',
        style: TextStyle(
          color: approved
              ? Colors.green
              : rejected
                  ? Colors.red
                  : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}