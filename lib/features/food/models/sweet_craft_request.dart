enum SweetCraftRequestStatus {
  open,
  reviewing,
  sellerSelected,
  negotiating,
  completed,
  cancelled,
}

enum SweetCraftApplicationStatus { pending, accepted, rejected }

class SweetCraftRequest {
  final String id;

  final String title;
  final String foodType;
  final String occasion;

  final String description;
  final String theme;
  final String flavor;

  final int servings;

  final double minBudget;
  final double maxBudget;

  final String requiredDate;
  final String location;

  final List<String> referenceImages;

  SweetCraftRequestStatus status;

  SweetCraftRequest({
    required this.id,
    required this.title,
    required this.foodType,
    required this.occasion,
    required this.description,
    required this.theme,
    required this.flavor,
    required this.servings,
    required this.minBudget,
    required this.maxBudget,
    required this.requiredDate,
    required this.location,
    required this.referenceImages,
    this.status = SweetCraftRequestStatus.open,
  });
}
