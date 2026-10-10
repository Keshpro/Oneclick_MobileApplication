import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import 'home_screen.dart';

// Admin Dashboard
import '../../../admin/screens/admin_dashboard.dart';


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

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Close keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('--------------------------------');
      debugPrint('LOGIN STARTED');
      debugPrint('Email: ${_emailController.text.trim()}');

      // ========================================================
      // FIREBASE LOGIN
      // ========================================================

      // AuthService logs the user in and returns the user's role
      final role = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      debugPrint('LOGIN SUCCESS');
      debugPrint('USER ROLE: $role');
      debugPrint('--------------------------------');

      if (!mounted) return;

      // Convert role to lowercase so Admin/admin/ADMIN all work
      final String userRole = role.toString().trim().toLowerCase();

      // ========================================================
      // ADMIN LOGIN
      // ========================================================

      if (userRole == 'admin') {
        debugPrint('ADMIN DETECTED');
        debugPrint('REDIRECTING TO ADMIN DASHBOARD');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (Route<dynamic> route) => false,
        );

        return;
      }

      // ========================================================
      // NORMAL USER LOGIN
      // ========================================================

      debugPrint('NORMAL USER DETECTED');
      debugPrint('REDIRECTING TO HOME SCREEN');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('--------------------------------');
      debugPrint('LOGIN ERROR');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('--------------------------------');

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
          duration: const Duration(seconds: 3),
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

  // ============================================================
  // REGISTER
  // ============================================================

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                const SizedBox(height: 70),

                // =================================================
                // ICON
                // =================================================
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

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5B4DFF).withValues(alpha: 0.25),

                        blurRadius: 20,

                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // TITLE
                // =================================================
                const Text(
                  'Welcome Back',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF120F2E),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login to continue to OneClick',

                  textAlign: TextAlign.center,

                  style: TextStyle(color: Color(0xFF6B6584), fontSize: 14),
                ),

                const SizedBox(height: 36),

                // =================================================
                // EMAIL
                // =================================================
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

                  textInputAction: TextInputAction.next,

                  autofillHints: const [AutofillHints.email],

                  decoration: InputDecoration(
                    hintText: 'Enter your email',

                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF5B4DFF),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                      horizontal: 16,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: const BorderSide(color: Color(0xFFE7E3FB)),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: const BorderSide(
                        color: Color(0xFF5B4DFF),
                        width: 1.5,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // =================================================
                // PASSWORD
                // =================================================
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

                  textInputAction: TextInputAction.done,

                  autofillHints: const [AutofillHints.password],

                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _login();
                    }
                  },

                  decoration: InputDecoration(
                    hintText: 'Enter your password',

                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF5B4DFF),
                    ),

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

                        color: const Color(0xFF6B6584),
                      ),
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                      horizontal: 16,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: const BorderSide(color: Color(0xFFE7E3FB)),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: const BorderSide(
                        color: Color(0xFF5B4DFF),
                        width: 1.5,
                      ),
                    ),

                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),

                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // =================================================
                // LOGIN BUTTON
                // =================================================
                SizedBox(
                  height: 54,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4DFF),

                      foregroundColor: Colors.white,

                      disabledBackgroundColor: const Color(0xFF5B4DFF)
                          .withValues(alpha: 0.55),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,

                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Text(
                                'Login',

                                style: TextStyle(
                                  fontSize: 15,

                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              SizedBox(width: 8),

                              Icon(Icons.arrow_forward_rounded, size: 19),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // =================================================
                // REGISTER
                // =================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text(
                      "Don't have an account? ",

                      style: TextStyle(color: Color(0xFF6B6584)),
                    ),

                    GestureDetector(
                      onTap: _isLoading ? null : _goToRegister,

                      child: const Text(
                        'Register',

                        style: TextStyle(
                          color: Color(0xFF5B4DFF),

                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
