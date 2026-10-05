class DriverRatingModel {
  final String id;
  final String bookingId;
  final String driverId;
  final String passengerId;
  final int rating;
  final String? review;
  final DateTime createdAt;

  const DriverRatingModel({
    required this.id,
    required this.bookingId,
    required this.driverId,
    required this.passengerId,
    required this.rating,
    this.review,
    required this.createdAt,
  });

  DriverRatingModel copyWith({
    int? rating,
    String? review,
  }) {
    return DriverRatingModel(
      id: id,
      bookingId: bookingId,
      driverId: driverId,
      passengerId: passengerId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
    );
  }
}