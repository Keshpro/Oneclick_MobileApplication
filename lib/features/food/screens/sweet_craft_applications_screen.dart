import 'package:flutter/material.dart';

import '../models/sweet_craft_application.dart';
import '../models/sweet_craft_request.dart';
import '../services/sweet_craft_service.dart';
import 'sweet_craft_chat_screen.dart';

class SweetCraftApplicationsScreen extends StatefulWidget {
  final String requestId;

  const SweetCraftApplicationsScreen({super.key, required this.requestId});

  @override
  State<SweetCraftApplicationsScreen> createState() =>
      _SweetCraftApplicationsScreenState();
}

class _SweetCraftApplicationsScreenState
    extends State<SweetCraftApplicationsScreen> {
  final service = SweetCraftService.instance;

  @override
  Widget build(BuildContext context) {
    final request = service.getRequestById(widget.requestId);

    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Applications')),
        body: const Center(child: Text('Request not found')),
      );
    }

    final applications = service.getApplicationsForRequest(widget.requestId);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        title: const Text(
          'Seller Applications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: applications.isEmpty
          ? _empty()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                return _applicationCard(request, applications[index]);
              },
            ),
    );
  }

  Widget _applicationCard(
    SweetCraftRequest request,
    SweetCraftApplication application,
  ) {
    final accepted = application.status == SweetCraftApplicationStatus.accepted;

    final rejected = application.status == SweetCraftApplicationStatus.rejected;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: accepted
            ? Border.all(color: const Color(0xFFE91E63), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: const Color(0xFFFFE6EE),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFFE91E63),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.shopName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      application.sellerName,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (accepted)
                _status('Accepted')
              else if (rejected)
                _status('Rejected'),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _stat(Icons.star_rounded, '${application.rating}', 'Rating'),
              _stat(
                Icons.shopping_bag_outlined,
                '${application.completedOrders}',
                'Orders',
              ),
              _stat(
                Icons.payments_outlined,
                'Rs. ${application.offeredPrice.toStringAsFixed(0)}',
                'Offer',
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8FB),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              application.message,
              style: const TextStyle(height: 1.45),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 18,
                color: Color(0xFFE91E63),
              ),
              const SizedBox(width: 6),
              Text(
                'Ready by ${application.estimatedCompletionDate}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (!accepted && !rejected)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        service.updateApplicationStatus(
                          application.id,
                          SweetCraftApplicationStatus.rejected,
                        );
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _acceptSeller(request, application);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text('Accept Seller'),
                  ),
                ),
              ],
            ),

          if (accepted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SweetCraftChatScreen(
                        requestId: request.id,
                        applicationId: application.id,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Open Private Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFE91E63)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _status(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE6EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE91E63),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 60, color: Color(0xFFFFB1C8)),
            SizedBox(height: 15),
            Text(
              'No applications yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 7),
            Text(
              'Verified sellers will be able to see your request and send proposals.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptSeller(
    SweetCraftRequest request,
    SweetCraftApplication application,
  ) {
    setState(() {
      service.updateApplicationStatus(
        application.id,
        SweetCraftApplicationStatus.accepted,
      );

      request.status = SweetCraftRequestStatus.sellerSelected;

      for (final other in service.getApplicationsForRequest(request.id)) {
        if (other.id != application.id) {
          other.status = SweetCraftApplicationStatus.rejected;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${application.shopName} has been selected! 🎉')),
    );
  }
}
