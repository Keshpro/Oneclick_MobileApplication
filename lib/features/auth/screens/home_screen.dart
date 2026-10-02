import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'services_screen.dart';
import 'explore_screen.dart';
import '../../doctor/patient/screens/doctor_entry_screen.dart';
import '../../drunk_drive/passenger/screens/drunk_drive_home_screen.dart';
import '../../Personal Vault/screens/dashboard.dart' as personal_vault;

class _Palette {
  static const bg = Color(0xFFF3F1FF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF120F2E);
  static const inkSoft = Color(0xFF6B6584);
  static const primary = Color(0xFF5B4DFF);
  static const primaryDeep = Color(0xFF2E1FA6);
  static const accent = Color(0xFFFF6FA1);
  static const accent2 = Color(0xFF00D6C4);
  static const line = Color(0xFFE7E3FB);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  String _searchQuery = '';
  String _userName = '';
  String _userEmail = '';
  bool _isLoadingUser = true;

  bool get _isLoggedIn => _auth.currentUser != null;

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Doctor',
      'description': 'Find doctors, book appointments and get medical support.',
      'icon': Icons.medical_services_rounded,
      'gradient': const [Color(0xFF11D999), Color(0xFF059669)],
    },

    {
      'title': 'Drunk & Drive',
      'description': 'Find a trusted driver and get home safely.',
      'icon': Icons.directions_car_filled_rounded,
      'gradient': const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    },

    {
      'title': 'Groceries',
      'description': 'Fresh groceries delivered through OneClick partners.',
      'icon': Icons.local_grocery_store_rounded,
      'gradient': const [Color(0xFFFFC857), Color(0xFFBF8211)],
    },

    {
      'title': 'Personal Vault',
      'description':
          'Keep your personal documents and important information secure.',
      'icon': Icons.shield_rounded,
      'gradient': const [Color(0xFF38BDF8), Color(0xFF0369A1)],
    },
  ];

  @override
  void initState() {
    super.initState();

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoadingUser = false);

      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      final data = doc.data();

      if (!mounted) return;

      setState(() {
        _userName = data?['name']?.toString() ?? 'User';
        _userEmail = data?['email']?.toString() ?? user.email ?? '';

        _isLoadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _userName = 'User';

        _userEmail = user.email ?? '';

        _isLoadingUser = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredServices {
    final q = _searchQuery.trim().toLowerCase();

    if (q.isEmpty) return _services;

    return _services.where((s) {
      return s['title'].toString().toLowerCase().contains(q) ||
          s['description'].toString().toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,

      extendBody: true,

      body: SafeArea(
        bottom: false,

        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),

                child: _HeroCard(
                  searchController: _searchController,

                  searchQuery: _searchQuery,

                  userName: _isLoggedIn ? _userName : null,

                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value),

                  onSearchClear: () {
                    _searchController.clear();

                    setState(() => _searchQuery = '');
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 14),

                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Explore Services',
                        style: TextStyle(
                          color: _Palette.ink,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: _Palette.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        '${_filteredServices.length} Categories',
                        style: const TextStyle(
                          color: _Palette.primary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // SERVICES GRID
            // ==================================================
            if (_filteredServices.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 14,

                    mainAxisSpacing: 14,

                    childAspectRatio: .86,
                  ),

                  delegate: SliverChildBuilderDelegate((context, index) {
                    final service = _filteredServices[index];

                    return _ServiceCard(
                      title: service['title'].toString(),

                      description: service['description'].toString(),

                      icon: service['icon'] as IconData,

                      gradient: List<Color>.from(service['gradient']),

                      onTap: () => _openService(service['title'].toString()),
                    );
                  }, childCount: _filteredServices.length),
                ),
              )
            else
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 45),

                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 46,
                        color: _Palette.inkSoft,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'No services found',
                        style: TextStyle(
                          color: _Palette.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isLoggedIn) SliverToBoxAdapter(child: _buildGuestCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: _selectedIndex,
        onSelected: _onNavigationSelected,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),

      child: Row(
        children: [
          Container(
            width: 44,

            height: 44,

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_Palette.primary, _Palette.primaryDeep],
              ),

              borderRadius: BorderRadius.circular(15),

              boxShadow: [
                BoxShadow(
                  color: _Palette.primary.withValues(alpha: .35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'OneClick',
                  style: TextStyle(
                    color: _Palette.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                Text(
                  'Everything in one place',
                  style: TextStyle(
                    color: _Palette.inkSoft,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (_isLoggedIn) ...[
            IconButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              ),

              icon: const Icon(
                Icons.notifications_none_rounded,
                color: _Palette.ink,
              ),
            ),

            GestureDetector(
              onTap: _showAccountOptions,

              child: Container(
                width: 42,

                height: 42,

                alignment: Alignment.center,

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_Palette.primary, _Palette.primaryDeep],
                  ),

                  shape: BoxShape.circle,
                ),

                child: _isLoadingUser
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: _Palette.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            _GradientButton(
              label: 'Register',
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_Palette.primary, _Palette.primaryDeep],
          ),

          borderRadius: BorderRadius.circular(26),

          boxShadow: [
            BoxShadow(
              color: _Palette.primary.withValues(alpha: .30),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),

        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 42,
            ),

            const SizedBox(height: 14),

            const Text(
              'Ready to get started?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Create an account to access services and manage everything from one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .78),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _Palette.primaryDeep,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                child: const Text(
                  'Create Account',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text(
                'Already have an account? Login',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openService(String serviceTitle) {
    switch (serviceTitle) {
      case 'Doctor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorEntryScreen()),
        );
        break;

      case 'Drunk & Drive':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DrunkDriveHomeScreen()),
        );
        break;

      case 'Personal Vault':
        if (!_isLoggedIn) {
          _showLoginRequired('Personal Vault');
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const personal_vault.PersonalDashboardScreen(),
          ),
        );
        break;

      case 'Groceries':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Groceries module is coming soon.')),
        );
        break;
    }
  }

  void _onNavigationSelected(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
    } else if (index == 1) {
      setState(() => _selectedIndex = 1);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServicesScreen()),
      ).then((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    } else if (index == 2) {
      setState(() => _selectedIndex = 2);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExploreScreen()),
      ).then((_) {
        if (mounted) setState(() => _selectedIndex = 0);
      });
    } else {
      setState(() => _selectedIndex = 3);

      _showAccountOptions();
    }
  }

  void _showLoginRequired(String serviceName) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      builder: (sheetContext) => _GlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bottomSheetHandle(),

            const SizedBox(height: 22),

            const Icon(
              Icons.lock_outline_rounded,
              color: _Palette.primary,
              size: 48,
            ),

            const SizedBox(height: 14),

            Text(
              'Access $serviceName',
              style: const TextStyle(
                color: _Palette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Login or create an account to continue using this service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _Palette.inkSoft,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);

                  Navigator.pushNamed(context, '/login');
                },

                style: _primaryButtonStyle(),

                child: const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(sheetContext);

                Navigator.pushNamed(context, '/register');
              },

              child: const Text(
                'Create a new account',
                style: TextStyle(
                  color: _Palette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountOptions() {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');

      if (mounted) setState(() => _selectedIndex = 0);

      return;
    }

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.transparent,

      builder: (sheetContext) => _GlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bottomSheetHandle(),

            const SizedBox(height: 22),

            CircleAvatar(
              radius: 34,

              backgroundColor: _Palette.primary,

              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _userName.isEmpty ? 'OneClick User' : _userName,
              style: const TextStyle(
                color: _Palette.ink,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _userEmail,
              style: const TextStyle(color: _Palette.inkSoft, fontSize: 13),
            ),

            const SizedBox(height: 18),

            ListTile(
              leading: const Icon(
                Icons.person_outline_rounded,
                color: _Palette.primary,
              ),
              title: const Text('My Profile'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(sheetContext),
            ),

            ListTile(
              leading: const Icon(
                Icons.history_rounded,
                color: _Palette.primary,
              ),
              title: const Text('My Activity'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(sheetContext),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),

              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),

              onTap: () async {
                Navigator.pop(sheetContext);

                await _auth.signOut();

                if (!mounted) return;

                setState(() {
                  _userName = '';

                  _userEmail = '';

                  _selectedIndex = 0;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              },
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedIndex = 0);
    });
  }

  Widget _bottomSheetHandle() => Container(
    width: 45,
    height: 5,
    decoration: BoxDecoration(
      color: _Palette.line,
      borderRadius: BorderRadius.circular(20),
    ),
  );

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: _Palette.primary,

    foregroundColor: Colors.white,

    elevation: 0,

    padding: const EdgeInsets.symmetric(vertical: 15),

    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _GradientButton extends StatelessWidget {
  final String label;

  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,

    child: InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(13),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),

        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_Palette.primary, _Palette.primaryDeep],
          ),

          borderRadius: BorderRadius.circular(13),
        ),

        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    ),
  );
}

