import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'worker_registration_screen.dart'; // Worker Registration Screen import
import 'workers_list_screen.dart';

class _Service {
  final String name;
  final String tagline;
  final IconData icon;
  final Color primaryColor;
  final Color softBgColor;

  const _Service(this.name, this.tagline, this.icon, this.primaryColor, this.softBgColor);
}

class HomeServicesScreen extends StatefulWidget {
  const HomeServicesScreen({super.key});

  @override
  State<HomeServicesScreen> createState() => _HomeServicesScreenState();
}

class _HomeServicesScreenState extends State<HomeServicesScreen> {
  static const Color _mainNavy = Color(0xFF1E293B);
  static const Color _bgCanvas = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  static const List<_Service> _services = [
    _Service('Electrician', 'Wiring & repairs', Icons.electrical_services_rounded, Color(0xFFD97706), Color(0xFFFEF3C7)),
    _Service('Plumber', 'Leaks & fittings', Icons.plumbing_rounded, Color(0xFF0284C7), Color(0xFFE0F2FE)),
    _Service('Carpenter', 'Furniture & woodwork', Icons.handyman_rounded, Color(0xFF78350F), Color(0xFFFFEDD5)),
    _Service('Painter', 'Interior & exterior', Icons.format_paint_rounded, Color(0xFFDB2777), Color(0xFFFCE7F3)),
    _Service('Cleaning', 'Home & office', Icons.cleaning_services_rounded, Color(0xFF0D9488), Color(0xFFCCFBF1)),
    _Service('AC Repair', 'Service & install', Icons.ac_unit_rounded, Color(0xFF2563EB), Color(0xFFDBEAFE)),
    _Service('Appliances', 'Gadgets & devices', Icons.local_laundry_service_rounded, Color(0xFFDC2626), Color(0xFFFEE2E2)),
    _Service('Gardening', 'Landscaping & lawns', Icons.grass_rounded, Color(0xFF16A34A), Color(0xFFDCFCE7)),
    _Service('Locksmith', 'Key & lock issues', Icons.lock_open_rounded, Color(0xFF7C3AED), Color(0xFFEDE9FE)),
    _Service('Masonry', 'Construction & brick', Icons.foundation_rounded, Color(0xFF475569), Color(0xFFF1F5F9)),
  ];

  String _query = '';
  String _selectedCategory = 'All';

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final filtered = _services.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_query.toLowerCase());
      if (_selectedCategory == 'All') return matchesSearch;
      if (_selectedCategory == 'Interior' &&
          (s.name == 'Painter' || s.name == 'Cleaning' || s.name == 'Carpenter' || s.name == 'Locksmith')) {
        return matchesSearch;
      }
      if (_selectedCategory == 'Mechanical' &&
          (s.name == 'Electrician' || s.name == 'Plumber' || s.name == 'AC Repair' || s.name == 'Appliances' || s.name == 'Masonry')) {
        return matchesSearch;
      }
      if (_selectedCategory == 'Outdoor' && (s.name == 'Gardening' || s.name == 'Masonry')) {
        return matchesSearch;
      }
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: _bgCanvas,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          
          // 1. WORKER PROMOTIONAL AD BANNER (EARN EXTRA SALARY)
          SliverToBoxAdapter(child: _buildWorkerAdBanner(context)),

          SliverToBoxAdapter(child: _buildCategoryChips()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  Text(
                    '${filtered.length} categories',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final s = filtered[index];
                    return _buildServiceCard(context, s);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final uid = _currentUser?.uid;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        color: _mainNavy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (Navigator.of(context).canPop())
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: uid != null
                ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
                : null,
            builder: (context, snapshot) {
              String displayName = 'User';
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data();
                displayName = data?['name'] ?? _currentUser?.email?.split('@').first ?? 'User';
              }

              return Text(
                'Hi, $displayName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          
          const SizedBox(height: 4),
          Text(
            'What service do you need today?',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 18),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search electrician, plumber...',
                hintStyle: TextStyle(color: _textMuted, fontSize: 13.5),
                prefixIcon: Icon(Icons.search_rounded, color: _textMuted, size: 22),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📢 EARN EXTRA SALARY WORKER PROMOTIONAL BANNER
  Widget _buildWorkerAdBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: Color(0xFF22C55E),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Earn an Extra Income!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Register as a skilled worker on OneClick & offer your services.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WorkerRegistrationScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Register as Worker',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF38BDF8),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Interior', 'Mechanical', 'Outdoor'];
    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.white : _textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              selected: selected,
              selectedColor: _mainNavy,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: selected ? _mainNavy : const Color(0xFFE2E8F0)),
              ),
              onSelected: (val) {
                if (val) setState(() => _selectedCategory = cat);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: _textMuted),
          SizedBox(height: 8),
          Text(
            'No matching services found',
            style: TextStyle(fontSize: 14, color: _textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, _Service s) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkersListScreen(categoryName: s.name),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: s.softBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.icon, color: s.primaryColor, size: 22),
              ),
              const Spacer(),
              Text(
                s.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _textMuted),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: s.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: s.primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}