// Vehicle model for the Drunk & Drive module.
//
// A vehicle belongs to exactly one passenger (ownerId). The driver never
// owns a vehicle in this module — the driver always drives the
// passenger's own vehicle.

enum VehicleType { car, van, suv, threeWheeler, other }

enum TransmissionType { automatic, manual }

extension VehicleTypeLabel on VehicleType {
  String get label {
    switch (this) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.van:
        return 'Van';
      case VehicleType.suv:
        return 'SUV';
      case VehicleType.threeWheeler:
        return 'Three Wheeler';
      case VehicleType.other:
        return 'Other';
    }
  }
}

extension TransmissionTypeLabel on TransmissionType {
  String get label {
    switch (this) {
      case TransmissionType.automatic:
        return 'Automatic';
      case TransmissionType.manual:
        return 'Manual';
    }
  }
}

class VehicleModel {
  final String id;

  // The uid of the passenger who owns this vehicle.
  // The backend must enforce that only this owner can edit/delete it.
  final String ownerId;

  final String registrationNumber;
  final String brand;
  final String model;
  final String colour;
  final VehicleType vehicleType;
  final TransmissionType transmission;

  // Local file path or URL to the vehicle photo. Optional.
  final String? photoPath;

  final bool isDefault;

  const VehicleModel({
    required this.id,
    required this.ownerId,
    required this.registrationNumber,
    required this.brand,
    required this.model,
    required this.colour,
    required this.vehicleType,
    required this.transmission,
    this.photoPath,
    this.isDefault = false,
  });

  String get displayName => '$brand $model';

  VehicleModel copyWith({
    String? registrationNumber,
    String? brand,
    String? model,
    String? colour,
    VehicleType? vehicleType,
    TransmissionType? transmission,
    String? photoPath,
    bool? isDefault,
  }) {
    return VehicleModel(
      id: id,
      ownerId: ownerId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      colour: colour ?? this.colour,
      vehicleType: vehicleType ?? this.vehicleType,
      transmission: transmission ?? this.transmission,
      photoPath: photoPath ?? this.photoPath,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
