import '../models/food_offer_model.dart';

class FoodSellerDataService {
  FoodSellerDataService._();

  static final FoodSellerDataService instance = FoodSellerDataService._();

  // ------------------------------------------------------------
  // OFFERS
  // ------------------------------------------------------------

  final List<FoodOfferModel> offers = [];

  // ------------------------------------------------------------
  // STORE PROFILE
  // ------------------------------------------------------------

  String storeName = 'Cocos Bakery';
  String ownerName = 'Dilni';
  String phone = '077 123 4567';
  String email = 'cocosbakery@example.com';
  String address = 'Ambathale, Mulleriyawa, Colombo';
  String description = 'Fresh bakery products and delicious homemade treats.';

  // ------------------------------------------------------------
  // ORDERS
  // ------------------------------------------------------------

  final List<FoodSellerOrder> orders = [
    FoodSellerOrder(
      orderId: 'FC1024',
      foodName: 'Chocolate Cake',
      customerName: 'Dilni',
      quantity: 2,
      total: 1400,
      collectionTime: '6:00 PM',
      status: 'NEW',
    ),

    FoodSellerOrder(
      orderId: 'FC1023',
      foodName: 'Bakery Surprise Box',
      customerName: 'Kamal',
      quantity: 1,
      total: 450,
      collectionTime: '5:30 PM',
      status: 'PREPARING',
    ),

    FoodSellerOrder(
      orderId: 'FC1022',
      foodName: 'Chicken Rice & Curry',
      customerName: 'Nimal',
      quantity: 2,
      total: 780,
      collectionTime: '7:00 PM',
      status: 'READY',
    ),

    FoodSellerOrder(
      orderId: 'FC1021',
      foodName: 'Chocolate Brownies',
      customerName: 'Sarah',
      quantity: 3,
      total: 900,
      collectionTime: '6:30 PM',
      status: 'COMPLETED',
    ),
  ];

  // ------------------------------------------------------------
  // CHANGE ORDER STATUS
  // ------------------------------------------------------------

  void updateOrderStatus(String orderId, String newStatus) {
    final index = orders.indexWhere((order) => order.orderId == orderId);

    if (index != -1) {
      orders[index].status = newStatus;
    }
  }

  // ------------------------------------------------------------
  // COMPLETED EARNINGS
  // ------------------------------------------------------------

  double get totalEarnings {
    return orders
        .where((order) => order.status == 'COMPLETED')
        .fold(0, (sum, order) => sum + order.total);
  }

  int get completedOrders {
    return orders.where((order) => order.status == 'COMPLETED').length;
  }

  int get foodSold {
    return orders
        .where((order) => order.status == 'COMPLETED')
        .fold(0, (sum, order) => sum + order.quantity);
  }
}

// ------------------------------------------------------------
// ORDER MODEL
// ------------------------------------------------------------

class FoodSellerOrder {
  final String orderId;
  final String foodName;
  final String customerName;
  final int quantity;
  final double total;
  final String collectionTime;

  String status;

  FoodSellerOrder({
    required this.orderId,
    required this.foodName,
    required this.customerName,
    required this.quantity,
    required this.total,
    required this.collectionTime,
    required this.status,
  });
}
