import 'package:flutter/material.dart';

import '../models/sweet_craft_request.dart';
import '../services/sweet_craft_service.dart';
import 'sweet_craft_applications_screen.dart';

class SweetCraftRequestDetailsScreen extends StatelessWidget {
  final String requestId;

  const SweetCraftRequestDetailsScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final service = SweetCraftService.instance;
    final request = service.getRequestById(requestId);

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Request')),
        body: const Center(child: Text('Request not found')),
      );
    }

    final applications = service.getApplicationsForRequest(request.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        title: const Text(
          'Request Details',
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
            _header(request),
            const SizedBox(height: 18),
            _detailsCard(request),
            const SizedBox(height: 18),
            _descriptionCard(request),
            const SizedBox(height: 18),
            _budgetCard(request),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SweetCraftApplicationsScreen(requestId: request.id),
                    ),
                  );
                },
                icon: const Icon(Icons.storefront_outlined),
                label: Text('View ${applications.length} Seller Applications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _header(SweetCraftRequest request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5C8A), Color(0xFFE91E63)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            request.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${request.foodType} • ${request.occasion}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(SweetCraftRequest request) {
    return _card(
      child: Column(
        children: [
          _row(Icons.palette_outlined, 'Theme', request.theme),
          _divider(),
          _row(Icons.restaurant_menu_outlined, 'Flavor', request.flavor),
          _divider(),
          _row(Icons.people_outline, 'Servings', '${request.servings}'),
          _divider(),
          _row(
            Icons.calendar_today_outlined,
            'Required Date',
            request.requiredDate,
          ),
          _divider(),
          _row(Icons.location_on_outlined, 'Location', request.location),
        ],
      ),
    );
  }

  Widget _descriptionCard(SweetCraftRequest request) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            request.description,
            style: const TextStyle(height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _budgetCard(SweetCraftRequest request) {
    return _card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(width: 14),
          const Text('Budget', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(
            'Rs. ${request.minBudget.toStringAsFixed(0)} - ${request.maxBudget.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.bold,
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

  Widget _row(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE91E63)),
        const SizedBox(width: 14),
        Text(title, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(height: 1),
    );
  }
}