class _HeroCard extends StatelessWidget {
  final TextEditingController searchController;

  final String searchQuery;

  final String? userName;

  final ValueChanged<String> onSearchChanged;

  final VoidCallback onSearchClear;

  const _HeroCard({
    required this.searchController,
    required this.searchQuery,
    required this.userName,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,

    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_Palette.primaryDeep, _Palette.primary],
      ),

      borderRadius: BorderRadius.circular(30),

      boxShadow: [
        BoxShadow(
          color: _Palette.primary.withValues(alpha: .30),
          blurRadius: 26,
          offset: const Offset(0, 16),
        ),
      ],
    ),

    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),

      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Palette.accent2.withValues(alpha: .25),
              ),
            ),
          ),

          Positioned(
            bottom: -60,
            left: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _Palette.accent.withValues(alpha: .20),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName != null && userName!.isNotEmpty
                      ? 'WELCOME, ${userName!.toUpperCase()}'
                      : 'ONE APP • MULTIPLE SERVICES',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .9,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'What do you\nneed today?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 33,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Discover services, find the right people and get things done with OneClick.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .80),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: TextField(
                    controller: searchController,

                    onChanged: onSearchChanged,

                    decoration: InputDecoration(
                      hintText: 'Search services...',

                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _Palette.primary,
                      ),

                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: onSearchClear,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,

                      border: InputBorder.none,

                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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

class _ServiceCard extends StatelessWidget {
  final String title;

  final String description;

  final IconData icon;

  final List<Color> gradient;

  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: _Palette.surface,

    borderRadius: BorderRadius.circular(24),

    child: InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(24),

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _Palette.line),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 25),
            ),

            const Spacer(),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _Palette.ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _Palette.inkSoft,
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  'Explore',
                  style: TextStyle(
                    color: gradient.last,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: gradient.last,
                  size: 17,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _GlassSheet extends StatelessWidget {
  final Widget child;

  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),

    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),

      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),

        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),

        child: SafeArea(top: false, child: child),
      ),
    ),
  );
}

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;

  final ValueChanged<int> onSelected;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),

    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Services'),

    (Icons.explore_outlined, Icons.explore_rounded, 'Explore'),

    (Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,

    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

          child: Container(
            height: 66,

            padding: const EdgeInsets.symmetric(horizontal: 10),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _Palette.line),
            ),

            child: Row(
              children: List.generate(_items.length, (index) {
                final selected = index == selectedIndex;

                final item = _items[index];

                return Expanded(
                  child: InkWell(
                    onTap: () => onSelected(index),

                    borderRadius: BorderRadius.circular(20),

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),

                      margin: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 4,
                      ),

                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [
                                  _Palette.primary,
                                  _Palette.primaryDeep,
                                ],
                              )
                            : null,

                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected ? item.$2 : item.$1,
                            color: selected ? Colors.white : _Palette.inkSoft,
                            size: 22,
                          ),

                          if (selected) ...[
                            const SizedBox(width: 7),

                            Flexible(
                              child: Text(
                                item.$3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    ),
  );
}
