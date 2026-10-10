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

  @override
  Widget build(BuildContext context) {
    final application = service.applications.firstWhere(
      (application) => application.id == widget.applicationId,
    );

    final request = service.getRequestById(widget.requestId);

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Final Offer')),
        body: const Center(child: Text('Request could not be found.')),
      );
    }

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

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_outlined, color: Colors.green.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Review the seller\'s final offer carefully. Once accepted, this custom order will continue through the normal Food checkout.',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _acceptOffer,
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

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE91E63),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back to Chat'),
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

  Widget _requestCard(SweetCraftRequest request) {
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

          const SizedBox(height: 6),

          Text(
            '${request.foodType} • ${request.occasion}',
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
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: Color(0xFFE91E63)),
              SizedBox(width: 8),
              Text(
                'Seller\'s Final Offer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Final Price',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 5),

                Text(
                  'Rs. ${application.offeredPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Offer Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Final customized offer including the requested design and decoration.',
              style: TextStyle(height: 1.5),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 19,
                color: Color(0xFFE91E63),
              ),
              const SizedBox(width: 7),
              Text(
                'Ready by ${application.estimatedCompletionDate}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
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

    final sweetCraftProduct = SweetCraftProduct(
      id: 'SC-${request.id}-${application.id}',
      name: request.title,
      sellerName: application.shopName,
      foodImage: '',
      sellerLogo: '',
      price: application.offeredPrice,
      rating: application.rating,
      reviewCount: application.completedOrders,
      availableQuantity: 1,
      availableUntil: request.requiredDate,
      requestId: request.id,
      applicationId: application.id,
      offerDetails: 'Final customized offer including the requested design and decoration.',
    );

    // SweetCraft becomes one custom Food order.
    service.updateRequestStatus(request.id, SweetCraftRequestStatus.completed);

    final cart = FoodCartService.instance;

    // Make sure the custom SweetCraft order
    // is the only item being checked out.
    cart.clearCart();

    cart.addProduct(sweetCraftProduct, 1);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FoodCheckoutScreen()),
    );
  }
}
