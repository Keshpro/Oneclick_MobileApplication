import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'register_screen.dart'; // Direct RegisterScreen import
import 'package:oneclick/admin/screens/admin_dashboard.dart';
import 'package:oneclick/features/doctor/doctor/screens/doctor_dashboard.dart';
import 'package:oneclick/features/quickfix/worker/screens/worker_dashboard.dart'; // Worker Dashboard Import
import '../../../shared/models/user_model.dart';
import 'package:oneclick/core/theme/app_theme.dart'; // UI only: Fresh Teal tokens

class AuthService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    // 1. Firebase Authentication sign in
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.trim(), password: password);

    final uid = userCredential.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to sign in. Please try again.',
      );
    }

    // 2. Firestore 'users' collection check
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final data = userDoc.data();
      final role = data?['role'];
      if (role != null) {
        return role.toString().trim().toLowerCase();
      }
    }

    // 3. Provider collections check (workers, doctors, drivers, food_sellers)
    final workerDoc =
        await FirebaseFirestore.instance.collection('workers').doc(uid).get();
    if (workerDoc.exists) {
      return 'worker';
    }

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

    final foodSellerDoc =
        await FirebaseFirestore.instance.collection('food_sellers').doc(uid).get();
    if (foodSellerDoc.exists) {
      return 'foodSeller';
    }

    return 'user';
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Approval Pending'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top_rounded, size: 48, color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Your account is pending approval. Please wait for activation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.textDark),
              ),
            ],
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

  // Direct route to RegisterScreen
  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen(role: UserRole.user)),
    );
  }

  // Provider (Worker/Doctor/Driver) status and dashboard routing
  Future<void> _checkProviderStatusAndNavigate(String uid, String role) async {
    final firestore = FirebaseFirestore.instance;

    String collection = 'users';
    if (role == 'worker') collection = 'workers';
    if (role == 'doctor') collection = 'doctors';
    if (role == 'driver') collection = 'drivers';
    if (role == 'foodSeller') collection = 'food_sellers';

    final doc = await firestore.collection(collection).doc(uid).get();

    if (doc.exists) {
      final data = doc.data();
      final status = data?['status'] ?? 'pending';

      if (status == 'active' || status == 'approved') {
        if (!mounted) return;

        // Worker Dashboard Navigation
        if (role == 'worker') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const WorkerDashboard(),
            ),
            (Route<dynamic> route) => false,
          );
          return;
        }

        // Doctor Dashboard Navigation
        if (role == 'doctor') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DoctorDashboardScreen(),
            ),
            (Route<dynamic> route) => false,
          );
          return;
        }

        // Driver / Food Seller / Active Users Navigation
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
        return;
      } else {
        // Pending approval screen for pending providers
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const PendingApprovalScreen(),
          ),
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
      // 1. Get user role from AuthService
      final role = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // 2. Role 'admin' -> AdminDashboard
      if (role == 'admin') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      // 3. Provider roles handling
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null &&
          (role == 'worker' || role == 'doctor' || role == 'driver' || role == 'foodSeller')) {
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

  // ==============================================================
  // UI ONLY (Fresh Teal). Everything above this line is unchanged.
  // ==============================================================
  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    const lineColor = Color(0xFFD9ECEA);
    OutlineInputBorder outline(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: outline(lineColor),
      enabledBorder: outline(lineColor),
      focusedBorder: outline(AppColors.primary, 1.5),
      errorBorder: outline(Colors.red),
      focusedErrorBorder: outline(Colors.red, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Teal header: back button, logo, title
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.paddingOf(context).top + 16,
                      20,
                      32,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(AppRadius.button),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(AppRadius.button),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textDark.withValues(alpha: .20),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_person_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login to continue to OneClick',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _fieldDecoration(
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
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
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _fieldDecoration(
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Direct link to RegisterScreen
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: _goToRegister,
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}