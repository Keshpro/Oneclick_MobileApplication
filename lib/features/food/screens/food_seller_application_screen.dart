import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'food_verification_screen.dart';

class FoodSellerApplicationScreen extends StatefulWidget {
  const FoodSellerApplicationScreen({super.key});

  @override
  State<FoodSellerApplicationScreen> createState() =>
      _FoodSellerApplicationScreenState();
}

class _FoodSellerApplicationScreenState
    extends State<FoodSellerApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final storeNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  String businessType = 'Restaurant';

  @override
  void dispose() {
    storeNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in before applying as a food seller.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('foodSellerApplications')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'storeName': storeNameController.text.trim(),
            'ownerName': ownerNameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': emailController.text.trim(),
            'businessType': businessType,
            'address': addressController.text.trim(),
            'status': 'under_review',
            'adminComment': '',
            'identityDocumentUrl': '',
            'businessRegistrationUrl': '',
            'foodPermitUrl': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application saved successfully.')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FoodVerificationScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit application: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Food Seller')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sell Food with Oneclick',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'Apply to become a verified food seller and offer your food to customers.',
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store / Business Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your store name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner / Contact Person',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the owner name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: businessType,
                decoration: const InputDecoration(
                  labelText: 'Business Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Restaurant',
                    child: Text('Restaurant'),
                  ),
                  DropdownMenuItem(value: 'Bakery', child: Text('Bakery')),
                  DropdownMenuItem(value: 'Cafe', child: Text('Cafe')),
                  DropdownMenuItem(
                    value: 'Home Food Business',
                    child: Text('Home Food Business'),
                  ),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    businessType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Business Address',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'After submitting your application, you will be asked to provide documents required for seller verification.',
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: submitApplication,
                  child: const Text(
                    'Submit Application',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
