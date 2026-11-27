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
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      await sellerData.loadOffers();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    } catch (e) {
      debugPrint('Load offers error: $e');

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load offers. Please try again.';
      });
    }
  }

  // ------------------------------------------------------------
  // PAUSE / RESUME OFFER
  // ------------------------------------------------------------

  Future<void> toggleOfferStatus(int index) async {
    final offer = sellerData.offers[index];
    final newStatus = offer.status == 'PAUSED' ? 'ACTIVE' : 'PAUSED';

    try {
      await sellerData.setOfferStatus(offer, newStatus);

      if (!mounted) return;

      setState(() {});

      final message = newStatus == 'PAUSED'
          ? '${offer.foodName} paused successfully.'
          : '${offer.foodName} resumed successfully.';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      debugPrint('Update offer status error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update offer status.')),
      );
    }
  }

  // ------------------------------------------------------------
  // DELETE OFFER
  // ------------------------------------------------------------

  Future<void> deleteOffer(int index) async {
    final offer = sellerData.offers[index];
    final offerName = offer.foodName;

    try {
      await sellerData.deleteOffer(offer);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$offerName deleted.')));
    } catch (e) {
      debugPrint('Delete offer error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete offer. Please try again.'),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // EDIT OFFER
  // ------------------------------------------------------------

  Future<DateTime?> _pickOfferDateTime(
    BuildContext pickerContext,
    DateTime initialDateTime,
    String title,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final initialDate = initialDateTime.isBefore(today)
        ? today
        : initialDateTime;

    final pickedDate = await showDatePicker(
      context: pickerContext,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 2, now.month, now.day),
      helpText: title,
    );

    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: pickerContext,
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

  String _formatOfferDateTime(DateTime? value) {
    if (value == null) return 'Select date and time';

    final date =
        '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';

    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    return '$date • $hour:$minute $period';
  }

  void editOffer(int index, FoodOfferModel offer) {
    final nameController = TextEditingController(text: offer.foodName);
    final originalController = TextEditingController(text: offer.originalPrice);
    final saverController = TextEditingController(text: offer.saverPrice);
    final quantityController = TextEditingController(text: offer.quantity);

    final now = DateTime.now();

    DateTime selectedStart =
        offer.startsAt != null && offer.startsAt!.isAfter(now)
        ? offer.startsAt!
        : now.add(const Duration(minutes: 5));

    DateTime selectedEnd =
        offer.expiresAt != null && offer.expiresAt!.isAfter(selectedStart)
        ? offer.expiresAt!
        : selectedStart.add(const Duration(hours: 2));

    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Offer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Offer Schedule',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.play_circle_outline),
                      title: const Text('Offer starts'),
                      subtitle: Text(_formatOfferDateTime(selectedStart)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final picked = await _pickOfferDateTime(
                          context,
                          selectedStart,
                          'Select offer start',
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedStart = picked;
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_available_outlined),
                      title: const Text('Offer ends'),
                      subtitle: Text(_formatOfferDateTime(selectedEnd)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final picked = await _pickOfferDateTime(
                          context,
                          selectedEnd,
                          'Select offer end',
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedEnd = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final originalPrice = originalController.text.trim();
                          final saverPrice = saverController.text.trim();
                          final quantity = quantityController.text.trim();
                          final parsedQuantity = int.tryParse(quantity);
                          final currentTime = DateTime.now();

                          if (name.isEmpty ||
                              originalPrice.isEmpty ||
                              saverPrice.isEmpty ||
                              parsedQuantity == null ||
                              parsedQuantity <= 0) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter all fields and a quantity greater than zero.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (!selectedStart.isAfter(currentTime)) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'The offer start must be in the future.',
                                ),
                              ),
                            );
                            return;
                          }

                          if (!selectedEnd.isAfter(selectedStart)) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'The offer end must be later than its start.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          final updatedOffer = FoodOfferModel(
                            id: offer.id,
                            foodName: name,
                            category: offer.category,
                            originalPrice: originalPrice,
                            saverPrice: saverPrice,
                            quantity: quantity,
                            availableFrom: _formatOfferDateTime(selectedStart),
                            availableUntil: _formatOfferDateTime(selectedEnd),
                            description: offer.description,
                            allergens: offer.allergens,
                            startsAt: selectedStart,
                            expiresAt: selectedEnd,
                            status: offer.status,
                          );

                          try {
                            await sellerData.updateOffer(updatedOffer);

                            if (!this.mounted) return;

                            setState(() {});

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text('Offer updated successfully.'),
                              ),
                            );
                          } catch (e) {
                            debugPrint('Edit offer error: $e');

                            if (!this.mounted) return;

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Could not update offer. Please try again.',
                                ),
                              ),
                            );

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isSaving = false;
                              });
                            }
                          }
                        },
                  child: Text(isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      originalController.dispose();
      saverController.dispose();
      quantityController.dispose();
    });
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        _loadOffers();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : sellerData.offers.isEmpty
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
                ...List.generate(
                  sellerData.offers.length,
                  (index) => _offerCard(index, sellerData.offers[index]),
                ),
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
            color: Colors.black.withValues(alpha: 0.05),
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
