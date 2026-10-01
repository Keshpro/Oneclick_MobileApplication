import 'booking_status.dart';
import 'fare_estimate.dart';
import 'location_model.dart';
import 'trip_reason.dart';
import 'vehicle_model.dart';

class BookingModel {
  final String id;
  final String passengerId;
  final VehicleModel vehicle;
  final LocationModel pickup;
  final LocationModel destination;
  final TripReason reason;
  final FareEstimate fareEstimate;
  final double distanceKm;
  final int durationMinutes;
  final BookingStatus status;
  final DateTime createdAt;
  final String? driverId;

  const BookingModel({
    required this.id,
    required this.passengerId,
    required this.vehicle,
    required this.pickup,
    required this.destination,
    required this.reason,
    required this.fareEstimate,
    required this.distanceKm,
    required this.durationMinutes,
    required this.status,
    required this.createdAt,
    this.driverId,
  });

   BookingModel copyWith({BookingStatus? status, String? driverId}) {
    return BookingModel(
      id: id,
      passengerId: passengerId,
      vehicle: vehicle,
      pickup: pickup,
      destination: destination,
      reason: reason,
      fareEstimate: fareEstimate,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
      createdAt: createdAt,
      driverId: driverId ?? this.driverId,
    );
  }
}