import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/vault_record.dart';

class VaultService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String get _userId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No logged-in user found.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _recordsCollection {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('vaultRecords');
  }

  Future<String?> uploadFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final safeFileName =
        '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    final ref = _storage
        .ref()
        .child('users')
        .child(_userId)
        .child('vault')
        .child(safeFileName);

    debugPrint('VAULT: Starting file upload...');

await ref.putData(bytes);

debugPrint('VAULT: Upload finished. Getting download URL...');

final url = await ref.getDownloadURL();

debugPrint('VAULT: Download URL received: $url');

return url;
  }

  Future<void> addRecord({
    required String title,
    required String recordType,
    required String category,
    required String notes,
    required List<String> tags,
    required DateTime renewalDate,
    required bool expiryNotification,
    String? fileName,
    String? fileUrl,
  }) async {
    final doc = _recordsCollection.doc();

    final record = VaultRecord(
      id: doc.id,
      userId: _userId,
      title: title,
      recordType: recordType,
      category: category,
      notes: notes,
      tags: tags,
      renewalDate: renewalDate,
      expiryNotification: expiryNotification,
      fileName: fileName,
      fileUrl: fileUrl,
      createdAt: DateTime.now(),
    );

    await doc.set(record.toMap());
  }

Future<void> deleteRecord(String recordId) async {
  await _recordsCollection.doc(recordId).delete();
}
Future<void> updateRecord({
  required String recordId,
  required String title,
  required String category,
  required String recordType,
  required String notes,
  required List<String> tags,
}) async {
  await _recordsCollection.doc(recordId).update({
    'title': title,
    'category': category,
    'recordType': recordType,
    'notes': notes,
    'tags': tags,
  });
}
  Stream<List<VaultRecord>> getRecords() {
    return _recordsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => VaultRecord.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}