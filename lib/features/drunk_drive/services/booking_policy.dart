import '../models/booking_model.dart';
import '../models/booking_status.dart';
import '../models/vehicle_model.dart';

class BookingPolicy {
  static const searchTimeout = Duration(minutes: 3);
  static const nearbyRadiusKm = 15.0;

  static bool isSearching(BookingStatus status) =>
      status == BookingStatus.requested || status == BookingStatus.searchingDriver;

  static bool blocksNewBooking(BookingModel booking) =>
      !{BookingStatus.completed, BookingStatus.cancelledByUser,
        BookingStatus.cancelledByDriver, BookingStatus.driverNotFound}.contains(booking.status);

  static DateTime? parseDate(String value) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
    final date = DateTime.tryParse(value);
    if (date == null || date.year.toString().padLeft(4, '0') != value.substring(0, 4) ||
        date.month.toString().padLeft(2, '0') != value.substring(5, 7) ||
        date.day.toString().padLeft(2, '0') != value.substring(8, 10)) {
      return null;
    }
    return date;
  }

  static bool licenceValid(String expiry) {
    final date = parseDate(expiry.trim());
    final now = DateTime.now();
    return date != null && !date.isBefore(DateTime(now.year, now.month, now.day));
  }

  static bool compatible(BookingModel booking, {required bool manual, required bool automatic}) =>
      booking.vehicle.transmission == TransmissionType.manual ? manual : automatic;

  static bool searchExpired(BookingModel booking) => isSearching(booking.status) &&
      DateTime.now().difference(booking.searchStartedAt ?? booking.createdAt) >= searchTimeout;
}
