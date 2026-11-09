import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oneclick/features/auth/screens/provider_rules_screen.dart';
import 'my_bookings_screen.dart'; // Import MyBookingsScreen
import 'workers_list_screen.dart';
import 'package:oneclick/core/theme/app_theme.dart'; // UI only: Fresh Teal tokens

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
  static const Color _bgCanvas = AppColors.background;
  static const Color _textDark = AppColors.textDark;
  static const Color _textMuted = AppColors.textSecondary;

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgCanvas,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),

            // 1. WORKER PROMOTIONAL AD BANNER
            SliverToBoxAdapter(child: _buildWorkerAdBanner(context)),

            SliverToBoxAdapter(child: _buildCategoryChips()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${filtered.length} categories',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final uid = _currentUser?.uid;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (Navigator.of(context).canPop())
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              const Spacer(),

              // 📅 MY BOOKINGS BUTTON (දැමූ Bookings බැලීමට)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyBookingsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'My Bookings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Notifications Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white, size: 24),
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
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              );
            },
          ),

          const SizedBox(height: 4),
          Text(
            'What service do you need today?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: _textDark.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search electrician, plumber...',
                hintStyle: TextStyle(color: _textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: _textDark.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payments_rounded,
                color: AppColors.success,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Earn an Extra Income!',
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Register as a skilled worker on OneClick & offer your services.',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProviderRulesScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Register as Worker',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.primary,
                          size: 16,
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
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              showCheckmark: false,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
                side: BorderSide(
                  color: selected ? AppColors.primary : const Color(0xFFD9ECEA),
                ),
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkersListScreen(categoryName: s.name),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: _textDark.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Per-service accent colour (secondary accent)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: s.softBgColor,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(s.icon, color: s.primaryColor, size: 24),
              ),
              const Spacer(),
              Text(
                s.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}