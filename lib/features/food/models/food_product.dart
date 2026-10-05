enum FoodProductType { saveBite, mysteryBites, homeTable, sweetCraft }

enum FoodFulfillmentOption { pickup, delivery }

abstract class FoodProduct {
  final String id;
  final String name;
  final String sellerName;
  final String foodImage;
  final String sellerLogo;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final int availableQuantity;
  final String availableUntil;
  final FoodProductType type;

  const FoodProduct({
    required this.id,
    required this.name,
    required this.sellerName,
    required this.foodImage,
    required this.sellerLogo,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.availableQuantity,
    required this.availableUntil,
    required this.type,
  });

  List<FoodFulfillmentOption> get fulfillmentOptions => [
    FoodFulfillmentOption.pickup,
    FoodFulfillmentOption.delivery,
  ];
}
