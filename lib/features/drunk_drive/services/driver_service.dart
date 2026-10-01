import '../models/driver_application_model.dart';
import 'vehicle_service.dart';

class DriverService {
  static final List<DriverApplicationModel> _applications = [];

  /// Returns driver application for current user if it exists.
  DriverApplicationModel? getMyApplication() {
    for (final app in _applications) {
      if (app.userId == VehicleService.currentUserId) {
        return app;
      }
    }
    return null;
  }

  /// True if current user has an approved application.
  bool isCurrentDriverApproved() {
    final myApp = getMyApplication();
    return myApp?.status == DriverApplicationStatus.approved;
  }

  /// Submit a new driver application for verification.
  DriverApplicationModel submitApplication({
    required String fullName,
    required String dateOfBirth,
    required String phone,
    required String address,
    required String licenceNumber,
    required String licenceType,
    required String licenceExpiry,
    required int drivingExperienceYears,
    required bool canDriveManual,
    required bool canDriveAutomatic,
    required String documentType,
    required String documentNumber,
    String? documentPhotoPath,
  }) {
    final existing = getMyApplication();
    if (existing != null) {
      // Overwrite / re-submit if previously submitted
      _applications.removeWhere((app) => app.userId == VehicleService.currentUserId);
    }

    final application = DriverApplicationModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: VehicleService.currentUserId,
      fullName: fullName.trim(),
      dateOfBirth: dateOfBirth.trim(),
      phone: phone.trim(),
      address: address.trim(),
      licenceNumber: licenceNumber.trim().toUpperCase(),
      licenceType: licenceType.trim(),
      licenceExpiry: licenceExpiry.trim(),
      drivingExperienceYears: drivingExperienceYears,
      canDriveManual: canDriveManual,
      canDriveAutomatic: canDriveAutomatic,
      documentType: documentType.trim(),
      documentNumber: documentNumber.trim(),
      documentPhotoPath: documentPhotoPath,
      status: DriverApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );

    _applications.add(application);
    return application;
  }

  /// Helper for Admin team / testing to approve or reject an application.
  void debugUpdateStatus(String applicationId, DriverApplicationStatus status, {String? notes}) {
    final index = _applications.indexWhere((app) => app.id == applicationId);
    if (index != -1) {
      _applications[index] = _applications[index].copyWith(status: status, adminNotes: notes);
    }
  }

  static void debugResetForTests() => _applications.clear();
}
