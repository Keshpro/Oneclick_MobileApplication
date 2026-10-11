import '../models/incident_model.dart';

class IncidentService {
  static final List<IncidentModel> _incidents = [];

  IncidentModel reportIncident({
    required String bookingId,
    required String reportedBy,
    required IncidentType type,
    required String description,
  }) {
    final incident = IncidentModel(
      id: 'incident-${DateTime.now().microsecondsSinceEpoch}',
      bookingId: bookingId,
      reportedBy: reportedBy,
      type: type,
      description: description.trim(),
      createdAt: DateTime.now(),
    );

    _incidents.add(incident);

    return incident;
  }

  List<IncidentModel> getIncidentsForBooking(String bookingId) {
    final incidents = _incidents
        .where((incident) => incident.bookingId == bookingId)
        .toList();

    incidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return incidents;
  }

  void debugResetForTests() {
    _incidents.clear();
  }
}
