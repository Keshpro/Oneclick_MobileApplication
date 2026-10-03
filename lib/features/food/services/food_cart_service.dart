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
    final existingIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(FoodCartItem(product: product, quantity: quantity));
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
    } else {
      items.removeAt(index);
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
