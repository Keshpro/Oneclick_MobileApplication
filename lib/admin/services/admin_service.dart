import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Pending ගිණුම් පමණක් Stream එකක් ලෙස ලබා ගැනීම
  Stream<List<UserModel>> getPendingUsers() {
    return _db
        .collection('users')
        .where('status', isEqualTo: AccountStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // සියලුම Users ලාව Stream එකක් ලෙස ලබා ගැනීම (Full CRUD)
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList());
  }

  // User ගේ Status එක (Approved / Rejected) Update කිරීම
  Future<void> updateUserStatus(String uid, AccountStatus status) async {
    await _db.collection('users').doc(uid).update({
      'status': status.name,
    });
  }

  // User ව සිස්ටම් එකෙන් Delete කිරීම
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // User ගේ Role එක Update කිරීම
  Future<void> updateUserRole(String uid, UserRole newRole) async {
    await _db.collection('users').doc(uid).update({
      'role': newRole.name,
    });
  }
}

class FirebaseFirestore {
  static FirebaseFirestore get instance => null;
}