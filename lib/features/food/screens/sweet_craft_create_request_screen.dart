import 'package:flutter/material.dart';

import '../models/sweet_craft_request.dart';
import '../services/sweet_craft_service.dart';

class SweetCraftCreateRequestScreen extends StatefulWidget {
  const SweetCraftCreateRequestScreen({super.key});

  @override
  State<SweetCraftCreateRequestScreen> createState() =>
      _SweetCraftCreateRequestScreenState();
}

class _SweetCraftCreateRequestScreenState
    extends State<SweetCraftCreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final themeController = TextEditingController();
  final flavorController = TextEditingController();
  final servingsController = TextEditingController();
  final minBudgetController = TextEditingController();
  final maxBudgetController = TextEditingController();
  final locationController = TextEditingController();
  final dateController = TextEditingController();

  String selectedFoodType = 'Custom Cake';
  String selectedOccasion = 'Birthday';

  final foodTypes = [
    'Custom Cake',
    'Cupcakes',
    'Cookies',
    'Brownies',
    'Dessert Box',
    'Party Sweets',
    'Other',
  ];

  final occasions = [
    'Birthday',
    'Wedding',
    'Anniversary',
    'Graduation',
    'Baby Shower',
    'Party',
    'Other',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    themeController.dispose();
    flavorController.dispose();
    servingsController.dispose();
    minBudgetController.dispose();
    maxBudgetController.dispose();
    locationController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        title: const Text(
          'Create SweetCraft Request',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Tell sellers what you need',
                'Give as much detail as possible so sellers can create accurate offers.',
              ),
              const SizedBox(height: 22),

              _field(
                controller: titleController,
                label: 'Request Title',
                hint: 'Example: Elegant 21st Birthday Cake',
                icon: Icons.title_rounded,
              ),

              const SizedBox(height: 16),

              _dropdown(
                label: 'Food Type',
                value: selectedFoodType,
                items: foodTypes,
                onChanged: (value) {
                  setState(() {
                    selectedFoodType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              _dropdown(
                label: 'Occasion',
                value: selectedOccasion,
                items: occasions,
                onChanged: (value) {
                  setState(() {
                    selectedOccasion = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              _field(
                controller: descriptionController,
                label: 'Description',
                hint: 'Describe exactly what you want...',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              _field(
                controller: themeController,
                label: 'Theme / Design',
                hint: 'Example: Pink and gold',
                icon: Icons.palette_outlined,
              ),

              const SizedBox(height: 16),

              _field(
                controller: flavorController,
                label: 'Flavor',
                hint: 'Example: Chocolate',
                icon: Icons.restaurant_menu_rounded,
              ),

              const SizedBox(height: 16),

              _field(
                controller: servingsController,
                label: 'Number of Servings',
                hint: 'Example: 20',
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'Budget',
                'Set the range you are comfortable paying.',
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _field(
                      controller: minBudgetController,
                      label: 'Minimum',
                      hint: 'Rs. 8,000',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: maxBudgetController,
                      label: 'Maximum',
                      hint: 'Rs. 12,000',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                'When and where?',
                'Tell sellers when you need the order and where it should be fulfilled.',
              ),

              const SizedBox(height: 14),

              _field(
                controller: dateController,
                label: 'Required Date',
                hint: 'Example: October 20, 2026',
                icon: Icons.calendar_today_outlined,
              ),

              const SizedBox(height: 16),

              _field(
                controller: locationController,
                label: 'Location',
                hint: 'Example: Colombo',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 26),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8EF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFE91E63)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your request will be visible to verified SweetCraft sellers. Sellers can privately submit their price and proposal.',
                        style: TextStyle(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Post Request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFE0E9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFE0E9)),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
    );
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = SweetCraftRequest(
      id: 'SC${DateTime.now().millisecondsSinceEpoch}',
      title: titleController.text.trim(),
      foodType: selectedFoodType,
      occasion: selectedOccasion,
      description: descriptionController.text.trim(),
      theme: themeController.text.trim(),
      flavor: flavorController.text.trim(),
      servings: int.tryParse(servingsController.text.trim()) ?? 1,
      minBudget: double.tryParse(minBudgetController.text.trim()) ?? 0,
      maxBudget: double.tryParse(maxBudgetController.text.trim()) ?? 0,
      requiredDate: dateController.text.trim(),
      location: locationController.text.trim(),
      referenceImages: [],
      status: SweetCraftRequestStatus.open,
    );

    SweetCraftService.instance.addRequest(request);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SweetCraft request posted successfully! 🎉'),
      ),
    );

    Navigator.pop(context);
  }
}
