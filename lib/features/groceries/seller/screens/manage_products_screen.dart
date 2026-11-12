import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);
  static const _red = Color(0xFFB83D3D);

  Future<void> _deleteProduct(
    BuildContext context,
    String productId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: _red,
          size: 36,
        ),
        title: const Text(
          'Delete Product',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this product?',
          style: TextStyle(
            color: _muted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _muted,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _red,
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
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
        const SnackBar(
          backgroundColor: _green,
          content: Text('Product deleted successfully'),
        ),
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

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EditProductDialog(product: product),
    );

    if (result == null || !context.mounted) return;

    try {
      final productRef = FirebaseFirestore.instance
          .collection('grocery_products')
          .doc(productId);

      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          final snapshot = await transaction.get(productRef);

          if (!snapshot.exists ||
              snapshot.data()?['sellerId'] != user.uid) {
            throw Exception('Product not found or access denied');
          }

          transaction.update(productRef, {
            'description': result['description'],
            'price': result['price'],
            'stock': result['stock'],
            'status': 'pending',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        },
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _green,
          content: Text('Product submitted for approval'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();

    final Color color;
    final Color background;

    if (normalized == 'active' || normalized == 'approved') {
      color = _green;
      background = const Color(0xFFE7F2E8);
    } else if (normalized == 'rejected') {
      color = _red;
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

  Widget _productImage(String path) {
    const fallback = Center(
      child: Icon(
        Icons.shopping_basket_outlined,
        color: _green,
        size: 32,
      ),
    );

    return Container(
      width: 68,
      height: 76,
      padding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: path.isEmpty
          ? fallback
          : Image.asset(
              path,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
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
            Icon(icon, color: _green, size: 58),
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
          'Manage Products',
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
                'Log in to manage your grocery products.',
              )
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('grocery_products')
                    .where('sellerId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _message(
                      Icons.error_outline_rounded,
                      'Unable to load products',
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

                  final products = snapshot.data!.docs;

                  if (products.isEmpty) {
                    return _message(
                      Icons.inventory_2_outlined,
                      'No products yet',
                      'Products you add will appear here.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      28,
                    ),
                    itemCount: products.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F2E8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
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
                                      'Your product collection',
                                      style: TextStyle(
                                        color: _textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${products.length} '
                                      '${products.length == 1 ? 'product' : 'products'}'
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

                      final productDoc = products[index - 1];
                      final product = productDoc.data();

                      final name =
                          (product['name'] ?? 'Unnamed Product')
                              .toString();

                      final category =
                          (product['category'] ?? '').toString();

                      final image =
                          (product['imageUrl'] ?? '').toString();

                      final price =
                          (product['price'] as num?)?.toDouble() ??
                              0.0;

                      final stock =
                          (product['stock'] as num?)?.toInt() ?? 0;

                      final status =
                          (product['status'] ?? 'pending').toString();

                      return Container(
                        padding: const EdgeInsets.all(16),
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
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _productImage(image),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: _textColor,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        category,
                                        style: const TextStyle(
                                          color: _muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rs. ${price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: _green,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'Product actions',
                                  color: Colors.white,
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: _muted,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editProduct(
                                        context,
                                        productDoc.id,
                                        product,
                                      );
                                    } else if (value == 'delete') {
                                      _deleteProduct(
                                        context,
                                        productDoc.id,
                                      );
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            color: _green,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: _red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(
                              height: 28,
                              color: Color(0xFFEDF1EA),
                            ),
                            Wrap(
                              alignment:
                                  WrapAlignment.spaceBetween,
                              crossAxisAlignment:
                                  WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                Text(
                                  'Stock: $stock',
                                  style: const TextStyle(
                                    color: _muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _statusBadge(status),
                              ],
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

class _EditProductDialog extends StatefulWidget {
  const _EditProductDialog({
    required this.product,
  });

  final Map<String, dynamic> product;

  @override
  State<_EditProductDialog> createState() =>
      _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  static const _green = Color(0xFF217A4B);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();

    _descriptionController = TextEditingController(
      text: '${widget.product['description'] ?? ''}',
    );
    _priceController = TextEditingController(
      text: '${widget.product['price'] ?? 0}',
    );
    _stockController = TextEditingController(
      text: '${widget.product['stock'] ?? 0}',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _muted),
      filled: true,
      fillColor: const Color(0xFFF5F8F4),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE3EADF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _green,
          width: 1.5,
        ),
      ),
      errorMaxLines: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: const Text(
        'Edit Product',
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Saved changes will be submitted for admin approval.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(color: _textColor),
                decoration: _decoration('Description'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                                style: const TextStyle(color: _textColor),
                decoration: _decoration('Price (Rs.)'),
                validator: (value) {
                  final price =
                      double.tryParse(value?.trim() ?? '');

                  if (price == null ||
                      !price.isFinite ||
                      price <= 0) {
                    return 'Enter a positive price';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: _textColor),
                decoration: _decoration('Stock Quantity'),
                validator: (value) {
                  final stock =
                      int.tryParse(value?.trim() ?? '');

                  if (stock == null || stock < 0) {
                    return 'Enter a valid stock quantity';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: _muted,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop<Map<String, dynamic>>(context, {
              'description': _descriptionController.text.trim(),
              'price': double.parse(_priceController.text.trim()),
              'stock': int.parse(_stockController.text.trim()),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}