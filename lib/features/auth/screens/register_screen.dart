import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.initialRole,
  });

  final String initialRole;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  static const _roleNames = <String, String>{
    'patient': 'Patient',
    'doctor': 'Doctor',
    'passenger': 'Passenger',
    'driver': 'Driver',
  };

  bool get _needsApproval =>
      widget.initialRole == 'doctor' ||
      widget.initialRole == 'driver';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Never allow an unexpected role or admin role from this screen.
    if (!_roleNames.containsKey(widget.initialRole)) {
      _showMessage('Invalid role selected.');
      return;
    }

    setState(() => _loading = true);

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Could not create the account.');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'role': widget.initialRole,
        'status': _needsApproval ? 'pending' : 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await user.updateDisplayName(_nameController.text.trim());

      if (!mounted) return;

      // This route checks role + status and opens the correct screen.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/role-gate',
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      String message;

      switch (error.code) {
        case 'email-already-in-use':
          message = 'මේ email එකට දැනටමත් account එකක් තියෙනවා.';
          break;
        case 'invalid-email':
          message = 'වලංගු email address එකක් ඇතුළත් කරන්න.';
          break;
        case 'weak-password':
          message = 'තවත් ශක්තිමත් password එකක් යොදන්න.';
          break;
        default:
          message = error.message ?? 'Registration අසාර්ථකයි.';
      }

      _showMessage(message);
    } catch (_) {
      _showMessage(
        'Account එක සෑදීමේදී ගැටලුවක් ඇති වුණා. '
        'නැවත උත්සාහ කරන්න.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
    final roleName =
        _roleNames[widget.initialRole] ?? widget.initialRole;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
      ),
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
                      'Join OneClick',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your account to get started.',
                    ),
                    const SizedBox(height: 24),

                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Registering as',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(roleName),
                    ),

                    if (_needsApproval) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Doctor and driver accounts require admin '
                        'approval before you can use the dashboard.',
                      ),
                    ],

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your full name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

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
                        final email = value?.trim() ?? '';

                        if (!RegExp(
                          r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [
                        AutofillHints.telephoneNumber,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your phone number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      autofillHints: const [
                        AutofillHints.newPassword,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 8) {
                          return 'Use at least 8 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmPassword,
                      autofillHints: const [
                        AutofillHints.newPassword,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _hideConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _hideConfirmPassword =
                                  !_hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    FilledButton(
                      onPressed: _loading ? null : _register,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create account'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LoginScreen(),
                                ),
                              );
                            },
                      child: const Text(
                        'Already have an account? Log in',
                      ),
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