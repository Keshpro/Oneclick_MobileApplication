import 'package:flutter/material.dart';

import '../models/food_offer_model.dart';
import '../services/food_seller_data_service.dart';

class FoodMyOffersScreen extends StatefulWidget {
  const FoodMyOffersScreen({super.key});

  @override
  State<FoodMyOffersScreen> createState() => _FoodMyOffersScreenState();
}

class _FoodMyOffersScreenState extends State<FoodMyOffersScreen> {
  final sellerData = FoodSellerDataService.instance;

  // ------------------------------------------------------------
  // PAUSE / RESUME OFFER
  // ------------------------------------------------------------

  void toggleOfferStatus(int index) {
    final offer = sellerData.offers[index];

    setState(() {
      if (offer.status == 'PAUSED') {
        offer.status = 'ACTIVE';
      } else {
        offer.status = 'PAUSED';
      }
    });

    final message = offer.status == 'PAUSED'
        ? '${offer.foodName} paused successfully.'
        : '${offer.foodName} resumed successfully.';

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ------------------------------------------------------------
  // DELETE OFFER
  // ------------------------------------------------------------

  void deleteOffer(int index) {
    final offerName = sellerData.offers[index].foodName;

    setState(() {
      sellerData.offers.removeAt(index);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$offerName deleted.')));
  }

  // ------------------------------------------------------------
  // EDIT OFFER
  // ------------------------------------------------------------

  void editOffer(int index, FoodOfferModel offer) {
    final nameController = TextEditingController(text: offer.foodName);

    final originalController = TextEditingController(text: offer.originalPrice);

    final saverController = TextEditingController(text: offer.saverPrice);

    final quantityController = TextEditingController(text: offer.quantity);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Offer'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // FOOD NAME
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // ORIGINAL PRICE
                TextField(
                  controller: originalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Original Price',
                    prefixText: 'Rs. ',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // SAVER PRICE
                TextField(
                  controller: saverController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Saver Price',
                    prefixText: 'Rs. ',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                // QUANTITY
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            // SAVE
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final oldOffer = sellerData.offers[index];

                  sellerData.offers[index] = FoodOfferModel(
                    foodName: nameController.text.trim(),
                    category: oldOffer.category,
                    originalPrice: originalController.text.trim(),
                    saverPrice: saverController.text.trim(),
                    quantity: quantityController.text.trim(),
                    availableFrom: oldOffer.availableFrom,
                    availableUntil: oldOffer.availableUntil,
                    description: oldOffer.description,
                    allergens: oldOffer.allergens,

                    // IMPORTANT:
                    // Keep the existing ACTIVE / PAUSED status.
                    status: oldOffer.status,
                  );
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Offer updated successfully.')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F7),

      // ------------------------------------------------------------
      // APP BAR
      // ------------------------------------------------------------
      appBar: AppBar(
        title: const Text('My Offers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      // ------------------------------------------------------------
      // BODY
      // ------------------------------------------------------------
      body: sellerData.offers.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.all(16),

              children: [
                const Text(
                  'Your Food Saver Offers',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  'Manage the surplus food offers from your store.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                const SizedBox(height: 20),

                ...List.generate(sellerData.offers.length, (index) {
                  final offer = sellerData.offers[index];

                  return _offerCard(index, offer);
                }),
              ],
            ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'No Food Saver Offers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'Create your first surplus food offer.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // OFFER CARD
  // ------------------------------------------------------------

  Widget _offerCard(int index, FoodOfferModel offer) {
    final bool isPaused = offer.status == 'PAUSED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // --------------------------------------------------------
          // FOOD INFORMATION
          // --------------------------------------------------------

          Row(
            children: [
              Container(
                width: 65,
                height: 65,

                decoration: BoxDecoration(
                  color: isPaused
                      ? Colors.grey.shade200
                      : const Color(0xFFE8F5E9),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  Icons.fastfood_rounded,

                  color: isPaused ? Colors.grey : const Color(0xFF2E7D32),

                  size: 32,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offer.foodName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // STATUS BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: isPaused
                                ? Colors.grey.shade200
                                : const Color(0xFFE8F5E9),

                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            isPaused ? 'PAUSED' : 'ACTIVE',

                            style: TextStyle(
                              color: isPaused
                                  ? Colors.grey.shade700
                                  : const Color(0xFF2E7D32),

                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      offer.category,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Text(
                          'Rs. ${offer.originalPrice}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          'Rs. ${offer.saverPrice}',
                          style: TextStyle(
                            color: isPaused
                                ? Colors.grey
                                : const Color(0xFF2E7D32),

                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(),

          const SizedBox(height: 8),

          // --------------------------------------------------------
          // QUANTITY + TIME
          // --------------------------------------------------------
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 6),

              Text('${offer.quantity} available'),

              const SizedBox(width: 18),

              const Icon(
                Icons.access_time_rounded,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text('${offer.availableFrom} - ${offer.availableUntil}'),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // --------------------------------------------------------
          // EDIT + PAUSE / RESUME
          // --------------------------------------------------------
          Row(
            children: [
              // EDIT
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    editOffer(index, offer);
                  },

                  icon: const Icon(Icons.edit_outlined),

                  label: const Text('Edit'),
                ),
              ),

              const SizedBox(width: 10),

              // PAUSE / RESUME
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    toggleOfferStatus(index);
                  },

                  icon: Icon(
                    isPaused
                        ? Icons.play_circle_outline
                        : Icons.pause_circle_outline,
                  ),

                  label: Text(isPaused ? 'Resume' : 'Pause'),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaused
                        ? const Color(0xFF2E7D32)
                        : Colors.orange.shade700,

                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // --------------------------------------------------------
          // DELETE
          // --------------------------------------------------------
          SizedBox(
            width: double.infinity,

            child: TextButton.icon(
              onPressed: () {
                _showDeleteConfirmation(index, offer.foodName);
              },

              icon: const Icon(Icons.delete_outline, color: Colors.red),

              label: const Text(
                'Delete Offer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DELETE CONFIRMATION
  // ------------------------------------------------------------

  void _showDeleteConfirmation(int index, String offerName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Offer?'),

          content: Text(
            'Are you sure you want to permanently delete "$offerName"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                deleteOffer(index);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
