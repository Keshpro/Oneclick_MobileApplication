import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/grocery_order_model.dart';
import '../models/grocery_product_model.dart';
import '../services/grocery_service.dart';

class GroceryController extends ChangeNotifier {
  final GroceryService _groceryService = GroceryService();

  final List<CartItem> _cartItems = [];
  final List<GroceryOrder> _orders = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';

  // ---------------- PRODUCTS ----------------

  List<GroceryProduct> get products {
    List<GroceryProduct> result;

    if (_selectedCategory == 'All') {
      result = _groceryService.getProducts();
    } else {
      result =
          _groceryService.getProductsByCategory(_selectedCategory);
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((product) {
        final query = _searchQuery.toLowerCase();

        return product.name.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
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

  bool placeOrder({
    required DeliveryMethod deliveryMethod,
    required String paymentMethod,
    String? deliveryAddress,
  }) {
    if (_cartItems.isEmpty) {
      return false;
    }

    if (deliveryMethod == DeliveryMethod.delivery &&
        (deliveryAddress == null ||
            deliveryAddress.trim().isEmpty)) {
      return false;
    }

    final order = GroceryOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: _cartItems
          .map(
            (item) => CartItem(
              product: item.product,
              quantity: item.quantity,
            ),
          )
          .toList(),
      totalAmount: cartTotal,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      deliveryAddress: deliveryAddress,
      orderDate: DateTime.now(),
    );

    _orders.insert(0, order);
    _cartItems.clear();

    notifyListeners();

    return true;
  }
}