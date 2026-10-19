class GroceryProduct {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double? discountPrice;
  final String imageUrl;
  final int stock;

  // Multi-Seller fields
  final String sellerId;
  final String sellerName;

  const GroceryProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.stock,

    // Optional for backward compatibility
    this.sellerId = '',
    this.sellerName = '',
  });

  bool get hasDiscount =>
      discountPrice != null && discountPrice! < price;

  double get finalPrice =>
      hasDiscount ? discountPrice! : price;

  bool get isAvailable => stock > 0;
}