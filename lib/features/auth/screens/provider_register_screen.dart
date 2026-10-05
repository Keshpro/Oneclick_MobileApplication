import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pending_approval_screen.dart';

enum ProviderRole {
  doctor,
  driver,
  grocerySeller,
}

class ProviderRegisterScreen
    extends StatefulWidget {
  final ProviderRole role;

  const ProviderRegisterScreen({
    super.key,
    required this.role,
  });

  @override
  State<ProviderRegisterScreen> createState() =>
      _ProviderRegisterScreenState();
}

class _ProviderRegisterScreenState
    extends State<ProviderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _phoneController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  // Doctor
  final _doctorIdController =
      TextEditingController();

  final _specializationController =
      TextEditingController();

  final _experienceController =
      TextEditingController();

  // Driver
  final _licenseController =
      TextEditingController();

  final _licenseExpiryController =
      TextEditingController();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isDoctor =>
      widget.role == ProviderRole.doctor;

  String get _roleName =>
      _isDoctor ? 'Doctor' : 'Driver';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _doctorIdController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();

    _licenseController.dispose();
    _licenseExpiryController.dispose();

    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate:
          DateTime(now.year + 1),
      firstDate: now,
      lastDate:
          DateTime(now.year + 20),
    );

    if (selected == null) return;

    setState(() {
      _licenseExpiryController.text =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    UserCredential? credential;

    try {
      credential =
          await _auth
              .createUserWithEmailAndPassword(
        email:
            _emailController.text.trim(),
        password:
            _passwordController.text,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Unable to create provider account.',
        );
      }

      final providerDetails = _isDoctor
          ? {
              'doctorId':
                  _doctorIdController.text.trim(),
              'specialization':
                  _specializationController.text
                      .trim(),
              'experienceYears':
                  _experienceController.text
                      .trim(),
            }
          : {
              'drivingLicenseNumber':
                  _licenseController.text.trim(),
              'licenseExpiryDate':
                  _licenseExpiryController.text
                      .trim(),
            };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name':
            _nameController.text.trim(),
        'email': _emailController.text
            .trim()
            .toLowerCase(),
        'phone':
            _phoneController.text.trim(),

        'role': widget.role.name,

        'accountType': 'provider',

        'status': 'pending',

        'requiresApproval': true,

        'providerDetails':
            providerDetails,

        'providerAgreementAccepted':
            true,

        'createdAt':
            FieldValue.serverTimestamp(),

        'approvedAt': null,
      });

      await _auth.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PendingApprovalScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'An account already exists with this email.';
          break;

        case 'invalid-email':
          message =
              'Please enter a valid email address.';
          break;

        case 'weak-password':
          message =
              'Please use a stronger password.';
          break;

        default:
          message =
              e.message ??
              'Unable to create account.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Clean up Firebase Auth account if
      // Firestore creation fails.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {}
      }

      if (!mounted) return;

      String message = e.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        message = message.replaceFirst(
          'Exception: ',
          '',
        );
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
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
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F7FC),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF7F7FC),
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
        title: Text(
          '$_roleName Application',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            16,
            24,
            40,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Apply as a $_roleName',
                  style: const TextStyle(
                    color: Color(0xFF17152A),
                    fontSize: 28,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Complete the information below. Your application will be reviewed before your provider account is activated.',
                  style: TextStyle(
                    color: Color(0xFF747187),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                _sectionTitle(
                  'Personal Information',
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _nameController,
                  label: 'Full Name',
                  icon:
                      Icons.person_outline_rounded,
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _emailController,
                  label: 'Email Address',
                  icon:
                      Icons.email_outlined,
                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                _field(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon:
                      Icons.phone_outlined,
                  keyboardType:
                      TextInputType.phone,
                ),

                const SizedBox(height: 28),

                _sectionTitle(
                  _isDoctor
                      ? 'Professional Information'
                      : 'Driver Information',
                ),

                const SizedBox(height: 14),

                if (_isDoctor) ...[
                  _field(
                    controller:
                        _doctorIdController,
                    label:
                        'Doctor / Medical Registration ID',
                    icon: Icons
                        .badge_outlined,
                  ),

                  const SizedBox(height: 14),

                  _field(
                    controller:
                        _specializationController,
                    label: 'Specialization',
                    icon: Icons
                        .medical_information_outlined,
                  ),

                  const SizedBox(height: 14),

                  _field(
                    controller:
                        _experienceController,
                    label:
                        'Years of Experience',
                    icon:
                        Icons.work_history_outlined,
                    keyboardType:
                        TextInputType.number,
                  ),
                ] else ...[
                  _field(
                    controller:
                        _licenseController,
                    label:
                        'Driving Licence Number',
                    icon:
                        Icons.badge_outlined,
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller:
                        _licenseExpiryController,
                    readOnly: true,
                    onTap: _selectExpiryDate,
                    decoration:
                        _decoration(
                      label:
                          'Licence Expiry Date',
                      icon: Icons
                          .event_outlined,
                      suffix: const Icon(
                        Icons
                            .calendar_month_outlined,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please select licence expiry date';
                      }

                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 28),

                _sectionTitle(
                  'Account Security',
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller:
                      _passwordController,
                  obscureText:
                      _obscurePassword,
                  decoration:
                      _decoration(
                    label: 'Password',
                    icon: Icons
                        .lock_outline_rounded,
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please enter a password';
                    }

                    if (value.length < 6) {
                      return 'Password must contain at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller:
                      _confirmPasswordController,
                  obscureText:
                      _obscureConfirmPassword,
                  decoration:
                      _decoration(
                    label: 'Confirm Password',
                    icon: Icons
                        .lock_outline_rounded,
                    suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value !=
                        _passwordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                Container(
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF5B4DFF,
                    ).withValues(alpha: .06),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons
                            .verified_user_outlined,
                        color:
                            Color(0xFF5B4DFF),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your provider account will remain pending until it is reviewed and approved by OneClick.',
                          style: TextStyle(
                            color:
                                Color(0xFF5B4DFF),
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _submitApplication,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF5B4DFF),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.white,
                            ),
                          )
                        : const Text(
                            'SUBMIT APPLICATION',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w800,
                            ),
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF17152A),
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _decoration(
        label: label,
        icon: icon,
      ),
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'Please enter $label';
        }

        if (label == 'Email Address') {
          final regex = RegExp(
            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
          );

          if (!regex.hasMatch(
            value.trim(),
          )) {
            return 'Please enter a valid email address';
          }
        }

        return null;
      },
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF5B4DFF),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE4E2EC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE4E2EC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF5B4DFF),
          width: 1.5,
        ),
      ),
    );
  }
}