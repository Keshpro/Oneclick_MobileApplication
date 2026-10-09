import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/shared_record.dart';

class SharingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged-in user found.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _sharedRecordsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('sharedRecords');
  }

  Future<void> shareRecord({
    required String recordTitle,
    required String recipientName,
    required String recipientEmail,
    required String permission,
    DateTime? expiryDate,
  }) async {
    final doc = _sharedRecordsCollection.doc();

    final sharedRecord = SharedRecord(
      id: doc.id,
      ownerId: _userId,
      recordTitle: recordTitle,
      recipientName: recipientName,
      recipientEmail: recipientEmail,
      permission: permission,
      status: 'Active',
      expiryDate: expiryDate,
      createdAt: DateTime.now(),
    );

    await doc.set(sharedRecord.toMap());
  }

  Stream<List<SharedRecord>> getSharedRecords() {
    return _sharedRecordsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SharedRecord.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> revokeAccess(String sharedRecordId) async {
    await _sharedRecordsCollection.doc(sharedRecordId).update({
      'status': 'Revoked',
    });
  }

  Future<void> deleteSharedRecord(String sharedRecordId) async {
    await _sharedRecordsCollection.doc(sharedRecordId).delete();
  }
}