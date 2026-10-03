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