import 'cart_item_model.dart';

enum DeliveryMethod {
  delivery,
  pickup,
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  completed,
  cancelled,
}

class GroceryOrder {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DeliveryMethod deliveryMethod;
  final String paymentMethod;
  final String? deliveryAddress;
  final DateTime orderDate;
  OrderStatus status;

  GroceryOrder({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryMethod,
    required this.paymentMethod,
    this.deliveryAddress,
    required this.orderDate,
    this.status = OrderStatus.pending,
  });
}