import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oneclick/features/groceries/customer/screens/grocery_home_screen.dart';

import 'offers_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';
import '../../doctor/patient/screens/doctor_entry_screen.dart';
import '../../doctor/doctor/screens/doctor_dashboard.dart';
import '../../../admin/screens/admin_dashboard.dart';
import '../../drunk_drive/passenger/screens/drunk_drive_home_screen.dart';
import '../../Personal Vault/screens/dashboard.dart' as personal_vault;
import '../../quickfix/user/screens/home_services_screen.dart';

import 'package:oneclick/core/theme/app_theme.dart';
import 'package:oneclick/core/widgets/teal_header.dart';
import 'package:oneclick/features/food/screens/food_saver_screen.dart';

import '../../food/screens/food_seller_dashboard_screen.dart';

class _Palette {
  static const bg = AppColors.background;
  static const surface = AppColors.surface;
  static const ink = AppColors.textDark;
  static const inkSoft = AppColors.textSecondary;
  static const primary = AppColors.primary;
  static const primaryDeep = AppColors.primaryDark;
  static const line = Color(0xFFD9ECEA);
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
  StreamSubscription<User?>? _authSubscription;
  int _loadGeneration = 0;

  int _selectedIndex = 0;
  String _searchQuery = '';
  String _userName = '';
  String _userEmail = '';
  String _userRole = 'user';
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
      'title': 'Food',
      'description':
          'Discover great food, save money and explore local food services.',
      'icon': Icons.restaurant_rounded,
      'gradient': const [Color(0xFFFF8A65), Color(0xFFE85D04)],
    },
    {
      'title': 'Groceries',
      'description': 'Fresh groceries delivered through OneClick partners.',
      'icon': Icons.local_grocery_store_rounded,
      'gradient': const [Color(0xFFFFC857), Color(0xFFBF8211)],
    },
    {
      'title': 'Quick Fix',
      'description':
          'Find local professionals for all your home and repair needs.',
      'icon': Icons.build_rounded,
      'gradient': const [Color(0xFFF87171), Color(0xFFDC2626)],
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
    _authSubscription = _auth.authStateChanges().listen((_) {
      if (mounted) _loadCurrentUser();
    });
  }

  List<Map<String, dynamic>> get _filteredServices {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _services;
    return _services.where((service) {
      final title = service['title'].toString().toLowerCase();
      final description = service['description'].toString().toLowerCase();
      return title.contains(q) || description.contains(q);
    }).toList();
  }

  // Auto-fetch User Details & Determine Role
  Future<void> _loadCurrentUser() async {
    final generation = ++_loadGeneration;
    final user = _auth.currentUser;
    if (!mounted) return;
    setState(() {
      _userName = user?.displayName?.trim() ?? '';
      _userEmail = user?.email ?? '';
      _userRole = 'user';
      _isLoadingUser = user != null;
    });
    if (user == null) return;

    Map<String, dynamic>? profile;
    Map<String, dynamic>? doctor;
    try {
      profile = (await _firestore.collection('users').doc(user.uid).get())
          .data();
    } catch (e) {
      debugPrint('User profile lookup failed: $e');
    }
    try {
      doctor = (await _firestore.collection('doctors').doc(user.uid).get())
          .data();
    } catch (e) {
      debugPrint('Doctor profile lookup failed: $e');
    }
    if (!mounted ||
        generation != _loadGeneration ||
        _auth.currentUser?.uid != user.uid)
      return;

    final data = doctor ?? profile;
    final name = data?['name']?.toString().trim();
    final fallbackName = user.displayName?.trim();
    setState(() {
      _userName = name != null && name.isNotEmpty
          ? name
          : (fallbackName != null && fallbackName.isNotEmpty
                ? fallbackName
                : (doctor != null ? 'Doctor' : 'User'));
      _userEmail = data?['email']?.toString() ?? user.email ?? '';
      _userRole = doctor != null
          ? 'doctor'
          : (profile?['role']?.toString().trim().toLowerCase() ?? 'user');
      _isLoadingUser = false;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _Palette.bg,
        extendBody: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Teal wave header (shared TealHeader) with floating search pill
              SliverToBoxAdapter(
                child: TealHeader(
                  floating: _HomeSearchField(
                    searchController: _searchController,
                    searchQuery: _searchQuery,
                    onSearchChanged: (value) =>
                        setState(() => _searchQuery = value),
                    onSearchClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _HeroCard(userName: _isLoggedIn ? _userName : null),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Explore Services',
                          style: TextStyle(
                            color: _Palette.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _Palette.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_filteredServices.length} Categories',
                          style: const TextStyle(
                            color: _Palette.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_filteredServices.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: .78,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final service = _filteredServices[index];
                      return _ServiceCard(
                        title: service['title'].toString(),
                        description: service['description'].toString(),
                        icon: service['icon'] as IconData,
                        gradient: List<Color>.from(service['gradient'] as List),
                        onTap: () => _openService(service['title'].toString()),
                      );
                    }, childCount: _filteredServices.length),
                  ),
                )
              else
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: _Palette.inkSoft,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No services found',
                          style: TextStyle(
                            color: _Palette.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isLoggedIn) SliverToBoxAdapter(child: _buildGuestCard()),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
            ],
          ),
        ),
        bottomNavigationBar: _FloatingNavBar(
          selectedIndex: _selectedIndex,
          onSelected: _onNavigationSelected,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: _Palette.primary,
              size: 24,
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
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Everything in one place',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12,
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
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: _showAccountOptions,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: _isLoadingUser
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _Palette.primary,
                        ),
                      )
                    : Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: _Palette.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
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
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_Palette.primary, _Palette.primaryDeep],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: _Palette.primary.withValues(alpha: .25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ready to get started?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account to access services and manage everything from one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .80),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _Palette.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
    if (!_isLoggedIn) {
      _showLoginRequired(serviceTitle);
      return;
    }

    Widget? screen;

    switch (serviceTitle) {
      case 'Doctor':
        screen = const DoctorEntryScreen();
        break;

      case 'Drunk & Drive':
        screen = const DrunkDriveHomeScreen();
        break;

      case 'Food':
        screen = const FoodSaverScreen();
        break;

      case 'Groceries':
        screen = const GroceryHomeScreen();
        break;

      case 'Quick Fix':
        screen = const HomeServicesScreen();
        break;

      case 'Personal Vault':
        screen = const personal_vault.PersonalDashboardScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    } else {
      _showLoginRequired(serviceTitle);
    }
  }

  void _onNavigationSelected(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    if ((index == 2 || index == 3) && !_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    final Widget screen = switch (index) {
      1 => const OffersScreen(),
      2 => const ActivityScreen(),
      3 => const ProfileScreen(),
      _ => const OffersScreen(),
    };

    setState(() => _selectedIndex = index);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((
      _,
    ) {
      if (mounted) setState(() => _selectedIndex = 0);
    });
  }

  void _showLoginRequired(String serviceName) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _GlassSheet(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomSheetHandle(),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: _Palette.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Access $serviceName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _Palette.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
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
              const SizedBox(height: 24),
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
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'Create a new account',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _Palette.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted && _selectedIndex != 0) setState(() => _selectedIndex = 0);
    });
  }

  // ======================================================
  // QUICKFIX WORKER MODE
  // ======================================================

  Widget _workerModeOption(BuildContext sheetContext) {
    final user = _auth.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      key: ValueKey('worker-mode-${user.uid}'),

      stream: _firestore.collection('workers').doc(user.uid).snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError ||
            !snapshot.hasData ||
            !snapshot.data!.exists ||
            _auth.currentUser?.uid != user.uid) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),

          decoration: BoxDecoration(
            color: _Palette.primary.withValues(alpha: 0.10),

            borderRadius: BorderRadius.circular(AppRadius.card),

            border: Border.all(color: _Palette.primary.withValues(alpha: 0.30)),
          ),

          child: ListTile(
            leading: const Icon(
              Icons.handyman_outlined,
              color: _Palette.primary,
            ),

            title: const Text(
              'Switch to Worker Mode',
              style: TextStyle(
                color: _Palette.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: const Text('Manage your QuickFix services'),

            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: _Palette.primary,
            ),

            onTap: () async {
              try {
                final current = _auth.currentUser;

                if (current == null || current.uid != user.uid) {
                  return;
                }

                final worker = await _firestore
                    .collection('workers')
                    .doc(current.uid)
                    .get(const GetOptions(source: Source.server));

                if (!mounted ||
                    !sheetContext.mounted ||
                    _auth.currentUser?.uid != current.uid) {
                  return;
                }

                if (!worker.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Worker account is unavailable.'),
                    ),
                  );

                  return;
                }

                Navigator.pop(sheetContext);

                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/worker-dashboard',
                  (route) => false,
                );
              } catch (_) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to verify worker account.'),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  // Account Options with Dynamic Role Switcher

  // Account Options with Food Seller Mode Switching
  Future<void> _showAccountOptions() async {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      if (mounted) setState(() => _selectedIndex = 0);
      return;
    }

    // Check whether the current user is an approved Food Seller
    final accountUid = _auth.currentUser?.uid;
    bool isActiveFoodSeller = false;

    try {
      final user = _auth.currentUser;

      if (user != null) {
        final sellerDoc = await _firestore
            .collection('food_sellers')
            .doc(user.uid)
            .get();

        final sellerData = sellerDoc.data();

        isActiveFoodSeller =
            sellerDoc.exists &&
            sellerData?['uid'] == user.uid &&
            sellerData?['role'] == 'foodSeller' &&
            sellerData?['status']?.toString().toLowerCase() == 'active';
      }
    } catch (e) {
      debugPrint('Food seller mode check failed: $e');
    }

    if (!mounted || accountUid == null || _auth.currentUser?.uid != accountUid)
      return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _GlassSheet(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomSheetHandle(),
              const SizedBox(height: 24),

              CircleAvatar(
                radius: 34,
                backgroundColor: _Palette.primary,
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                _userName.isEmpty ? 'OneClick User' : _userName,
                style: const TextStyle(
                  color: _Palette.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _userEmail,
                style: const TextStyle(color: _Palette.inkSoft, fontSize: 13),
              ),

              const SizedBox(height: 16),

              // FOOD SELLER MODE
              if (isActiveFoodSeller)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.orange,
                    ),
                    title: const Text(
                      'Switch to Seller Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                    onTap: () {
                      if (_auth.currentUser?.uid != accountUid) return;
                      Navigator.pop(sheetContext);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FoodSellerDashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),

              // QuickFix worker account switcher (independent of doctor role)
              _workerModeOption(sheetContext),

              // DOCTOR MODE

              // DYNAMIC ROLE SWITCHER (Shows ONLY for Providers/Admins)
              if (_userRole == 'doctor')
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.medical_services_rounded,
                      color: AppColors.success,
                    ),
                    title: const Text(
                      'Switch to Doctor Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                    onTap: () {
                      if (_auth.currentUser?.uid != accountUid) return;
                      Navigator.pop(sheetContext);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DoctorDashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),

              // ADMIN MODE
              if (_userRole == 'admin')
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: _Palette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: _Palette.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: _Palette.primary,
                    ),
                    title: const Text(
                      'Switch to Admin Portal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _Palette.primary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: _Palette.primary,
                    ),
                    onTap: () {
                      if (_auth.currentUser?.uid != accountUid) return;
                      Navigator.pop(sheetContext);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboard(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),

              // PROFILE
              ListTile(
                leading: const Icon(
                  Icons.person_outline_rounded,
                  color: _Palette.primary,
                ),
                title: const Text('My Profile'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _onNavigationSelected(3);
                },
              ),

              // ACTIVITY
              ListTile(
                leading: const Icon(
                  Icons.history_rounded,
                  color: _Palette.primary,
                ),
                title: const Text('My Activity'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _onNavigationSelected(2);
                },
              ),

              const Divider(),

              // LOGOUT
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);

                  try {
                    await _auth.signOut();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: $e')),
                      );
                    }
                    return;
                  }

                  if (!mounted) return;

                  setState(() {
                    _userName = '';
                    _userEmail = '';
                    _userRole = 'user';
                    _isLoadingUser = false;
                    _selectedIndex = 0;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ], // children
          ), // Column
        ), // SingleChildScrollView
      ), // _GlassSheet
    ).whenComplete(() {
      if (mounted) setState(() => _selectedIndex = 0);
    });
  }

  Widget _bottomSheetHandle() => Container(
    width: 48,
    height: 4,
    decoration: BoxDecoration(
      color: _Palette.line,
      borderRadius: BorderRadius.circular(4),
    ),
  );

  ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: _Palette.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    ),
  );
}

