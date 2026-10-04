import 'sweet_craft_request.dart';

class SweetCraftApplication {
  final String id;
  final String requestId;

  final String shopName;
  final String sellerName;

  final double offeredPrice;
  final String estimatedCompletionDate;

  final String message;

  final double rating;
  final int completedOrders;

  final String instagramUrl;
  final String facebookUrl;
  final String websiteUrl;

  final List<String> portfolioImages;

  SweetCraftApplicationStatus status;

  SweetCraftApplication({
    required this.id,
    required this.requestId,
    required this.shopName,
    required this.sellerName,
    required this.offeredPrice,
    required this.estimatedCompletionDate,
    required this.message,
    required this.rating,
    required this.completedOrders,
    required this.instagramUrl,
    required this.facebookUrl,
    required this.websiteUrl,
    required this.portfolioImages,
    this.status = SweetCraftApplicationStatus.pending,
  });
}
