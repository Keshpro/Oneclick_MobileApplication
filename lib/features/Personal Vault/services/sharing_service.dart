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

  String get _userEmail {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw Exception('No logged-in user email found.');
    }

    return user.email!;
  }

  CollectionReference<Map<String, dynamic>> get _sharedRecordsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('sharedRecords');
  }

  CollectionReference<Map<String, dynamic>> get _globalSharedRecordsCollection {
    return _firestore.collection('sharedRecords');
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

    final data = sharedRecord.toMap();

    data['ownerEmail'] = _userEmail;

    final batch = _firestore.batch();

    batch.set(
      doc,
      data,
    );

    batch.set(
      _globalSharedRecordsCollection.doc(doc.id),
      data,
    );

    await batch.commit();
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

  Stream<List<SharedRecord>> getReceivedRecords() {
    final email = _userEmail.toLowerCase();

    return _globalSharedRecordsCollection
        .where('recipientEmail', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map(
            (doc) => SharedRecord.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .where((record) => record.status != 'Revoked')
          .toList();

      records.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return records;
    });
  }

  Future<void> revokeAccess(String sharedRecordId) async {
    final batch = _firestore.batch();

    batch.update(
      _sharedRecordsCollection.doc(sharedRecordId),
      {
        'status': 'Revoked',
      },
    );

    batch.update(
      _globalSharedRecordsCollection.doc(sharedRecordId),
      {
        'status': 'Revoked',
      },
    );

    await batch.commit();
  }

  Future<void> deleteSharedRecord(String sharedRecordId) async {
    final batch = _firestore.batch();

    batch.delete(
      _sharedRecordsCollection.doc(sharedRecordId),
    );

    batch.delete(
      _globalSharedRecordsCollection.doc(sharedRecordId),
    );

    await batch.commit();
  }
}