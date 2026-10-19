import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});
  Future<void> _deleteProduct(
  BuildContext context,
  String productId,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Product'),
      content: const Text(
        'Are you sure you want to delete this product?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  try {
    final productRef = FirebaseFirestore.instance
        .collection('grocery_products')
        .doc(productId);

    final product = await productRef.get();

    if (product.data()?['sellerId'] != user.uid) {
      throw Exception('You cannot delete this product');
    }

    await productRef.delete();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully')),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete failed: $e')),
    );
  }
}
Future<void> _editProduct(
  BuildContext context,
  String productId,
  Map<String, dynamic> product,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final priceController = TextEditingController(
    text: '${product['price'] ?? 0}',
  );
  final stockController = TextEditingController(
    text: '${product['stock'] ?? 0}',
  );
  final descriptionController = TextEditingController(
    text: '${product['description'] ?? ''}',
  );

  try {
    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (Rs.)',
                ),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text.trim());
              final stock = int.tryParse(stockController.text.trim());

              if (price == null || price <= 0 ||
                  stock == null || stock < 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Enter valid price and stock'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (save != true || !context.mounted) return;

    final productRef = FirebaseFirestore.instance
        .collection('grocery_products')
        .doc(productId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(productRef);

      if (!snapshot.exists ||
          snapshot.data()?['sellerId'] != user.uid) {
        throw Exception('Product not found or access denied');
      }

      transaction.update(productRef, {
        'description': descriptionController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'stock': int.parse(stockController.text.trim()),
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product submitted for approval'),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update failed: $e')),
    );
  } finally {
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
  }
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Products')),
        body: const Center(
          child: Text('Please log in to manage products'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('grocery_products')
            .where('sellerId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load products'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final products = snapshot.data!.docs;

          if (products.isEmpty) {
            return const Center(
              child: Text('No products added yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final product = productDoc.data();

              final name = (product['name'] ?? 'Unnamed Product')
                  .toString();

              final price =
                  (product['price'] as num?)?.toDouble() ?? 0.0;

              final stock =
                  (product['stock'] as num?)?.toInt() ?? 0;

              final status =
                  (product['status'] ?? 'pending').toString();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.shopping_basket),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Rs. ${price.toStringAsFixed(2)}\n'
                    'Stock: $stock\n'
                    'Status: $status',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
  _editProduct(context, productDoc.id, product);
}

                      if (value == 'delete') {
  _deleteProduct(context, productDoc.id);
}
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
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