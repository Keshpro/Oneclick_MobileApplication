import 'package:flutter/material.dart';

import '../services/food_seller_data_service.dart';

class FoodStoreProfileScreen extends StatefulWidget {
  const FoodStoreProfileScreen({super.key});

  @override
  State<FoodStoreProfileScreen> createState() => _FoodStoreProfileScreenState();
}

class _FoodStoreProfileScreenState extends State<FoodStoreProfileScreen> {
  final sellerData = FoodSellerDataService.instance;

  late final TextEditingController storeNameController;
  late final TextEditingController ownerNameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController addressController;
  late final TextEditingController descriptionController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    storeNameController = TextEditingController(text: sellerData.storeName);

    ownerNameController = TextEditingController(text: sellerData.ownerName);

    phoneController = TextEditingController(text: sellerData.phone);

    emailController = TextEditingController(text: sellerData.email);

    addressController = TextEditingController(text: sellerData.address);

    descriptionController = TextEditingController(text: sellerData.description);
  }

  @override
  void dispose() {
    storeNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // SAVE PROFILE
  // ------------------------------------------------------------

  void saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      sellerData.storeName = storeNameController.text.trim();

      sellerData.ownerName = ownerNameController.text.trim();

      sellerData.phone = phoneController.text.trim();

      sellerData.email = emailController.text.trim();

      sellerData.address = addressController.text.trim();

      sellerData.description = descriptionController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store profile updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------
      appBar: AppBar(
        title: const Text('Store Profile'),

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // --------------------------------------------------
              // STORE HEADER
              // --------------------------------------------------

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,

                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(25),
                      ),

                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Color(0xFF2E7D32),
                        size: 45,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Text(
                          sellerData.storeName,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 6),

                        Icon(
                          Icons.verified,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Verified Food Seller',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --------------------------------------------------
              // BUSINESS INFORMATION
              // --------------------------------------------------
              const Text(
                'Business Information',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // STORE NAME
              _field(
                controller: storeNameController,
                label: 'Store Name',
                icon: Icons.storefront_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your store name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // OWNER
              _field(
                controller: ownerNameController,
                label: 'Owner / Contact Person',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the owner name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // PHONE
              _field(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // EMAIL
              _field(
                controller: emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email address';
                  }

                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ADDRESS
              _field(
                controller: addressController,
                label: 'Business Address',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your business address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // DESCRIPTION
              _field(
                controller: descriptionController,
                label: 'About Your Store',
                icon: Icons.info_outline,
                maxLines: 4,
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // BUSINESS TYPE
              // --------------------------------------------------
              const Text(
                'Business Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: const Row(
                  children: [
                    Icon(Icons.category_outlined, color: Color(0xFF2E7D32)),

                    SizedBox(width: 12),

                    Text('Bakery', style: TextStyle(fontSize: 15)),

                    Spacer(),

                    Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Business type is based on your seller application.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 28),

              // --------------------------------------------------
              // SAVE BUTTON
              // --------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: saveProfile,

                  icon: const Icon(Icons.save_outlined),

                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  // ------------------------------------------------------------
  // TEXT FIELD
  // ------------------------------------------------------------

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      maxLines: maxLines,

      validator: validator,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
      ),
    );
  }
}
