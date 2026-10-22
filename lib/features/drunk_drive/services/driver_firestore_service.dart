import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/driver_application_model.dart';

class DriverFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('drunkDriveDriverApplications');

  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Please sign in first.');
    }
    return user.uid;
  }

  Future<DriverApplicationModel?> getMyApplication() async {
    final doc = await _applications.doc(currentUserId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return _fromMap(doc.id, doc.data()!);
  }

  Future<bool> isCurrentDriverApproved() async {
    final application = await getMyApplication();
    return application?.status == DriverApplicationStatus.approved;
  }

  /// Returns the driver's saved availability. Drivers without an approved
  /// application are always treated as offline.
  Future<bool> getMyOnlineStatus() async {
    final doc = await _applications.doc(currentUserId).get();
    final data = doc.data();
    if (data == null ||
        data['status'] != DriverApplicationStatus.approved.name) {
      return false;
    }
    return data['isOnline'] == true;
  }

  /// Persists availability. The transaction checks current approval before
  /// allowing a driver to go online (or update their existing status).
  Future<void> setMyOnlineStatus(bool isOnline) async {
    final reference = _applications.doc(currentUserId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists ||
          snapshot.data()?['status'] != DriverApplicationStatus.approved.name) {
        throw StateError('Only approved drivers can change availability.');
      }
      transaction.update(reference, {
        'isOnline': isOnline,
        'onlineStatusUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  CollectionReference<Map<String, dynamic>> _declinedBookings(String userId) =>
      _applications.doc(userId).collection('declinedBookings');

  /// Booking IDs that this driver has declined, so they can remain hidden
  /// even after restarting the app.
  Future<Set<String>> getMyDeclinedBookingIds() async {
    final snapshots = await _declinedBookings(currentUserId).get();
    return snapshots.docs.map((doc) => doc.id).toSet();
  }

  /// Records a decline only for the signed-in driver. Other drivers can still
  /// see and accept the booking. The dashboard must filter these IDs locally.
  Future<void> declineBooking(String bookingId) async {
    if (bookingId.trim().isEmpty || bookingId.contains('/')) {
      throw ArgumentError.value(bookingId, 'bookingId', 'Invalid booking ID.');
    }
    if (!await isCurrentDriverApproved()) {
      throw StateError('Only approved drivers can decline requests.');
    }
    await _declinedBookings(currentUserId).doc(bookingId).set({
      'bookingId': bookingId,
      'declinedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> submitApplication(DriverApplicationModel application) async {
    if (application.userId != currentUserId) {
      throw StateError('You can only submit your own application.');
    }

    await _applications.doc(currentUserId).set({
      'userId': currentUserId,
      'fullName': application.fullName,
      'dateOfBirth': application.dateOfBirth,
      'phone': application.phone,
      'address': application.address,
      'licenceNumber': application.licenceNumber,
      'licenceType': application.licenceType,
      'licenceExpiry': application.licenceExpiry,
      'drivingExperienceYears': application.drivingExperienceYears,
      'canDriveManual': application.canDriveManual,
      'canDriveAutomatic': application.canDriveAutomatic,
      'documentType': application.documentType,
      'documentNumber': application.documentNumber,
      'documentPhotoPath': application.documentPhotoPath,
      'status': DriverApplicationStatus.pending.name,
      'adminNotes': null,
      'submittedAt': FieldValue.serverTimestamp(),
      'isOnline': false,
      'onlineStatusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  DriverApplicationModel _fromMap(String id, Map<String, dynamic> data) {
    final statusName = data['status'] as String? ?? 'pending';

    final status = DriverApplicationStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => DriverApplicationStatus.pending,
    );

    final submittedAt = data['submittedAt'];

    return DriverApplicationModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      dateOfBirth: data['dateOfBirth'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      licenceNumber: data['licenceNumber'] as String? ?? '',
      licenceType: data['licenceType'] as String? ?? '',
      licenceExpiry: data['licenceExpiry'] as String? ?? '',
      drivingExperienceYears:
          (data['drivingExperienceYears'] as num?)?.toInt() ?? 0,
      canDriveManual: data['canDriveManual'] as bool? ?? false,
      canDriveAutomatic: data['canDriveAutomatic'] as bool? ?? false,
      documentType: data['documentType'] as String? ?? '',
      documentNumber: data['documentNumber'] as String? ?? '',
      documentPhotoPath: data['documentPhotoPath'] as String?,
      status: status,
      adminNotes: data['adminNotes'] as String?,
      submittedAt: submittedAt is Timestamp
          ? submittedAt.toDate()
          : DateTime.now(),
    );
  }
}
