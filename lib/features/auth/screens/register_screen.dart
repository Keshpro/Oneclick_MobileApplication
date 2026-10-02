import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../../shared/models/user_model.dart';
import 'pending_approval_screen.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;

  const RegisterScreen({
    super.key,
    required this.role,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Roles that need admin approval
  bool get _requiresApproval {
    final role = widget.role.name.toLowerCase();

    return role == 'doctor' ||
        role == 'driver';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: widget.role.name,
      );

      if (!mounted) return;

      // Provider account
      if (_requiresApproval) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const PendingApprovalScreen(),
          ),
          (route) => false,
        );

        return;
      }

      // Normal account
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      /*
       * Normal user is already authenticated here.
       *
       * Later we will redirect this user to the
       * correct dashboard using RoleRouter.
       */

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

  @override
  Widget build(BuildContext context) {
    final roleName = widget.role.name.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Register as $roleName'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // -------------------------------
                // TITLE
                // -------------------------------

                Text(
                  'Create $roleName Account',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _requiresApproval
                      ? 'Your account will be reviewed by an administrator before access is granted.'
                      : 'Create your account to continue.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 32),

                // -------------------------------
                // FULL NAME
                // -------------------------------

                TextFormField(
                  controller: _nameController,

                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }

                    if (value.trim().length < 3) {
                      return 'Please enter a valid name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // -------------------------------
                // EMAIL
                // -------------------------------

                TextFormField(
                  controller: _emailController,

                  keyboardType: TextInputType.emailAddress,

                  textInputAction: TextInputAction.next,

                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }

                    final emailRegex = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // -------------------------------
                // PASSWORD
                // -------------------------------

                TextFormField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  textInputAction: TextInputAction.next,

                  decoration: InputDecoration(
                    labelText: 'Password',

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),

                    border: const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },

                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // -------------------------------
                // CONFIRM PASSWORD
                // -------------------------------

                TextFormField(
                  controller: _confirmPasswordController,

                  obscureText: _obscureConfirmPassword,

                  textInputAction: TextInputAction.done,

                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _register();
                    }
                  },

                  decoration: InputDecoration(
                    labelText: 'Confirm Password',

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),

                    border: const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },

                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // -------------------------------
                // REGISTER BUTTON
                // -------------------------------

                ElevatedButton(
                  onPressed:
                      _isLoading ? null : _register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),

                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'REGISTER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                if (_requiresApproval) ...[
                  const SizedBox(height: 18),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          'Provider accounts require administrator verification.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}