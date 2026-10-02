import '../screens/food_saver_screen.dart';

class FoodCartItem {
  final SaveBiteOffer offer;
  int quantity;

  FoodCartItem({required this.offer, this.quantity = 1});

  double get total => offer.saverPrice * quantity;
}

class FoodCartService {
  FoodCartService._();

  static final FoodCartService instance = FoodCartService._();

  final List<FoodCartItem> items = [];

  void addToCart(SaveBiteOffer offer, int quantity) {
    final existingIndex = items.indexWhere(
      (item) =>
          item.offer.foodName == offer.foodName &&
          item.offer.restaurantName == offer.restaurantName,
    );

    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(FoodCartItem(offer: offer, quantity: quantity));
    }
  }

  void removeFromCart(int index) {
    items.removeAt(index);
  }

  void increaseQuantity(int index) {
    final item = items[index];

    if (item.quantity < item.offer.quantity) {
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

  bool get isEmpty => items.isEmpty;
}
