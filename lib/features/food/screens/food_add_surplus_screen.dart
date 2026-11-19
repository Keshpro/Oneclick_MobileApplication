import 'package:flutter/material.dart';

import '../models/food_offer_model.dart';
import '../services/food_seller_data_service.dart';
import 'food_my_offers_screen.dart';

class FoodAddSurplusScreen extends StatefulWidget {
  const FoodAddSurplusScreen({super.key});

  @override
  State<FoodAddSurplusScreen> createState() => _FoodAddSurplusScreenState();
}

class _FoodAddSurplusScreenState extends State<FoodAddSurplusScreen> {
  final _formKey = GlobalKey<FormState>();

  final foodNameController = TextEditingController();
  final originalPriceController = TextEditingController();
  final saverPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final allergenController = TextEditingController();

  String selectedCategory = 'Bakery';
  bool _isSaving = false;

  DateTime? selectedStartDateTime;
  DateTime? selectedEndDateTime;

  final List<String> categories = [
    'Bakery',
    'Rice & Curry',
    'Fast Food',
    'Desserts',
    'Snacks',
    'Beverages',
    'Other',
  ];

  @override
  void dispose() {
    foodNameController.dispose();
    originalPriceController.dispose();
    saverPriceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    allergenController.dispose();

    super.dispose();
  }

  Future<DateTime?> _pickDateTime({
    required String title,
    required DateTime initialDateTime,
  }) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime.isBefore(now)
          ? DateTime(now.year, now.month, now.day)
          : initialDateTime,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, now.month, now.day),
      helpText: title,
    );

    if (pickedDate == null || !mounted) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      helpText: title,
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Choose date and time';

    final date =
        '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$date • $hour:$minute $period';
  }

  // ------------------------------------------------------------
  // CREATE OFFER
  // ------------------------------------------------------------

  Future<void> createOffer() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    final startAt = selectedStartDateTime;
    final endAt = selectedEndDateTime;

    if (startAt == null || endAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both the offer start and end times.'),
        ),
      );
      return;
    }

    if (!startAt.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The offer start must be in the future.')),
      );
      return;
    }

    if (!endAt.isAfter(startAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The offer end must be later than its start.'),
        ),
      );
      return;
    }

    final parsedQuantity = int.tryParse(quantityController.text.trim());

    if (parsedQuantity == null || parsedQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity must be a whole number greater than zero.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final offer = FoodOfferModel(
      foodName: foodNameController.text.trim(),
      category: selectedCategory,
      originalPrice: originalPriceController.text.trim(),
      saverPrice: saverPriceController.text.trim(),
      quantity: quantityController.text.trim(),
      availableFrom: _formatDateTime(startAt),
      availableUntil: _formatDateTime(endAt),
      description: descriptionController.text.trim(),
      allergens: allergenController.text.trim(),
      startsAt: startAt,
      expiresAt: endAt,
    );

    try {
      await FoodSellerDataService.instance.addOffer(offer);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food Saver offer created successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FoodMyOffersScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save offer. Please try again.'),
          duration: const Duration(seconds: 3),
        ),
      );

      debugPrint('Create food offer error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Surplus Food')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ------------------------------------------------------------
              // TITLE
              // ------------------------------------------------------------

              const Text(
                'Create Food Saver Offer',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                'Sell your safe surplus food at a discounted price and help reduce food waste.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 28),

              // ------------------------------------------------------------
              // FOOD NAME
              // ------------------------------------------------------------
              const Text(
                'Food Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: foodNameController,

                decoration: const InputDecoration(
                  hintText: 'e.g. Bakery Surprise Box',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the food name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // CATEGORY
              // ------------------------------------------------------------
              const Text(
                'Food Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,

                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),

                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // PRICING
              // ------------------------------------------------------------
              const Text(
                'Pricing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  // ORIGINAL PRICE
                  Expanded(
                    child: TextFormField(
                      controller: originalPriceController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        labelText: 'Original Price',
                        hintText: '800',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // SAVER PRICE
                  Expanded(
                    child: TextFormField(
                      controller: saverPriceController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        labelText: 'Saver Price',
                        hintText: '450',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(),
                      ),

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // QUANTITY
              // ------------------------------------------------------------
              const Text(
                'Available Quantity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: quantityController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  hintText: 'e.g. 10',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the quantity';
                  }

                  return null;
                },
              ),

              // OFFER SCHEDULE
              const Text(
                'Offer Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                'Choose exactly when customers can start buying and when the offer expires.',
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 16),

              // START DATE AND TIME
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Offer starts'),
                subtitle: Text(_formatDateTime(selectedStartDateTime)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final now = DateTime.now();

                  final picked = await _pickDateTime(
                    title: 'Select offer start',
                    initialDateTime:
                        selectedStartDateTime ??
                        now.add(const Duration(minutes: 5)),
                  );

                  if (picked != null && mounted) {
                    setState(() {
                      selectedStartDateTime = picked;
                    });
                  }
                },
              ),

              const Divider(),

              // END DATE AND TIME
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_outlined),
                title: const Text('Offer ends'),
                subtitle: Text(_formatDateTime(selectedEndDateTime)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final now = DateTime.now();

                  final picked = await _pickDateTime(
                    title: 'Select offer end',
                    initialDateTime:
                        selectedEndDateTime ??
                        (selectedStartDateTime ?? now).add(
                          const Duration(hours: 2),
                        ),
                  );

                  if (picked != null && mounted) {
                    setState(() {
                      selectedEndDateTime = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------------------
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: descriptionController,

                maxLines: 4,

                decoration: const InputDecoration(
                  hintText: 'Describe what customers will receive...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // ALLERGEN INFORMATION
              // ------------------------------------------------------------
              const Text(
                'Allergen Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: allergenController,

                decoration: const InputDecoration(
                  hintText: 'e.g. Contains milk, eggs, nuts',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------------------
              // CREATE OFFER BUTTON
              // ------------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : createOffer,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_circle_outline),
                  label: Text(
                    _isSaving ? 'Saving Offer...' : 'Create Food Saver Offer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}
