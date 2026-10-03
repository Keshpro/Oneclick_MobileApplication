import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current logged-in user
  User? get currentUser => _auth.currentUser;

  // Auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // REGISTER
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    UserCredential? credential;

    try {
      // 1. Create Firebase Auth account
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Unable to create account.');
      }

      // 2. Decide whether admin approval is required
      final normalizedRole = role.trim().toLowerCase();

      const approvalRequiredRoles = {
        'doctor',
        'driver',
      };

      final requiresApproval =
          approvalRequiredRoles.contains(normalizedRole);

      final status = requiresApproval ? 'pending' : 'approved';

      // 3. Save profile in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': normalizedRole,
        'status': status,
        'requiresApproval': requiresApproval,
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt':
            requiresApproval ? null : FieldValue.serverTimestamp(),
      });

      // 4. Provider accounts must wait for admin approval
      if (requiresApproval) {
        await _auth.signOut();
      }
    } catch (e) {
      // Avoid leaving an Auth account without its Firestore profile
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {}
      }

      rethrow;
    }
  }

  // LOGIN
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Login failed.');
      }

      final document =
          await _firestore.collection('users').doc(user.uid).get();

      if (!document.exists) {
        await _auth.signOut();
        throw Exception('User profile not found.');
      }

      final data = document.data()!;

      final role =
          (data['role'] ?? 'user').toString().toLowerCase();

      final status =
          (data['status'] ?? 'pending').toString().toLowerCase();

      // Pending provider
      if (status == 'pending') {
        await _auth.signOut();
        throw Exception(
          'Your account is waiting for admin approval.',
        );
      }

      // Rejected provider
      if (status == 'rejected') {
        await _auth.signOut();
        throw Exception(
          'Your account verification was rejected.',
        );
      }

      if (status != 'approved') {
        await _auth.signOut();
        throw Exception('Account access is unavailable.');
      }

      // Successful login → return role
      return role;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          throw Exception('Invalid email or password.');

        case 'invalid-email':
          throw Exception('Please enter a valid email address.');

        case 'user-disabled':
          throw Exception('This account has been disabled.');

        case 'too-many-requests':
          throw Exception(
            'Too many attempts. Please try again later.',
          );

        default:
          throw Exception(e.message ?? 'Login failed.');
      }
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user's Firestore profile
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final document =
        await _firestore.collection('users').doc(user.uid).get();

    return document.data();
  }
}