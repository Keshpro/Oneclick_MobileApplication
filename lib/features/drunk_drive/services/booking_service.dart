import '../models/booking_model.dart';
import '../models/booking_status.dart';
import '../models/fare_estimate.dart';
import '../models/location_model.dart';
import '../models/trip_reason.dart';
import '../models/vehicle_model.dart';
import 'vehicle_service.dart';

class BookingService {
  static final List<BookingModel> _bookings = [];

  List<BookingModel> getMyBookings() {
    final mine = _bookings
        .where((b) => b.passengerId == VehicleService.currentUserId)
        .toList();
    mine.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return mine;
  }

    BookingModel? getBookingById(String id) {
    for (final booking in _bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  /// Bookings any driver could currently accept: still REQUESTED and
  /// not yet claimed by a driver.
  List<BookingModel> getAvailableRequests() {
    final available = _bookings
        .where((b) => b.status == BookingStatus.requested && b.driverId == null)
        .toList();
    available.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return available;
  }

  /// Attempts to accept a booking for the given driver. Returns the
  /// updated booking on success, or null if it's no longer available
  /// (already accepted by someone else, or no longer REQUESTED). This
  /// guard is what prevents two drivers from accepting the same trip
  /// (spec section 40) — once this is backed by Firestore, the same
  /// check becomes a transaction instead of an in-memory list check.
  BookingModel? acceptBooking(String bookingId, String driverId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return null;

    final current = _bookings[index];
    if (current.status != BookingStatus.requested || current.driverId != null) {
      return null; // someone else already took it
    }

    final updated = current.copyWith(
      status: BookingStatus.driverAssigned,
      driverId: driverId,
    );
    _bookings[index] = updated;
    return updated;
  }

  BookingModel createBooking({
    required VehicleModel vehicle,
    required LocationModel pickup,
    required LocationModel destination,
    required TripReason reason,
    required FareEstimate fareEstimate,
    required double distanceKm,
    required int durationMinutes,
  }) {
    final booking = BookingModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      passengerId: VehicleService.currentUserId,
      vehicle: vehicle,
      pickup: pickup,
      destination: destination,
      reason: reason,
      fareEstimate: fareEstimate,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      status: BookingStatus.requested,
      createdAt: DateTime.now(),
    );
    _bookings.add(booking);
    return booking;
  }

  static void debugResetForTests() => _bookings.clear();
}