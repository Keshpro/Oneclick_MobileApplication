import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/incident_model.dart';

/// Persists Drunk & Drive incidents in Firestore.
/// Firestore Security Rules must independently enforce booking ownership.
class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('drunkDriveIncidents');

  Future<IncidentModel> reportIncident({
    required String bookingId,
    required IncidentType type,
    required String description,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('Please sign in to report an incident.');
    }
    final trimmedBookingId = bookingId.trim();
    final trimmedDescription = description.trim();
    if (trimmedBookingId.isEmpty || trimmedDescription.isEmpty) {
      throw ArgumentError('Booking and incident description are required.');
    }

    final booking = await _db
        .collection('drunkDriveBookings')
        .doc(trimmedBookingId)
        .get();
    final bookingData = booking.data();
    if (bookingData == null ||
        (bookingData['driverId'] != userId &&
            bookingData['passengerId'] != userId)) {
      throw StateError('You cannot report an incident for this trip.');
    }

    final newDoc = _incidents.doc();
    final createdAt = DateTime.now();
    await newDoc.set({
      'bookingId': trimmedBookingId,
      'reportedBy': userId,
      'type': type.name,
      'description': trimmedDescription,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return IncidentModel(
      id: newDoc.id,
      bookingId: trimmedBookingId,
      reportedBy: userId,
      type: type,
      description: trimmedDescription,
      createdAt: createdAt,
    );
  }

  Future<List<IncidentModel>> getIncidentsForBooking(String bookingId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('Please sign in to view incident reports.');
    }
    final booking = await _db
        .collection('drunkDriveBookings')
        .doc(bookingId)
        .get();
    final data = booking.data();
    if (data == null ||
        (data['driverId'] != userId && data['passengerId'] != userId)) {
      throw StateError('You cannot view incidents for this trip.');
    }

    final snapshot = await _incidents
        .where('bookingId', isEqualTo: bookingId)
        .get();
    final incidents = snapshot.docs.map((doc) {
      final value = doc.data();
      final typeName = value['type'] as String? ?? 'other';
      final incidentType = IncidentType.values.firstWhere(
        (item) => item.name == typeName,
        orElse: () => IncidentType.other,
      );
      final timestamp = value['createdAt'];
      return IncidentModel(
        id: doc.id,
        bookingId: value['bookingId'] as String? ?? bookingId,
        reportedBy: value['reportedBy'] as String? ?? '',
        type: incidentType,
        description: value['description'] as String? ?? '',
        createdAt: timestamp is Timestamp
            ? timestamp.toDate()
            : DateTime.fromMillisecondsSinceEpoch(0),
      );
    }).toList();
    incidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return incidents;
  }
}
