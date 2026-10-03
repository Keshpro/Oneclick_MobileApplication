import 'package:flutter_test/flutter_test.dart';
import 'package:oneclick/features/drunk_drive/models/fare_estimate.dart';
import 'package:oneclick/features/drunk_drive/models/location_model.dart';
import 'package:oneclick/features/drunk_drive/models/trip_reason.dart';
import 'package:oneclick/features/drunk_drive/models/vehicle_model.dart';
import 'package:oneclick/features/drunk_drive/services/booking_service.dart';
import 'package:oneclick/features/drunk_drive/services/vehicle_service.dart';

void main() {
  setUp(() {
    BookingService.debugResetForTests();
    VehicleService.debugResetForTests();
  });

  group('BookingService', () {
    test('creates a booking successfully and adds to my bookings', () {
      final vehicleService = VehicleService();
      final vehicle = vehicleService.addVehicle(
        registrationNumber: 'CAB-5678',
        brand: 'Nissan',
        model: 'Leaf',
        colour: 'Blue',
        vehicleType: VehicleType.car,
        transmission: TransmissionType.automatic,
      );

      final bookingService = BookingService();
      final booking = bookingService.createBooking(
        vehicle: vehicle,
        pickup: const LocationModel(name: 'Colombo 03'),
        destination: const LocationModel(name: 'Nugegoda'),
        reason: TripReason.hadAlcohol,
        fareEstimate: const FareEstimate(
          baseFare: 500,
          distanceCharge: 400,
          timeCharge: 150,
          serviceFee: 100,
        ),
        distanceKm: 8.5,
        durationMinutes: 25,
      );

      final bookings = bookingService.getMyBookings();
      expect(bookings.length, 1);
      expect(bookings.first.id, booking.id);
      expect(bookings.first.fareEstimate.total, 1150);
    });
  });
}
