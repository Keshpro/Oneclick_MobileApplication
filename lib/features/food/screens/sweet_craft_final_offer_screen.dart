import 'package:flutter/material.dart';

import '../models/sweet_craft_request.dart';
import '../models/sweet_craft_product.dart';
import '../services/sweet_craft_service.dart';
import '../services/food_cart_service.dart';
import 'food_checkout_screen.dart';

class SweetCraftFinalOfferScreen extends StatefulWidget {
  final String requestId;
  final String applicationId;

  const SweetCraftFinalOfferScreen({
    super.key,
    required this.requestId,
    required this.applicationId,
  });

  @override
  State<SweetCraftFinalOfferScreen> createState() =>
      _SweetCraftFinalOfferScreenState();
}

class _SweetCraftFinalOfferScreenState
    extends State<SweetCraftFinalOfferScreen> {
  final service = SweetCraftService.instance;

  late final TextEditingController priceController;
  late final TextEditingController noteController;

  bool editing = false;

  @override
  void initState() {
    super.initState();

    final application = service.applications.firstWhere(
      (application) => application.id == widget.applicationId,
    );

    priceController = TextEditingController(
      text: application.offeredPrice.toStringAsFixed(0),
    );

    noteController = TextEditingController(
      text: 'Final customized offer including the requested design and decoration.',
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final application = service.applications.firstWhere(
      (application) => application.id == widget.applicationId,
    );

    final request = service.getRequestById(widget.requestId);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        title: const Text(
          'Final Offer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sellerCard(application),
            const SizedBox(height: 18),
            _requestCard(request),
            const SizedBox(height: 18),
            _offerCard(application),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _acceptOffer();
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Accept Final Offer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sellerCard(dynamic application) {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFE6EE),
            child: const Icon(Icons.storefront, color: Color(0xFFE91E63)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.shopName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application.sellerName,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB300),
                size: 20,
              ),
              const SizedBox(width: 3),
              Text('${application.rating}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _requestCard(SweetCraftRequest? request) {
    if (request == null) {
      return const SizedBox();
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Request',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            request.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '${request.servings} servings • ${request.requiredDate}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _offerCard(dynamic application) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: Color(0xFFE91E63)),
              const SizedBox(width: 8),
              const Text(
                'Final Offer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    editing = !editing;
                  });
                },
                child: Text(editing ? 'Done' : 'Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            enabled: editing,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Final Price',
              prefixText: 'Rs. ',
              filled: true,
              fillColor: const Color(0xFFFFF8FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: noteController,
            enabled: editing,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Offer Details',
              filled: true,
              fillColor: const Color(0xFFFFF8FB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  void _acceptOffer() {
    final application = service.applications.firstWhere(
      (application) => application.id == widget.applicationId,
    );

    final request = service.getRequestById(widget.requestId);

    if (request == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request could not be found.')),
      );
      return;
    }

    final price = double.tryParse(priceController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid final price.')),
      );
      return;
    }

    final sweetCraftProduct = SweetCraftProduct(
      id: 'SC-${request.id}-${application.id}',
      name: request.title,
      sellerName: application.shopName,
      foodImage: '',
      sellerLogo: '',
      price: price,
      rating: application.rating,
      reviewCount: application.completedOrders,
      availableQuantity: 1,
      availableUntil: request.requiredDate,
      requestId: request.id,
      applicationId: application.id,
      offerDetails: noteController.text.trim(),
    );

    final cart = FoodCartService.instance;

    // SweetCraft is treated as one custom order.
    cart.clearCart();
    cart.addProduct(sweetCraftProduct, 1);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FoodCheckoutScreen()),
    );
  }
}
