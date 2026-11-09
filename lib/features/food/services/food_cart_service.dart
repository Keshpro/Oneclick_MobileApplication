import '../models/food_product.dart';
import '../screens/food_saver_screen.dart';

class FoodCartItem {
  final FoodProduct product;
  int quantity;

  FoodCartItem({required this.product, this.quantity = 1});

  double get total {
    return product.price * quantity;
  }
}

class FoodCartService {
  FoodCartService._();

  static final FoodCartService instance = FoodCartService._();

  final List<FoodCartItem> items = [];

  bool _isExpired(FoodProduct product) {
    if (product is SaveBiteOffer) {
      final expiry = product.expiresAt;
      return expiry == null || !expiry.isAfter(DateTime.now());
    }

    return false;
  }

  // Remove expired SaveBite offers from the cart.
  void removeExpiredOffers() {
    items.removeWhere((item) => _isExpired(item.product));
  }

  // Add any type of FoodProduct to the cart.
  bool addProduct(FoodProduct product, int quantity) {
    removeExpiredOffers();

    if (_isExpired(product) ||
        quantity <= 0 ||
        product.availableQuantity <= 0) {
      return false;
    }

    final existingIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final existingItem = items[existingIndex];
      final remainingStock = product.availableQuantity - existingItem.quantity;

      if (remainingStock <= 0) return false;

      existingItem.quantity += quantity > remainingStock
          ? remainingStock
          : quantity;
    } else {
      final safeQuantity = quantity > product.availableQuantity
          ? product.availableQuantity
          : quantity;

      items.add(FoodCartItem(product: product, quantity: safeQuantity));
    }

    return true;
  }

  void removeFromCart(int index) {
    items.removeAt(index);
  }

  void increaseQuantity(int index) {
    removeExpiredOffers();
    if (index < 0 || index >= items.length) return;

    final item = items[index];

    if (!_isExpired(item.product) &&
        item.quantity < item.product.availableQuantity) {
      item.quantity++;
    }
  }

  void decreaseQuantity(int index) {
    if (index < 0 || index >= items.length) return;

    final item = items[index];

    if (item.quantity > 1) {
      item.quantity--;
    }
  }

  void clearCart() {
    items.clear();
  }

  int get totalItems {
    removeExpiredOffers();
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    removeExpiredOffers();
    return items.fold(0, (sum, item) => sum + item.total);
  }

  bool get isEmpty {
    removeExpiredOffers();
    return items.isEmpty;
  }
}
