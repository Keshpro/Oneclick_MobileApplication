class FoodOfferModel {
  final String foodName;
  final String category;
  final String originalPrice;
  final String saverPrice;
  final String quantity;
  final String availableFrom;
  final String availableUntil;
  final String description;
  final String allergens;

  // NEW
  String status;

  FoodOfferModel({
    required this.foodName,
    required this.category,
    required this.originalPrice,
    required this.saverPrice,
    required this.quantity,
    required this.availableFrom,
    required this.availableUntil,
    required this.description,
    required this.allergens,
    this.status = 'ACTIVE',
  });
}
