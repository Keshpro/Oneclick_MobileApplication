enum DriverApplicationStatus {
  pending,
  approved,
  rejected,
  moreInfoRequired,
  suspended,
}

extension DriverApplicationStatusLabel on DriverApplicationStatus {
  String get label {
    switch (this) {
      case DriverApplicationStatus.pending:
        return 'UNDER REVIEW';
      case DriverApplicationStatus.approved:
        return 'APPROVED';
      case DriverApplicationStatus.rejected:
        return 'REJECTED';
      case DriverApplicationStatus.moreInfoRequired:
        return 'MORE INFO REQUIRED';
      case DriverApplicationStatus.suspended:
        return 'SUSPENDED';
    }
  }
}

class DriverApplicationModel {
  final String id;
  final String userId;
  final String fullName;
  final String dateOfBirth;
  final String phone;
  final String address;
  final String licenceNumber;
  final String licenceType;
  final String licenceExpiry;
  final int drivingExperienceYears;
  final bool canDriveManual;
  final bool canDriveAutomatic;
  final String documentType;
  final String documentNumber;
  final String? documentPhotoPath;
  final DriverApplicationStatus status;
  final String? adminNotes;
  final DateTime submittedAt;

  const DriverApplicationModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.phone,
    required this.address,
    required this.licenceNumber,
    required this.licenceType,
    required this.licenceExpiry,
    required this.drivingExperienceYears,
    required this.canDriveManual,
    required this.canDriveAutomatic,
    required this.documentType,
    required this.documentNumber,
    this.documentPhotoPath,
    required this.status,
    this.adminNotes,
    required this.submittedAt,
  });

  DriverApplicationModel copyWith({
    DriverApplicationStatus? status,
    String? adminNotes,
  }) {
    return DriverApplicationModel(
      id: id,
      userId: userId,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      phone: phone,
      address: address,
      licenceNumber: licenceNumber,
      licenceType: licenceType,
      licenceExpiry: licenceExpiry,
      drivingExperienceYears: drivingExperienceYears,
      canDriveManual: canDriveManual,
      canDriveAutomatic: canDriveAutomatic,
      documentType: documentType,
      documentNumber: documentNumber,
      documentPhotoPath: documentPhotoPath,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      submittedAt: submittedAt,
    );
  }
}
