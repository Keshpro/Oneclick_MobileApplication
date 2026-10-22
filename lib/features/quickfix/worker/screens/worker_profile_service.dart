import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String area,
    required int experience,
    required double hourlyRate,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Worker not logged in');
    }

    if (name.trim().isEmpty ||
        phone.trim().isEmpty ||
        area.trim().isEmpty ||
        experience < 0 ||
        !hourlyRate.isFinite ||
        hourlyRate <= 0) {
      throw Exception('Please enter valid profile details.');
    }

    final workerRef = _firestore.collection('workers').doc(user.uid);

    if (!(await workerRef.get()).exists) {
      throw Exception('Worker profile not found.');
    }

    await workerRef.update({
      'name': name.trim(),
      'phone': phone.trim(),
      'area': area.trim(),
      'providerDetails.experienceYears': experience.toString(),
      'providerDetails.hourlyRate': hourlyRate,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}