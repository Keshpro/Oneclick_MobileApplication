import '../models/driver_rating_model.dart';

class DriverRatingService {
  static final List<DriverRatingModel> _ratings = [];

  static const String currentPassengerId = 'mock-passenger-1';

  List<DriverRatingModel> getRatingsForDriver(String driverId) {
    return _ratings.where((rating) => rating.driverId == driverId).toList();
  }

  DriverRatingModel? getRatingForBooking(String bookingId) {
    for (final rating in _ratings) {
      if (rating.bookingId == bookingId) {
        return rating;
      }
    }

    return null;
  }

  bool hasRatedBooking(String bookingId) {
    return getRatingForBooking(bookingId) != null;
  }

  DriverRatingModel? submitRating({
    required String bookingId,
    required String driverId,
    required int rating,
    String? review,
  }) {
    if (rating < 1 || rating > 5) {
      return null;
    }

    if (hasRatedBooking(bookingId)) {
      return null;
    }

    final trimmedReview = review?.trim();

    final driverRating = DriverRatingModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      bookingId: bookingId,
      driverId: driverId,
      passengerId: currentPassengerId,
      rating: rating,
      review: trimmedReview == null || trimmedReview.isEmpty
          ? null
          : trimmedReview,
      createdAt: DateTime.now(),
    );

    _ratings.add(driverRating);

    return driverRating;
  }

  double? getAverageRating(String driverId) {
    final ratings = getRatingsForDriver(driverId);

    if (ratings.isEmpty) {
      return null;
    }

    final total = ratings.fold<int>(0, (sum, rating) => sum + rating.rating);

    return total / ratings.length;
  }

  int getRatingCount(String driverId) {
    return getRatingsForDriver(driverId).length;
  }
}
