class WorkerModel {
  final String id;
  final String name;
  final String phone;
  final String category;
  final String experience;
  final double rating;
  final int reviewCount;
  final List<String> skills;
  final List<String> serviceAreas;
  final String description;
  final double startingPrice;
  final bool isAvailable;

  WorkerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.category,
    required this.experience,
    required this.rating,
    required this.reviewCount,
    required this.skills,
    required this.serviceAreas,
    required this.description,
    required this.startingPrice,
    required this.isAvailable,
  });
}