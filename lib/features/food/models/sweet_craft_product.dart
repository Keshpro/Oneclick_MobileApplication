import 'food_product.dart';

class SweetCraftProduct extends FoodProduct {
  final String requestId;
  final String applicationId;
  final String offerDetails;

  const SweetCraftProduct({
    required super.id,
    required super.name,
    required super.sellerName,
    required super.foodImage,
    required super.sellerLogo,
    required super.price,
    required super.rating,
    required super.reviewCount,
    required super.availableQuantity,
    required super.availableUntil,
    required this.requestId,
    required this.applicationId,
    required this.offerDetails,
  }) : super(type: FoodProductType.sweetCraft);
}
