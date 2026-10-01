import 'package:flutter_test/flutter_test.dart';
import 'package:oneclick/features/drunk_drive/models/driver_application_model.dart';
import 'package:oneclick/features/drunk_drive/services/driver_service.dart';
import 'package:oneclick/features/drunk_drive/services/vehicle_service.dart';

void main() {
  setUp(() {
    DriverService.debugResetForTests();
    VehicleService.debugResetForTests();
  });

  group('DriverService', () {
    test('submits driver application with PENDING status initially', () {
      final service = DriverService();

      final app = service.submitApplication(
        fullName: 'John Doe',
        dateOfBirth: '1995-05-12',
        phone: '0712345678',
        address: '123 Main St, Kandy',
        licenceNumber: 'B9876543',
        licenceType: 'Light Car',
        licenceExpiry: '2030-01-01',
        drivingExperienceYears: 5,
        canDriveManual: true,
        canDriveAutomatic: true,
        documentType: 'National Identity Card (NIC)',
        documentNumber: '951330999V',
      );

      expect(app.status, DriverApplicationStatus.pending);
      expect(service.getMyApplication()?.id, app.id);
      expect(service.isCurrentDriverApproved(), false);
    });

    test('isCurrentDriverApproved returns true only when status is APPROVED', () {
      final service = DriverService();

      final app = service.submitApplication(
        fullName: 'John Doe',
        dateOfBirth: '1995-05-12',
        phone: '0712345678',
        address: '123 Main St, Kandy',
        licenceNumber: 'B9876543',
        licenceType: 'Light Car',
        licenceExpiry: '2030-01-01',
        drivingExperienceYears: 5,
        canDriveManual: true,
        canDriveAutomatic: true,
        documentType: 'NIC',
        documentNumber: '951330999V',
      );

      expect(service.isCurrentDriverApproved(), false);

      service.debugUpdateStatus(app.id, DriverApplicationStatus.approved);
      expect(service.isCurrentDriverApproved(), true);
    });
  });
}
