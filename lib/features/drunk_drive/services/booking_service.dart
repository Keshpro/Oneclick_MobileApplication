import 'dart:math';

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

  /// Statuses that mean "this driver is currently committed to a trip"
  /// (spec section 33: a driver with an active trip can't accept another).
  static const Set<BookingStatus> _activeDriverStatuses = {
    BookingStatus.driverAssigned,
    BookingStatus.driverAccepted,
    BookingStatus.driverArriving,
    BookingStatus.driverArrived,
    BookingStatus.verification,
    BookingStatus.tripStarted,
    BookingStatus.tripInProgress,
  };

  /// The driver's current in-progress booking, if any.
  BookingModel? getMyActiveDriverBooking(String driverId) {
    for (final booking in _bookings) {
      if (booking.driverId == driverId &&
          _activeDriverStatuses.contains(booking.status)) {
        return booking;
      }
    }
    return null;
  }

  /// Attempts to accept a booking for the given driver. Returns the
  /// updated booking on success, or null if it's no longer available
  /// (already accepted by someone else, no longer REQUESTED, or this
  /// driver already has an active trip). These guards are what prevent
  /// two drivers accepting the same trip, and a busy driver accepting
  /// a second one (spec sections 33 & 40) — once backed by Firestore,
  /// the same checks become a transaction instead of a list scan.
  BookingModel? acceptBooking(String bookingId, String driverId) {
    if (getMyActiveDriverBooking(driverId) != null) {
      return null; // this driver is already on a trip
    }

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return null;

    final current = _bookings[index];
    if (current.status != BookingStatus.requested || current.driverId != null) {
      return null; // someone else already took it
    }

    final updated = current.copyWith(
      status: BookingStatus.driverAssigned,
      driverId: driverId,
      tripPin: _generatePin(),
    );
    _bookings[index] = updated;
    return updated;
  }

  /// Statuses a trip may validly be in right before TRIP_STARTED.
  static const Set<BookingStatus> _preTripStartStatuses = {
    BookingStatus.driverAssigned,
    BookingStatus.driverAccepted,
    BookingStatus.driverArriving,
    BookingStatus.driverArrived,
    BookingStatus.verification,
  };

  /// Attempts to start a trip. Returns the updated booking on success,
  /// or null if: this isn't the assigned driver, the booking isn't in
  /// a valid pre-start state, or the PIN is wrong. The trip NEVER
  /// starts on a wrong PIN (spec section 17) — this is the one place
  /// that check happens, so no screen can bypass it.
  BookingModel? startTrip({
    required String bookingId,
    required String driverId,
    required String enteredPin,
  }) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);

    if (index == -1) {
      return null;
    }

    final current = _bookings[index];

    if (current.driverId != driverId) {
      return null;
    }

    if (!_preTripStartStatuses.contains(current.status)) {
      return null;
    }

    if (current.tripPin == null || enteredPin.trim() != current.tripPin) {
      return null;
    }
    final updated = current.copyWith(
      status: BookingStatus.tripStarted,
      startedAt: DateTime.now(),
    );
    _bookings[index] = updated;
    return updated;
  }

  String _generatePin() {
    final random = Random();
    return List.generate(4, (_) => random.nextInt(10)).join();
  }

  /// Statuses a trip may validly be in while it's ongoing.
  static const Set<BookingStatus> _inProgressStatuses = {
    BookingStatus.tripStarted,
    BookingStatus.tripInProgress,
  };

  /// Ends a trip. Returns the updated booking on success, or null if
  /// this isn't the assigned driver or the trip isn't currently in
  /// progress — so TRIP_COMPLETED can never be reached from the wrong
  /// state (spec section 40: no jumping statuses).
  BookingModel? endTrip({required String bookingId, required String driverId}) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return null;

    final current = _bookings[index];
    if (current.driverId != driverId) return null;
    if (!_inProgressStatuses.contains(current.status)) return null;

    final updated = current.copyWith(
      status: BookingStatus.tripCompleted,
      completedAt: DateTime.now(),
    );
    _bookings[index] = updated;
    return updated;
  }

  BookingModel? moveToPayment(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return null;

    final current = _bookings[index];

    if (current.status != BookingStatus.tripCompleted) {
      return null;
    }

    final updated = current.copyWith(status: BookingStatus.payment);

    _bookings[index] = updated;
    return updated;
  }

  BookingModel? completePayment(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return null;

    final current = _bookings[index];

    if (current.status != BookingStatus.payment) {
      return null;
    }

    final updated = current.copyWith(status: BookingStatus.completed);

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
