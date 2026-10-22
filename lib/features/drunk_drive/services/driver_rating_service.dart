import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/driver_rating_model.dart';

/// Persistent driver ratings. Each booking may have at most one rating.
class DriverRatingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _ratings =>
      _db.collection('drunkDriveDriverRatings');

  /// Compatibility cache for older dashboard widgets that use synchronous
  /// rating summaries. For fully live dashboard stats use watchRatingsForDriver.
  static final Map<String, List<DriverRatingModel>> _cachedByDriver = {};

  DriverRatingModel _parse(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    final createdAt = rawCreatedAt is Timestamp
        ? rawCreatedAt.toDate()
        : DateTime.fromMillisecondsSinceEpoch(0);
    return DriverRatingModel(
      id: id,
      bookingId: data['bookingId'] as String? ?? id,
      driverId: data['driverId'] as String? ?? '',
      passengerId: data['passengerId'] as String? ?? '',
      rating: (data['rating'] as num).toInt(),
      review: data['review'] as String?,
      createdAt: createdAt,
    );
  }

  Stream<List<DriverRatingModel>> watchRatingsForDriver(String driverId) {
    return _ratings.where('driverId', isEqualTo: driverId).snapshots().map(
      (snapshot) {
        final results = snapshot.docs
            .map((doc) => _parse(doc.id, doc.data()))
            .toList();
        _cachedByDriver[driverId] = results;
        return results;
      },
    );
  }

  Future<List<DriverRatingModel>> fetchRatingsForDriver(String driverId) async {
    final snapshot = await _ratings.where('driverId', isEqualTo: driverId).get();
    final results = snapshot.docs
        .map((doc) => _parse(doc.id, doc.data()))
        .toList();
    _cachedByDriver[driverId] = results;
    return results;
  }

  Future<DriverRatingModel?> getRatingForBooking(String bookingId) async {
    final document = await _ratings.doc(bookingId).get();
    final data = document.data();
    return data == null ? null : _parse(document.id, data);
  }

  Future<bool> hasRatedBooking(String bookingId) async {
    final document = await _ratings.doc(bookingId).get();
    return document.exists;
  }

  /// Returns null for an already-rated booking or invalid rating.
  /// Throws on authorization, network, or database errors.
  Future<DriverRatingModel?> submitRating({
    required String bookingId,
    required String driverId,
    required int rating,
    String? review,
  }) async {
    if (rating < 1 || rating > 5 || bookingId.isEmpty || driverId.isEmpty) {
      return null;
    }
    final passengerId = _auth.currentUser?.uid;
    if (passengerId == null) {
      throw StateError('Please sign in to rate your driver.');
    }

    final bookingRef = _db.collection('drunkDriveBookings').doc(bookingId);
    final ratingRef = _ratings.doc(bookingId);
    final text = review?.trim();

    final saved = await _db.runTransaction<DriverRatingModel?>((transaction) async {
      // Read before writing: this prevents two simultaneous duplicate ratings.
      final bookingSnapshot = await transaction.get(bookingRef);
      final ratingSnapshot = await transaction.get(ratingRef);
      final booking = bookingSnapshot.data();
      if (booking == null ||
          booking['passengerId'] != passengerId ||
          booking['driverId'] != driverId ||
          booking['status'] != 'completed') {
        throw StateError('Only the passenger can rate their completed trip.');
      }
      if (ratingSnapshot.exists) {
        return null;
      }

      final now = Timestamp.now();
      transaction.set(ratingRef, {
        'bookingId': bookingId,
        'driverId': driverId,
        'passengerId': passengerId,
        'rating': rating,
        'review': text == null || text.isEmpty ? null : text,
        'createdAt': now,
      });
      return DriverRatingModel(
        id: bookingId,
        bookingId: bookingId,
        driverId: driverId,
        passengerId: passengerId,
        rating: rating,
        review: text == null || text.isEmpty ? null : text,
        createdAt: now.toDate(),
      );
    });

    if (saved != null) {
      final current = _cachedByDriver[driverId];
      if (current != null &&
          !current.any((rating) => rating.bookingId == bookingId)) {
        _cachedByDriver[driverId] = [...current, saved];
      }
    }
    return saved;
  }

  // Legacy synchronous summaries; only contain records loaded this session.
  // Connect DriverHomeScreen to watchRatingsForDriver for persistent stats.
  double? getAverageRating(String driverId) {
    final ratings = _cachedByDriver[driverId] ?? const <DriverRatingModel>[];
    if (ratings.isEmpty) {
      return null;
    }
    final score = ratings.fold<int>(0, (total, item) => total + item.rating);
    return score / ratings.length;
  }

  int getRatingCount(String driverId) {
    return _cachedByDriver[driverId]?.length ?? 0;
  }
}
