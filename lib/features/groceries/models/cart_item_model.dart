import 'grocery_product_model.dart';

class CartItem {
  final GroceryProduct product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice {
    return product.finalPrice * quantity;
  }

  void increaseQuantity() {
    if (quantity < product.stock) {
      quantity++;
    }
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}