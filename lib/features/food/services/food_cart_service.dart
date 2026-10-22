import '../models/food_product.dart';

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

  // Add any type of FoodProduct to the cart.
  void addProduct(FoodProduct product, int quantity) {
    if (quantity <= 0 || product.availableQuantity <= 0) {
      return;
    }

    final existingIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final existingItem = items[existingIndex];
      final remainingStock = product.availableQuantity - existingItem.quantity;

      if (remainingStock <= 0) return;

      existingItem.quantity += quantity > remainingStock
          ? remainingStock
          : quantity;
    } else {
      final safeQuantity = quantity > product.availableQuantity
          ? product.availableQuantity
          : quantity;

      items.add(FoodCartItem(product: product, quantity: safeQuantity));
    }
  }

  void removeFromCart(int index) {
    items.removeAt(index);
  }

  void increaseQuantity(int index) {
    final item = items[index];

    if (item.quantity < item.product.availableQuantity) {
      item.quantity++;
    }
  }

  void decreaseQuantity(int index) {
    final item = items[index];

    if (item.quantity > 1) {
      item.quantity--;
    }
  }

  void clearCart() {
    items.clear();
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  bool get isEmpty {
    return items.isEmpty;
  }
}
