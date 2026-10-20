
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/document_pack.dart';


class SavedDocumentPack {
  final String id;
  final DocumentPack pack;

  const SavedDocumentPack({
    required this.id,
    required this.pack,
  });
}

class DocumentPackService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must sign in to access document packs.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('documentPacks');
  }

  Future<String> savePack(DocumentPack pack) async {
    if (pack.name.trim().isEmpty || pack.requirements.isEmpty) {
      throw ArgumentError('A pack name and requirements are required.');
    }

    final document = _collection.doc();

    await document.set({
      ...pack.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  Stream<List<DocumentPack>> getPacks() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((document) => DocumentPack.fromMap(document.data()))
          .toList(),
    );
  }
  
  Stream<List<SavedDocumentPack>> getSavedPacks() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs.map((document) {
        return SavedDocumentPack(
          id: document.id,
          pack: DocumentPack.fromMap(document.data()),
        );
      }).toList(),
    );
  }

  Future<void> deletePack(String packId) async {
    if (packId.trim().isEmpty) {
      throw ArgumentError('Document pack ID is required.');
    }

    await _collection.doc(packId).delete();
  }
}
