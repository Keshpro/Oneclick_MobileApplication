import 'package:flutter_test/flutter_test.dart';
import 'package:oneclick/features/drunk_drive/models/vehicle_model.dart';
import 'package:oneclick/features/drunk_drive/services/vehicle_service.dart';

void main() {
  setUp(() {
    VehicleService.debugResetForTests();
  });

  group('VehicleService', () {
    test('a newly added vehicle appears in getMyVehicles', () {
      final service = VehicleService();

      final vehicle = service.addVehicle(
        registrationNumber: 'abc-1234',
        brand: 'Toyota',
        model: 'Prius',
        colour: 'White',
        vehicleType: VehicleType.car,
        transmission: TransmissionType.automatic,
      );

      final vehicles = service.getMyVehicles();

      expect(vehicles.length, 1);
      expect(vehicles.first.id, vehicle.id);
      expect(vehicle.registrationNumber, 'ABC-1234'); // stored uppercase
    });

    test('the first vehicle added becomes the default', () {
      final service = VehicleService();

      final first = service.addVehicle(
        registrationNumber: 'ABC-1234',
        brand: 'Toyota',
        model: 'Prius',
        colour: 'White',
        vehicleType: VehicleType.car,
        transmission: TransmissionType.automatic,
      );

      final second = service.addVehicle(
        registrationNumber: 'XYZ-9999',
        brand: 'Honda',
        model: 'Civic',
        colour: 'Black',
        vehicleType: VehicleType.car,
        transmission: TransmissionType.manual,
      );

      expect(first.isDefault, true);
      expect(second.isDefault, false);
      expect(service.getDefaultVehicle()?.id, first.id);
    });
  });
}
