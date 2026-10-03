import 'food_product.dart';

class MysteryBitesProduct extends FoodProduct {
  final String description;
  final double estimatedValue;

  final List<String> possibleItems;
  final List<String> allergens;

  final String collectionTime;

  final bool containsVegetarianOptions;

  MysteryBitesProduct({
    required super.id,
    required super.name,
    required super.sellerName,
    required super.foodImage,
    required super.sellerLogo,
    required super.price,
    super.originalPrice,
    required super.rating,
    required super.reviewCount,
    required super.availableQuantity,
    required super.availableUntil,
    required this.description,
    required this.estimatedValue,
    required this.possibleItems,
    required this.allergens,
    required this.collectionTime,
    required this.containsVegetarianOptions,
  }) : super(type: FoodProductType.mysteryBites);
}
