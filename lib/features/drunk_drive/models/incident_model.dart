enum IncidentType {
  accident,
  vehicleProblem,
  passengerIssue,
  safetyConcern,
  other,
}

extension IncidentTypeLabel on IncidentType {
  String get label {
    switch (this) {
      case IncidentType.accident:
        return 'Accident';
      case IncidentType.vehicleProblem:
        return 'Vehicle Problem';
      case IncidentType.passengerIssue:
        return 'Passenger Issue';
      case IncidentType.safetyConcern:
        return 'Safety Concern';
      case IncidentType.other:
        return 'Other';
    }
  }
}

class IncidentModel {
  final String id;
  final String bookingId;
  final String reportedBy;
  final IncidentType type;
  final String description;
  final DateTime createdAt;

  const IncidentModel({
    required this.id,
    required this.bookingId,
    required this.reportedBy,
    required this.type,
    required this.description,
    required this.createdAt,
  });
}