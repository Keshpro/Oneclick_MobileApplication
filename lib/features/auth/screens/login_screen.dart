import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/role-gate',
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      String message;

      switch (error.code) {
        case 'invalid-email':
          message = 'වලංගු email address එකක් ඇතුළත් කරන්න.';
          break;
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'Email හෝ password වැරදියි.';
          break;
        case 'too-many-requests':
          message = 'උත්සාහයන් වැඩියි. ටික වේලාවකින් නැවත උත්සාහ කරන්න.';
          break;
        default:
          message = error.message ?? 'Login අසාර්ථකයි.';
      }

      _showMessage(message);
    } catch (_) {
      _showMessage('Login වීමේදී ගැටලුවක් ඇති වුණා.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _showMessage('මුලින් ඔබගේ email address එක ඇතුළත් කරන්න.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset link එක email එකට යවා ඇත.');
    } on FirebaseAuthException catch (error) {
      _showMessage(error.message ?? 'Reset email එක යැවීමට නොහැකි වුණා.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log in')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Log in to continue using the app.'),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () => _hidePassword = !_hidePassword,
                            );
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading ? null : _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: _loading ? null : _login,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Log in'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const RoleSelectionScreen(),
                                ),
                              );
                            },
                      child: const Text("Don't have an account? Register"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}