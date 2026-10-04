import 'package:flutter/material.dart';

import '../models/sweet_craft_request.dart';
import '../services/sweet_craft_service.dart';
import 'sweet_craft_create_request_screen.dart';
import 'sweet_craft_request_details_screen.dart';

class SweetCraftScreen extends StatefulWidget {
  const SweetCraftScreen({super.key});

  @override
  State<SweetCraftScreen> createState() => _SweetCraftScreenState();
}

class _SweetCraftScreenState extends State<SweetCraftScreen> {
  final SweetCraftService service = SweetCraftService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FB),
      appBar: AppBar(
        title: const Text(
          'SweetCraft',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 24),
              _buildHowItWorks(),
              const SizedBox(height: 28),
              _buildCategories(),
              const SizedBox(height: 30),
              _buildMyRequests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5C8A), Color(0xFFE91E63)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 38),
          const SizedBox(height: 18),
          const Text(
            'You dream it.\nSellers create it.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Post your custom food idea and let verified sellers compete to create it for you.',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createRequest,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Post a Custom Request',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How SweetCraft Works',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _step(icon: Icons.edit_note_rounded, number: '1', title: 'Post'),
            _line(),
            _step(
              icon: Icons.storefront_rounded,
              number: '2',
              title: 'Receive',
            ),
            _line(),
            _step(
              icon: Icons.chat_bubble_outline_rounded,
              number: '3',
              title: 'Chat',
            ),
            _line(),
            _step(
              icon: Icons.check_circle_outline_rounded,
              number: '4',
              title: 'Choose',
            ),
          ],
        ),
      ],
    );
  }

  Widget _step({
    required IconData icon,
    required String number,
    required String title,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE1EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFE91E63)),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFFE91E63),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      width: 12,
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: const Color(0xFFFFC2D5),
    );
  }

  Widget _buildCategories() {
    final categories = [
      ['Cakes', Icons.cake_rounded],
      ['Cupcakes', Icons.bakery_dining_rounded],
      ['Cookies', Icons.cookie_rounded],
      ['Brownies', Icons.square_rounded],
      ['Dessert Boxes', Icons.inventory_2_rounded],
      ['Party Sweets', Icons.celebration_rounded],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What can you request?',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Container(
                width: 105,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFD6E2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      categories[index][1] as IconData,
                      color: const Color(0xFFE91E63),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categories[index][0] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Requests',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            Text(
              '${service.requests.length}',
              style: const TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (service.requests.isEmpty)
          _emptyRequests()
        else
          ...service.requests.map((request) => _requestCard(request)),
      ],
    );
  }

  Widget _requestCard(SweetCraftRequest request) {
    final applications = service.getApplicationsForRequest(request.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusChip(request.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${request.foodType} • ${request.occasion}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 17,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(width: 5),
                Text(
                  'Rs. ${request.minBudget.toStringAsFixed(0)} - ${request.maxBudget.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 17,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(width: 5),
                Text('${request.servings} servings'),
                const SizedBox(width: 15),
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.location,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${applications.length} seller application${applications.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFFE91E63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SweetCraftRequestDetailsScreen(
                          requestId: request.id,
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Request'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(SweetCraftRequestStatus status) {
    String text;

    switch (status) {
      case SweetCraftRequestStatus.open:
        text = 'Open';
        break;
      case SweetCraftRequestStatus.reviewing:
        text = 'Reviewing';
        break;
      case SweetCraftRequestStatus.sellerSelected:
        text = 'Seller Selected';
        break;
      case SweetCraftRequestStatus.negotiating:
        text = 'Negotiating';
        break;
      case SweetCraftRequestStatus.completed:
        text = 'Completed';
        break;
      case SweetCraftRequestStatus.cancelled:
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  Widget _emptyRequests() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome, size: 50, color: Color(0xFFFFB1C8)),
          SizedBox(height: 12),
          Text(
            'No custom requests yet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            'Create your first SweetCraft request.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _createRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SweetCraftCreateRequestScreen()),
    ).then((_) => setState(() {}));
  }
}
