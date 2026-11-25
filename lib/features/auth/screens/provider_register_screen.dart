import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pending_approval_screen.dart';

enum ProviderRole { doctor, driver, grocerySeller, worker, foodSeller }

class ProviderRegisterScreen extends StatefulWidget {
  final ProviderRole role;

  const ProviderRegisterScreen({super.key, required this.role});

  @override
  State<ProviderRegisterScreen> createState() => _ProviderRegisterScreenState();
}

class _ProviderRegisterScreenState extends State<ProviderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Doctor
  final _doctorIdController = TextEditingController();
  final _experienceController = TextEditingController();

  // Doctor Categories
  final List<String> _doctorCategories = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Gynecologist',
    'Dentist',
  ];

  // Quick Fix Worker Categories
  final List<String> _workerCategories = [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'Cleaning',
    'AC Repair',
    'Appliances',
    'Gardening',
    'Locksmith',
    'Masonry',
  ];

  String? _selectedCategory;

  // Food services selected by the restaurant
  final Set<String> _selectedFoodServices = {};

  final List<String> _availableFoodServices = [
    'Food Saver',
    'Mystery Bites',
    'SweetCraft',
  ];

  // Driver
  final _licenseController = TextEditingController();
  final _licenseExpiryController = TextEditingController();

  // Worker / Food Partner
  final _hourlyRateController = TextEditingController();
  final _restaurantNameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get _isExistingFoodSellerApplicant =>
      _isFoodSeller && _auth.currentUser != null;

  @override
  void initState() {
    super.initState();

    if (_isExistingFoodSellerApplicant) {
      final user = _auth.currentUser!;

      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get _isDoctor => widget.role == ProviderRole.doctor;
  bool get _isDriver => widget.role == ProviderRole.driver;
  bool get _isWorker => widget.role == ProviderRole.worker;
  bool get _isFoodSeller => widget.role == ProviderRole.foodSeller;

  String get _roleName {
    switch (widget.role) {
      case ProviderRole.doctor:
        return 'Doctor';
      case ProviderRole.driver:
        return 'Driver';
      case ProviderRole.worker:
        return 'Quick Fix Worker';
      case ProviderRole.foodSeller:
        return 'Food Partner';
      default:
        return 'Provider';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _doctorIdController.dispose();
    _experienceController.dispose();

    _licenseController.dispose();
    _licenseExpiryController.dispose();

    _hourlyRateController.dispose();
    _restaurantNameController.dispose();

    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year + 1),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
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

    if (_isFoodSeller && _selectedFoodServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one food service.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if ((_isDoctor || _isWorker) && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a ${_isDoctor ? "doctor" : "worker skill"} category',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    UserCredential? credential;
    bool createdNewAccount = false;

    try {
      User? user;

      if (_isExistingFoodSellerApplicant) {
        // Use the currently logged-in customer's account.
        user = _auth.currentUser;
      } else {
        // Create a new account for a new provider.
        credential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        user = credential.user;
        createdNewAccount = true;
      }

      if (user == null) {
        throw Exception('Unable to access the user account.');
      }

      if (_isExistingFoodSellerApplicant) {
        final existingApplication = await _firestore
            .collection('food_sellers')
            .doc(user.uid)
            .get();

        if (existingApplication.exists) {
          final status = existingApplication
              .data()?['status']
              ?.toString()
              .toLowerCase();

          if (status == 'pending' || status == 'active') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    status == 'pending'
                        ? 'Your Food Seller application is already pending.'
                        : 'You are already an approved Food Seller.',
                  ),
                ),
              );
            }
            return;
          }
        }
      }

      if (createdNewAccount) {
        await user.updateDisplayName(_nameController.text.trim());
      }

      // 2. Determine target collection (Worker data directed to 'workers' collection)
      String targetCollection = 'users';
      if (_isDoctor) targetCollection = 'doctors';
      if (_isDriver) targetCollection = 'drivers';
      if (_isWorker) {
        targetCollection = 'workers'; // Saved in 'workers' collection
      }
      if (_isFoodSeller) targetCollection = 'food_sellers';

      // 3. Prepare details based on role
      Map<String, dynamic> providerDetails = {};

      if (_isDoctor) {
        providerDetails = {
          'doctorId': _doctorIdController.text.trim(),
          'specialization': _selectedCategory,
          'experienceYears': _experienceController.text.trim(),
        };
      } else if (_isDriver) {
        providerDetails = {
          'drivingLicenseNumber': _licenseController.text.trim(),
          'licenseExpiryDate': _licenseExpiryController.text.trim(),
        };
      } else if (_isWorker) {
        providerDetails = {
          'category': _selectedCategory,
          'hourlyRate': _hourlyRateController.text.trim(),
          'experienceYears': _experienceController.text.trim(),
        };
      } else if (_isFoodSeller) {
        providerDetails = {
          'restaurantName': _restaurantNameController.text.trim(),
          'foodServices': _selectedFoodServices.toList(),
        };
      }

      // 4. Save data into the specific role-based collection in Firestore
      await _firestore.collection(targetCollection).doc(user.uid).set({
        'uid': user.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'role': widget.role.name,
        'accountType': 'provider',
        'status': 'pending',
        'requiresApproval': true,
        'category': _selectedCategory,
        'providerDetails': providerDetails,
        'providerAgreementAccepted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
      });

      // Also save user profile in main 'users' collection

      if (createdNewAccount) {
        // Create the main user profile only for a new account.
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'role': widget.role.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 5. Add to Activity Logs for Admin Dashboard
      await _firestore.collection('activity_logs').add({
        'action': 'New $_roleName Application',
        'details':
            '${_nameController.text.trim()} applied as $_roleName${_selectedCategory != null ? " ($_selectedCategory)" : ""}.',
        'performedBy': 'System',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Please use a stronger password.';
          break;
        default:
          message = e.message ?? 'Unable to create account.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (createdNewAccount && credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {}
      }

      if (!mounted) return;

      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
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
      backgroundColor: const Color(0xFFF7F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          '$_roleName Application',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Apply as a $_roleName',
                  style: const TextStyle(
                    color: Color(0xFF17152A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete the information below. Your application will be reviewed before your provider account is activated.',
                  style: TextStyle(color: Color(0xFF747187), height: 1.5),
                ),
                const SizedBox(height: 30),
                _sectionTitle('Personal Information'),
                const SizedBox(height: 14),
                _field(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),
                _sectionTitle('$_roleName Information'),
                const SizedBox(height: 14),

                // Doctor Role Fields
                if (_isDoctor) ...[
                  _field(
                    controller: _doctorIdController,
                    label: 'Doctor / Medical Registration ID',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: _decoration(
                      label: 'Doctor Category / Specialization',
                      icon: Icons.medical_information_outlined,
                    ),
                    items: _doctorCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select doctor category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _experienceController,
                    label: 'Years of Experience',
                    icon: Icons.work_history_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ]
                // Driver Role Fields
                else if (_isDriver) ...[
                  _field(
                    controller: _licenseController,
                    label: 'Driving Licence Number',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _licenseExpiryController,
                    readOnly: true,
                    onTap: _selectExpiryDate,
                    decoration: _decoration(
                      label: 'Licence Expiry Date',
                      icon: Icons.event_outlined,
                      suffix: const Icon(Icons.calendar_month_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select licence expiry date';
                      }
                      return null;
                    },
                  ),
                ]
                // Worker Role Fields
                else if (_isWorker) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: _decoration(
                      label: 'Worker Skill Category',
                      icon: Icons.handyman_outlined,
                    ),
                    items: _workerCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select worker skill category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _hourlyRateController,
                    label: 'Expected Hourly Rate (LKR)',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _experienceController,
                    label: 'Years of Experience',
                    icon: Icons.work_history_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ]
                // Food Seller Role Fields
                else if (_isFoodSeller) ...[
                  _field(
                    controller: _restaurantNameController,
                    label: 'Restaurant / Business Name',
                    icon: Icons.storefront_outlined,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Food Services Offered'),

                  const SizedBox(height: 8),

                  const Text(
                    'Select all the services your business wants to provide.',
                    style: TextStyle(color: Color(0xFF747187), fontSize: 13),
                  ),

                  const SizedBox(height: 12),

                  ..._availableFoodServices.map((service) {
                    return CheckboxListTile(
                      value: _selectedFoodServices.contains(service),
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedFoodServices.add(service);
                          } else {
                            _selectedFoodServices.remove(service);
                          }
                        });
                      },
                      title: Text(
                        service,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      activeColor: const Color(0xFF5B4DFF),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),

                  if (_selectedFoodServices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Please select at least one food service.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],

                if (!_isExistingFoodSellerApplicant) ...[
                  const SizedBox(height: 28),
                  _sectionTitle('Account Security'),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _decoration(
                      label: 'Password',
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

                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _decoration(
                      label: 'Confirm Password',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
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
                ],
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B4DFF).withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF5B4DFF),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your provider account will remain pending until it is reviewed and approved by OneClick.',
                          style: TextStyle(
                            color: Color(0xFF5B4DFF),
                            fontSize: 12.5,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
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
                    onPressed: _isLoading ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4DFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'SUBMIT APPLICATION',
                            style: TextStyle(fontWeight: FontWeight.w800),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _decoration(label: label, icon: icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }

        if (label == 'Email Address') {
          final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

          if (!regex.hasMatch(value.trim())) {
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
      prefixIcon: Icon(icon, color: const Color(0xFF5B4DFF)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE4E2EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE4E2EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF5B4DFF), width: 1.5),
      ),
    );
  }
}
