import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const _green = Color(0xFF217A4B);
  static const _background = Color(0xFFF5F8F4);
  static const _textColor = Color(0xFF203B2B);
  static const _muted = Color(0xFF748074);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  String _selectedCategory = 'Fruits';
  bool _isSaving = false;

  final List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Meat',
    'Bakery',
    'Beverages',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());

    setState(() => _isSaving = true);

    try {
      final applications = await FirebaseFirestore.instance
          .collection('seller_applications')
          .where('userId', isEqualTo: user.uid)
          .get();

      final approvedApplications = applications.docs.where((doc) {
        return doc.data()['status'] == 'active';
      }).toList();

      if (approvedApplications.isEmpty) {
        throw Exception(
          'Your grocery seller account is not approved.',
        );
      }

      final seller = approvedApplications.first.data();
      final sellerName = (seller['shopName'] ?? '').toString();

      await FirebaseFirestore.instance
          .collection('grocery_products')
          .add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'price': price,
        'discountPrice': null,
        'stock': stock,
        'imageUrl': '',
        'sellerId': user.uid,
        'sellerName': sellerName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _green,
          content: Text(
            'Product submitted for admin approval!',
          ),
        ),
      );

      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _stockController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: _muted,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: _muted,
        fontSize: 13,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: _green,
              size: 22,
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE3EADF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _green,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFB83D3D),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFB83D3D),
          width: 1.5,
        ),
      ),
      errorMaxLines: 2,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: _textColor,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF175C38),
                        Color(0xFF2E8B57),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.add_business_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Grow your shop.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your grocery essentials and help customers '
                        'fill their baskets.',
                        style: TextStyle(
                          color: Color(0xFFE1F2E5),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // Product information
                _sectionTitle('Product information'),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: _textColor),
                  decoration: _inputDecoration(
                    label: 'Product Name',
                    hint: 'e.g. Fresh green apples',
                    icon: Icons.shopping_basket_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSaving,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: _textColor),
                  decoration: _inputDecoration(
                    label: 'Description',
                    hint: 'Add details such as size, weight or quantity',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: _textColor,
                    fontSize: 14,
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _green,
                  ),
                  decoration: _inputDecoration(
                    label: 'Category',
                    icon: Icons.category_outlined,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 26),

                // Price and stock
                _sectionTitle('Price & availability'),
                TextFormField(
                  controller: _priceController,
                  enabled: !_isSaving,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: _textColor),
                  decoration: _inputDecoration(
                    label: 'Price (Rs.)',
                    hint: 'e.g. 1200.00',
                    icon: Icons.payments_outlined,
                  ),
                  validator: (value) {
                    final price =
                        double.tryParse(value?.trim() ?? '');

                    if (price == null ||
                        !price.isFinite ||
                        price <= 0) {
                      return 'Enter a valid price greater than zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: _textColor),
                  decoration: _inputDecoration(
                    label: 'Stock Quantity',
                    hint: 'e.g. 20',
                    icon: Icons.inventory_2_outlined,
                  ),
                  validator: (value) {
                    final stock =
                        int.tryParse(value?.trim() ?? '');

                    if (stock == null || stock < 0) {
                      return 'Enter a valid quantity of zero or more';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),

                // Approval information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F2E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: _green,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reviewed before going live',
                              style: TextStyle(
                                color: _textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Your product will appear in the shop '
                              'after admin approval.',
                              style: TextStyle(
                                color: Color(0xFF607565),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFDBE7DD),
                    disabledForegroundColor: _green,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSaving ? null : _addProduct,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: _green,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(
                    _isSaving
                        ? 'Submitting...'
                        : 'Submit for approval',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}