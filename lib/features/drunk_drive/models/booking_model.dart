import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? tripPin;
  final DateTime? startedAt;
  final DateTime? completedAt;

  // Payment information is independent of the trip lifecycle status.
  // Existing Firestore bookings default to unpaid when these fields are absent.
  final String paymentStatus; // unpaid, pending, paid
  final String? paymentMethod; // cash, simulatedCard
  final double? amountDue;
  final DateTime? paidAt;

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
    this.tripPin,
    this.startedAt,
    this.completedAt,
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
    this.amountDue,
    this.paidAt,
  });

  double get customerAmountDue => amountDue ?? fareEstimate.total;

  BookingModel copyWith({
    BookingStatus? status,
    String? driverId,
    String? tripPin,
    DateTime? startedAt,
    DateTime? completedAt,
    String? paymentStatus,
    String? paymentMethod,
    double? amountDue,
    DateTime? paidAt,
  }) {
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
      tripPin: tripPin ?? this.tripPin,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountDue: amountDue ?? this.amountDue,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'vehicle': {
        'id': vehicle.id,
        'ownerId': vehicle.ownerId,
        'registrationNumber': vehicle.registrationNumber,
        'brand': vehicle.brand,
        'model': vehicle.model,
        'colour': vehicle.colour,
        'vehicleType': vehicle.vehicleType.name,
        'transmission': vehicle.transmission.name,
        'photoName': vehicle.photoName,
        'isDefault': vehicle.isDefault,
      },
      'pickup': {
        'name': pickup.name,
        'address': pickup.address,
        'latitude': pickup.latitude,
        'longitude': pickup.longitude,
      },
      'destination': {
        'name': destination.name,
        'address': destination.address,
        'latitude': destination.latitude,
        'longitude': destination.longitude,
      },
      'reason': reason.name,
      'fareEstimate': {
        'baseFare': fareEstimate.baseFare,
        'distanceCharge': fareEstimate.distanceCharge,
        'timeCharge': fareEstimate.timeCharge,
        'serviceFee': fareEstimate.serviceFee,
      },
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'driverId': driverId,
      'tripPin': tripPin,
      'startedAt': startedAt == null ? null : Timestamp.fromDate(startedAt!),
      'completedAt': completedAt == null
          ? null
          : Timestamp.fromDate(completedAt!),
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'amountDue': customerAmountDue,
      'paidAt': paidAt == null ? null : Timestamp.fromDate(paidAt!),
    };
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> data) {
    final vehicleData = Map<String, dynamic>.from(data['vehicle'] as Map);
    final pickupData = Map<String, dynamic>.from(data['pickup'] as Map);
    final destinationData = Map<String, dynamic>.from(
      data['destination'] as Map,
    );
    final fareData = Map<String, dynamic>.from(data['fareEstimate'] as Map);

    double? optionalDouble(dynamic value) {
      return value == null ? null : (value as num).toDouble();
    }

    DateTime? optionalDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.parse(value as String);
    }

    final fareEstimate = FareEstimate(
      baseFare: (fareData['baseFare'] as num).toDouble(),
      distanceCharge: (fareData['distanceCharge'] as num).toDouble(),
      timeCharge: (fareData['timeCharge'] as num).toDouble(),
      serviceFee: (fareData['serviceFee'] as num).toDouble(),
    );

    return BookingModel(
      id: id,
      passengerId: data['passengerId'] as String,
      vehicle: VehicleModel(
        id: vehicleData['id'] as String,
        ownerId: vehicleData['ownerId'] as String,
        registrationNumber: vehicleData['registrationNumber'] as String,
        brand: vehicleData['brand'] as String,
        model: vehicleData['model'] as String,
        colour: vehicleData['colour'] as String,
        vehicleType: VehicleType.values.byName(
          vehicleData['vehicleType'] as String,
        ),
        transmission: TransmissionType.values.byName(
          vehicleData['transmission'] as String,
        ),
        photoName: vehicleData['photoName'] as String?,
        isDefault: vehicleData['isDefault'] as bool? ?? false,
      ),
      pickup: LocationModel(
        name: pickupData['name'] as String,
        address: pickupData['address'] as String?,
        latitude: optionalDouble(pickupData['latitude']),
        longitude: optionalDouble(pickupData['longitude']),
      ),
      destination: LocationModel(
        name: destinationData['name'] as String,
        address: destinationData['address'] as String?,
        latitude: optionalDouble(destinationData['latitude']),
        longitude: optionalDouble(destinationData['longitude']),
      ),
      reason: TripReason.values.byName(data['reason'] as String),
      fareEstimate: fareEstimate,
      distanceKm: (data['distanceKm'] as num).toDouble(),
      durationMinutes: (data['durationMinutes'] as num).toInt(),
      status: BookingStatus.values.byName(data['status'] as String),
      createdAt: optionalDate(data['createdAt']) ?? DateTime.now(),
      driverId: data['driverId'] as String?,
      tripPin: data['tripPin'] as String?,
      startedAt: optionalDate(data['startedAt']),
      completedAt: optionalDate(data['completedAt']),
      paymentStatus: data['paymentStatus'] as String? ?? 'unpaid',
      paymentMethod: data['paymentMethod'] as String?,
      amountDue: optionalDouble(data['amountDue']) ?? fareEstimate.total,
      paidAt: optionalDate(data['paidAt']),
    );
  }
}
