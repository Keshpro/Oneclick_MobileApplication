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

  String selectedFromTime = '5:00 PM';
  String selectedUntilTime = '8:00 PM';

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

  // ------------------------------------------------------------
  // CREATE OFFER
  // ------------------------------------------------------------

  void createOffer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Create the new food offer
    final offer = FoodOfferModel(
      foodName: foodNameController.text.trim(),
      category: selectedCategory,
      originalPrice: originalPriceController.text.trim(),
      saverPrice: saverPriceController.text.trim(),
      quantity: quantityController.text.trim(),
      availableFrom: selectedFromTime,
      availableUntil: selectedUntilTime,
      description: descriptionController.text.trim(),
      allergens: allergenController.text.trim(),
    );

    // ------------------------------------------------------------
    // SAVE OFFER TO SHARED SELLER DATA
    // ------------------------------------------------------------

    FoodSellerDataService.instance.offers.add(offer);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food Saver offer created successfully!'),
        duration: Duration(seconds: 2),
      ),
    );

    // Open My Offers screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FoodMyOffersScreen()),
    );
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
                value: selectedCategory,

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

              const SizedBox(height: 20),

              // ------------------------------------------------------------
              // COLLECTION TIME
              // ------------------------------------------------------------
              const Text(
                'Collection Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  // FROM
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFromTime,

                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: '4:00 PM',
                          child: Text('4:00 PM'),
                        ),
                        DropdownMenuItem(
                          value: '5:00 PM',
                          child: Text('5:00 PM'),
                        ),
                        DropdownMenuItem(
                          value: '6:00 PM',
                          child: Text('6:00 PM'),
                        ),
                        DropdownMenuItem(
                          value: '7:00 PM',
                          child: Text('7:00 PM'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedFromTime = value;
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // UNTIL
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedUntilTime,

                      decoration: const InputDecoration(
                        labelText: 'Until',
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: '6:00 PM',
                          child: Text('6:00 PM'),
                        ),
                        DropdownMenuItem(
                          value: '7:00 PM',
                          child: Text('7:00 PM'),
                        ),
                        DropdownMenuItem(
                          value: '8:00 PM',
                          child: Text('8:00 PM'),
                        ),
                        DropdownMenuItem(
                          value: '9:00 PM',
                          child: Text('9:00 PM'),
                        ),
                      ],

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedUntilTime = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
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
                  onPressed: createOffer,

                  icon: const Icon(Icons.add_circle_outline),

                  label: const Text(
                    'Create Food Saver Offer',
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