// ================================================================
// UI-only widgets (Fresh Teal)
// ================================================================
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _Palette.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Hero text. The teal background comes from TealHeader.
class _HeroCard extends StatelessWidget {
  final String? userName;

  const _HeroCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'ONE APP • MULTIPLE SERVICES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName != null && userName!.trim().isNotEmpty
                ? 'Hi, ${userName!.split(' ').first}!\nWhat do you need?'
                : 'What do you\nneed today?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover services, find the right people and get things done with OneClick.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating pill search field (sits on the wave edge of the header).
class _HomeSearchField extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;

  const _HomeSearchField({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _Palette.ink.withValues(alpha: .12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: const TextStyle(color: _Palette.inkSoft),
          prefixIcon: const Icon(Icons.search_rounded, color: _Palette.primary),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: onSearchClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _Palette.inkSoft,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final accent = gradient.last;

    return Material(
      color: _Palette.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: _Palette.ink.withValues(alpha: .06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _Palette.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _Palette.inkSoft,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      color: _Palette.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: _Palette.primary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  final Widget child;

  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(top: BorderSide(color: _Palette.line)),
          ),
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.local_offer_rounded,
    Icons.history_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Offers', 'Activity', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _Palette.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_icons.length, (index) {
              final selected = index == selectedIndex;
              return Expanded(
                child: Semantics(
                  label: _labels[index],
                  button: true,
                  selected: selected,
                  child: Tooltip(
                    message: _labels[index],
                    child: InkWell(
                      onTap: () => onSelected(index),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected
                              ? _Palette.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            _icons[index],
                            size: 26,
                            color: selected
                                ? _Palette.primary
                                : _Palette.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
