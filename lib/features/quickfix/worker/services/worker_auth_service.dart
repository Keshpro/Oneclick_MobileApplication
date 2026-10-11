
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerAuthService {
  WorkerAuthService._();

  static final WorkerAuthService instance = WorkerAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workers =>
      _firestore.collection('workers');

  // Register a new worker and generate a unique username.
  Future<Map<String, dynamic>> registerWorker({
    required String name,
    required String phone,
    required String category,
    required String area,
    required String password,
  }) async {
    UserCredential? credential;

    final username = 'worker${DateTime.now().microsecondsSinceEpoch}';
    final authEmail = '$username@quickfixworker.com';

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Unable to create worker account.');
      }

      final workerData = <String, dynamic>{
        'uid': user.uid,
        'name': name.trim(),
        'username': username,
        'authEmail': authEmail,
        'phone': phone.trim(),
        'category': category,
        'area': area,
        'rating': 0.0,
        'jobsCompleted': 0,
        'experience': 0,
        'isOnline': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _workers.doc(user.uid).set(workerData);

      // Sign out after registration so the worker can login.
      await _auth.signOut();

      return workerData;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    } catch (e) {
      // Delete the newly created Auth account if profile saving fails.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Preserve the original error.
        }
      }

      if (e is Exception) rethrow;
      throw Exception('Worker registration failed.');
    }
  }

  // Login using the generated username and password.
  Future<UserCredential> loginWorker({
    required String username,
    required String password,
  }) async {
    try {
      final query = await _workers
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Invalid username or password.');
      }

      final workerData = query.docs.first.data();
      final authEmail = workerData['authEmail']?.toString();

      if (authEmail == null || authEmail.isEmpty) {
        throw Exception('Worker login details are incomplete.');
      }

      return await _auth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email') {
        throw Exception('Invalid username or password.');
      }

      throw Exception(_authErrorMessage(e));
    }
  }

  // Get the currently logged-in worker's profile.
  Future<Map<String, dynamic>?> getCurrentWorker() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document = await _workers.doc(user.uid).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  // Update the logged-in worker's profile in Firestore.
  Future<void> updateWorkerProfile({
    required String name,
    required String phone,
    required String category,
    required String area,
    required int experience,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please login to update your profile.');
    }

    await _workers.doc(user.uid).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'category': category.trim(),
      'area': area.trim(),
      'experience': experience,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Logout method used by WorkerMainScreen.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Alternative logout method for other screens.
  Future<void> logoutWorker() async {
    await _auth.signOut();
  }

  // Convert Firebase Auth errors into readable messages.
  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This account already exists. Please login.';

      case 'weak-password':
        return 'Please choose a stronger password.';

      case 'invalid-email':
        return 'Invalid account email format.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase.';

      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
