import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService();

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // 1. Firebase Authentication
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('User registration failed. Please try again.');
    }

   
    await user.updateDisplayName(name.trim());

    final normalizedRole = role.trim().toLowerCase();

  
    if (normalizedRole == 'doctor') {
      await firestore.collection('doctors').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'doctor',
        'status': 'pending', 
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
        'providerDetails': {
          'specialization': 'General Physician',
          'hospital': 'General Hospital',
          'experienceYears': '5',
        },
      });
    } else if (normalizedRole == 'driver') {
     
      await firestore.collection('drivers').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'driver',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }


    await firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name.trim(),
      'email': email.trim(),
      'role': normalizedRole,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }
}