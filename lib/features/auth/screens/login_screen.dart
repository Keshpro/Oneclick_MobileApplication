import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'package:oneclick/admin/screens/admin_dashboard.dart';

class AuthService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    // 1. Firebase Authentication මඟින් ලොග් වීම
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.trim(), password: password);

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to sign in. Please try again.',
      );
    }

    // 2. Firestore එකේ 'users' collection එකෙන් role එක පරීක්ෂා කිරීම
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
        
    if (userDoc.exists) {
      final data = userDoc.data();
      final role = data?['role'];
      if (role != null) {
        return role.toString().trim().toLowerCase();
      }
    }

    // 3. doctors හෝ drivers collection වල ඇත්දැයි බැලීම
    final doctorDoc =
        await FirebaseFirestore.instance.collection('doctors').doc(uid).get();
    if (doctorDoc.exists) {
      return 'doctor';
    }

    final driverDoc =
        await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
    if (driverDoc.exists) {
      return 'driver';
    }

    return 'user';
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Registration flow is not available yet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Pending')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your account is pending approval. Please wait for activation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Provider (Doctor/Driver) ලාගේ status එක පරීක්ෂා කිරීම
  Future<void> _checkProviderStatusAndNavigate(String uid, String role) async {
    final firestore = FirebaseFirestore.instance;
    final collection = role == 'doctor' ? 'doctors' : 'drivers';

    final doc = await firestore.collection(collection).doc(uid).get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final status = data?['status'] ?? 'pending';

      if (status != 'active') {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PendingApprovalScreen()),
          (Route<dynamic> route) => false,
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. AuthService හරහා ලොග් වී role එක ලබා ගැනීම
      final role = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // 2. Role එක 'admin' නම් කෙලින්ම AdminDashboard වෙත යැවීම
      if (role == 'admin') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      // 3. අනෙකුත් role (doctor, driver, user) සඳහා අදාළ තිර වෙත යැවීම
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && (role == 'doctor' || role == 'driver')) {
        await _checkProviderStatusAndNavigate(currentUser.uid, role);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 70),
                Container(
                  width: 82,
                  height: 82,
                  margin: const EdgeInsets.symmetric(horizontal: 120),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5B4DFF), Color(0xFF2E1FA6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF120F2E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to continue to OneClick',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B6584), fontSize: 14),
                ),
                const SizedBox(height: 36),
                const Text(
                  'Email Address',
                  style: TextStyle(
                    color: Color(0xFF120F2E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFF5B4DFF)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(
                    color: Color(0xFF120F2E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: Color(0xFF5B4DFF)),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4DFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}