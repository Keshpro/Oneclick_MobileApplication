import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/grocery_order_model.dart';
import '../models/grocery_product_model.dart';
import '../services/grocery_service.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroceryController extends ChangeNotifier {
  final GroceryService _groceryService = GroceryService();
  List<GroceryProduct> _firebaseProducts = [];

StreamSubscription<List<GroceryProduct>>? _productsSubscription;

bool _productsLoading = true;
String? _productsError;

bool get productsLoading => _productsLoading;
String? get productsError => _productsError;

  final List<CartItem> _cartItems = [];
  final List<GroceryOrder> _orders = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  GroceryController() {
  _listenToApprovedProducts();
}

void _listenToApprovedProducts() {
  _productsSubscription = _groceryService
      .watchApprovedProducts()
      .listen(
    (products) {
      _firebaseProducts = products;
      _productsLoading = false;
      _productsError = null;
      notifyListeners();
    },
    onError: (Object error) {
      _productsLoading = false;
      _productsError = error.toString();
      notifyListeners();
    },
  );
}

@override
void dispose() {
  _productsSubscription?.cancel();
  super.dispose();
}

  // ---------------- PRODUCTS ----------------

  List<GroceryProduct> get products {
 List<GroceryProduct> result = _firebaseProducts.isNotEmpty
    ? List.from(_firebaseProducts)
    : _groceryService.getProducts();

  if (_selectedCategory != 'All') {
    result = result
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  if (_searchQuery.isNotEmpty) {
    final query = _searchQuery.toLowerCase();

    result = result.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.sellerName.toLowerCase().contains(query);
    }).toList();
  }

  return result;
}

  List<String> get categories =>
      _groceryService.getCategories();

  String get selectedCategory => _selectedCategory;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // ---------------- CART ----------------

  List<CartItem> get cartItems =>
      List.unmodifiable(_cartItems);

  int get cartItemCount {
    return _cartItems.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get cartTotal {
    return _cartItems.fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  void addToCart(GroceryProduct product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      _cartItems[index].increaseQuantity();
    } else if (product.stock > 0) {
      _cartItems.add(
        CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  void increaseQuantity(GroceryProduct product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      _cartItems[index].increaseQuantity();
      notifyListeners();
    }
  }

  void decreaseQuantity(GroceryProduct product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].decreaseQuantity();
      } else {
        _cartItems.removeAt(index);
      }

      notifyListeners();
    }
  }

  void removeFromCart(GroceryProduct product) {
    _cartItems.removeWhere(
      (item) => item.product.id == product.id,
    );

    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ---------------- ORDERS ----------------

  List<GroceryOrder> get orders =>
      List.unmodifiable(_orders);

Future<bool> placeOrder({
  required DeliveryMethod deliveryMethod,
  required String paymentMethod,
  String? deliveryAddress,
}) async {
  if (_cartItems.isEmpty) return false;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  if (deliveryMethod == DeliveryMethod.delivery &&
      (deliveryAddress == null || deliveryAddress.trim().isEmpty)) {
    return false;
  }

  final orderItems = _cartItems.map((item) {
    return CartItem(
      product: item.product,
      quantity: item.quantity,
    );
  }).toList();

  final firestore = FirebaseFirestore.instance;
  final orderRef = firestore.collection('grocery_orders').doc();
  final total = cartTotal;

  try {
    await firestore.runTransaction((transaction) async {
      // Read all products before making any writes.
      final productSnapshots = <String, DocumentSnapshot<Map<String, dynamic>>>{};

      for (final item in orderItems) {
        final productId = item.product.id;

        if (!productSnapshots.containsKey(productId)) {
          final productRef =
              firestore.collection('grocery_products').doc(productId);

          productSnapshots[productId] =
              await transaction.get(productRef);
        }
      }

      // Check available stock.
      final quantities = <String, int>{};

      for (final item in orderItems) {
        quantities.update(
          item.product.id,
          (value) => value + item.quantity,
          ifAbsent: () => item.quantity,
        );
      }

      for (final entry in quantities.entries) {
        final snapshot = productSnapshots[entry.key];

        if (snapshot == null || !snapshot.exists) {
          throw Exception('Product not found');
        }

        final data = snapshot.data()!;
        final availableStock = (data['stock'] as num?)?.toInt() ?? 0;

        if (data['status'] != 'active' ||
            availableStock < entry.value) {
          throw Exception('Product unavailable or insufficient stock');
        }
      }

      // Reduce stock for each product.
      for (final entry in quantities.entries) {
        final productRef =
            firestore.collection('grocery_products').doc(entry.key);

        transaction.update(productRef, {
          'stock': FieldValue.increment(-entry.value),
        });
      }

      // Save the order in the same transaction.
      transaction.set(orderRef, {
        'customerId': user.uid,
        'items': orderItems.map((item) {
          return {
            'productId': item.product.id,
            'name': item.product.name,
            'sellerId': item.product.sellerId,
            'price': item.product.finalPrice,
            'quantity': item.quantity,
            'totalPrice': item.totalPrice,
          };
        }).toList(),
        'totalAmount': total,
        'deliveryMethod': deliveryMethod.name,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
      });
    });

    final order = GroceryOrder(
      id: orderRef.id,
      items: orderItems,
      totalAmount: total,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      orderDate: DateTime.now(),
    );

    _orders.insert(0, order);
    _cartItems.clear();
    notifyListeners();

    return true;
  } catch (e) {
    debugPrint('Failed to place grocery order: $e');
    return false;
  }
}
}