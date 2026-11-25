
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:oneclick/core/theme/app_theme.dart';
import 'package:oneclick/core/widgets/teal_header.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Notifications'),
      ),
    );
  }
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Offers'),
      ),
    );
  }
}

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Activity'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onActivityTap;

  const ProfileScreen({
    super.key,
    this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Profile Screen'),
            if (onActivityTap != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onActivityTap,
                child: const Text('View Activity'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DoctorEntryScreen extends StatelessWidget {
  const DoctorEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Doctor Entry'),
      ),
    );
  }
}

class DrunkDriveHomeScreen extends StatelessWidget {
  const DrunkDriveHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Drunk & Drive'),
      ),
    );
  }
}

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Food Home'),
      ),
    );
  }
}

class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Groceries Home'),
      ),
    );
  }
}

class HomeServicesScreen extends StatelessWidget {
  const HomeServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Quick Fix'),
      ),
    );
  }
}

class PersonalDashboardScreen extends StatelessWidget {
  const PersonalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Personal Vault'),
      ),
    );
  }
}

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Doctor Dashboard'),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Admin Dashboard'),
      ),
    );
  }
}

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
  final TextEditingController _searchController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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
      'description':
          'Find doctors, book appointments and get medical support.',
      'icon': Icons.medical_services_rounded,
      'gradient': const [
        Color(0xFF11D999),
        Color(0xFF059669),
      ],
    },
    {
      'title': 'Drunk & Drive',
      'description':
          'Find a trusted driver and get home safely.',
      'icon': Icons.directions_car_filled_rounded,
      'gradient': const [
        Color(0xFFA78BFA),
        Color(0xFF7C3AED),
      ],
    },
    {
      'title': 'Food',
      'description':
          'Discover great food, save money and explore local food services.',
      'icon': Icons.restaurant_rounded,
      'gradient': const [
        Color(0xFFFF8A65),
        Color(0xFFE85D04),
      ],
    },
    {
      'title': 'Groceries',
      'description':
          'Fresh groceries delivered through OneClick partners.',
      'icon': Icons.local_grocery_store_rounded,
      'gradient': const [
        Color(0xFFFFC857),
        Color(0xFFBF8211),
      ],
    },
    {
      'title': 'Quick Fix',
      'description':
          'Find local professionals for all your home and repair needs.',
      'icon': Icons.build_rounded,
      'gradient': const [
        Color(0xFFF87171),
        Color(0xFFDC2626),
      ],
    },
    {
      'title': 'Personal Vault',
      'description':
          'Keep your personal documents and important information secure.',
      'icon': Icons.shield_rounded,
      'gradient': const [
        Color(0xFF38BDF8),
        Color(0xFF0369A1),
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredServices {
    final q = _searchQuery.trim().toLowerCase();

    if (q.isEmpty) return _services;

    return _services.where((service) {
      final title =
          service['title'].toString().toLowerCase();

      final description =
          service['description'].toString().toLowerCase();

      return title.contains(q) ||
          description.contains(q);
    }).toList();
  }

  Future<void> _loadCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _userName = '';
        _userEmail = '';
        _userRole = 'user';
        _isLoadingUser = false;
      });

      return;
    }

    if (mounted) {
      setState(() => _isLoadingUser = true);
    }

    try {
      final doctorSnapshot = await _firestore
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (!mounted ||
          _auth.currentUser?.uid != user.uid) {
        return;
      }

      if (doctorSnapshot.exists) {
        final data = doctorSnapshot.data();

        setState(() {
          _userName =
              data?['name']?.toString() ??
              user.displayName ??
              'Doctor';

          _userEmail =
              data?['email']?.toString() ??
              user.email ??
              '';

          _userRole = 'doctor';
          _isLoadingUser = false;
        });

        return;
      }

      final userSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted ||
          _auth.currentUser?.uid != user.uid) {
        return;
      }

      final data = userSnapshot.data();

      setState(() {
        final name =
            data?['name']?.toString().trim() ?? '';

        _userName = name.isNotEmpty
            ? name
            : (user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!
                  : 'User');

        _userEmail =
            data?['email']?.toString() ??
            user.email ??
            '';

        _userRole =
            data?['role']?.toString().toLowerCase() ??
            'user';

        _isLoadingUser = false;
      });
    } catch (_) {
      if (!mounted ||
          _auth.currentUser?.uid != user.uid) {
        return;
      }

      setState(() {
        _userName =
            user.displayName?.trim().isNotEmpty == true
                ? user.displayName!
                : 'User';

        _userEmail = user.email ?? '';
        _userRole = 'user';
        _isLoadingUser = false;
      });
    }
  }

  void _openProfile() {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          onActivityTap: () {
            Navigator.pop(context);
            _onNavigationSelected(2);
          },
        ),
      ),
    ).then((_) {
      if (mounted) _loadCurrentUser();
    });
  }

  void _openNotifications() {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

  void _onNavigationSelected(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    if (index == 3) {
      _openProfile();
      return;
    }

    if (index == 2 && !_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    final Widget screen;

    switch (index) {
      case 1:
        screen = const OffersScreen();
        break;

      case 2:
        screen = const ActivityScreen();
        break;

      default:
        return;
    }

    setState(() => _selectedIndex = index);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      if (mounted) {
        setState(() => _selectedIndex = 0);
      }
    });
  }

  void _openService(String serviceTitle) {
    Widget? screen;

    switch (serviceTitle) {
      case 'Doctor':
        screen = const DoctorEntryScreen();
        break;

      case 'Drunk & Drive':
        screen = const DrunkDriveHomeScreen();
        break;

      case 'Food':
        screen = const FoodHomeScreen();
        break;

      case 'Groceries':
        screen = const GroceryHomeScreen();
        break;

      case 'Quick Fix':
        screen = const HomeServicesScreen();
        break;

      case 'Personal Vault':
        screen = const PersonalDashboardScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => screen!,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();

      if (!mounted) return;

      setState(() {
        _userName = '';
        _userEmail = '';
        _userRole = 'user';
        _isLoadingUser = false;
        _selectedIndex = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log out'),
        ),
      );
    }
  }

  void _showAccountOptions() {
    if (!_isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _GlassSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _bottomSheetHandle(),
            const SizedBox(height: 24),

            CircleAvatar(
              radius: 34,
              backgroundColor: _Palette.primary,
              child: Text(
                _userName.isNotEmpty
                    ? _userName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              _userName.isEmpty
                  ? 'OneClick User'
                  : _userName,
              style: const TextStyle(
                color: _Palette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _userEmail,
              style: const TextStyle(
                color: _Palette.inkSoft,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 16),

            if (_userRole == 'doctor')
              ListTile(
                leading: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.success,
                ),
                title: const Text(
                  'Switch to Doctor Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DoctorDashboardScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),

            if (_userRole == 'admin')
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: _Palette.primary,
                ),
                title: const Text(
                  'Switch to Admin Portal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                ),
                onTap: () {
                  Navigator.pop(sheetContext);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminDashboard(),
                    ),
                    (route) => false,
                  );
                },
              ),

            ListTile(
              leading: const Icon(
                Icons.person_outline_rounded,
                color: _Palette.primary,
              ),
              title: const Text('My Profile'),
              trailing: const Icon(
                Icons.chevron_right_rounded,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _openProfile();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.notifications_none_rounded,
                color: _Palette.primary,
              ),
              title: const Text('Notifications'),
              trailing: const Icon(
                Icons.chevron_right_rounded,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _openNotifications();
              },
            ),

            ListTile(
              leading: const Icon(
                Icons.history_rounded,
                color: _Palette.primary,
              ),
              title: const Text('My Activity'),
              trailing: const Icon(
                Icons.chevron_right_rounded,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _onNavigationSelected(2);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () async {
                Navigator.pop(sheetContext);
                await _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetHandle() {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: _Palette.line,
        borderRadius: BorderRadius.circular(4),
      ),
    );
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
              SliverToBoxAdapter(
                child: TealHeader(
                  floating: _HomeSearchField(
                    searchController:
                        _searchController,
                    searchQuery: _searchQuery,
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSearchClear: () {
                      _searchController.clear();

                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _HeroCard(
                        userName: _isLoggedIn
                            ? _userName
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    16,
                  ),
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
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _Palette.primary
                              .withValues(alpha: .10),
                          borderRadius:
                              BorderRadius.circular(16),
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
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: .78,
                    ),
                    delegate:
                        SliverChildBuilderDelegate(
                      (context, index) {
                        final service =
                            _filteredServices[index];

                        return _ServiceCard(
                          title:
                              service['title'].toString(),
                          description:
                              service['description']
                                  .toString(),
                          icon:
                              service['icon'] as IconData,
                          gradient: List<Color>.from(
                            service['gradient'] as List,
                          ),
                          onTap: () => _openService(
                            service['title'].toString(),
                          ),
                        );
                      },
                      childCount:
                          _filteredServices.length,
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 40,
                    ),
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

              if (!_isLoggedIn)
                SliverToBoxAdapter(
                  child: _buildGuestCard(),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 104),
              ),
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
              borderRadius: BorderRadius.circular(
                AppRadius.button,
              ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
            _buildNotificationButton(),

            const SizedBox(width: 4),

            GestureDetector(
              onTap: _openProfile,
              onLongPress: _showAccountOptions,
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
                        _userName.isNotEmpty
                            ? _userName[0].toUpperCase()
                            : 'U',
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
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/login',
                );
              },
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
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/register',
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount =
            snapshot.data?.docs.where((doc) {
                  return doc.data()['isRead'] != true;
                }).length ??
                0;

        return IconButton(
          tooltip: 'Notifications',
          onPressed: _openNotifications,
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text(
              unreadCount > 99
                  ? '99+'
                  : unreadCount.toString(),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        32,
        20,
        24,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _Palette.primary,
              _Palette.primaryDeep,
            ],
          ),
          borderRadius: BorderRadius.circular(
            AppRadius.card,
          ),
          boxShadow: [
            BoxShadow(
              color: _Palette.primary
                  .withValues(alpha: .25),
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
                color: Colors.white
                    .withValues(alpha: .80),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/register',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor:
                      _Palette.primary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      AppRadius.button,
                    ),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/login',
                );
              },
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
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.button,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              AppRadius.button,
            ),
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

class _HeroCard extends StatelessWidget {
  final String? userName;

  const _HeroCard({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(alpha: .16),
              borderRadius:
                  BorderRadius.circular(16),
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
            userName != null &&
                    userName!.trim().isNotEmpty
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
              color: Colors.white
                  .withValues(alpha: .85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: _Palette.ink
                .withValues(alpha: .12),
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
          hintStyle: const TextStyle(
            color: _Palette.inkSoft,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _Palette.primary,
          ),
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
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),
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
      borderRadius: BorderRadius.circular(
        AppRadius.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.card,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppRadius.card,
            ),
            boxShadow: [
              BoxShadow(
                color: _Palette.ink
                    .withValues(alpha: .06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent
                      .withValues(alpha: .12),
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.button,
                  ),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 24,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
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
                  overflow:
                      TextOverflow.ellipsis,
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
                      fontWeight:
                          FontWeight.w700,
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

  const _GlassSheet({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(
        top: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            16,
            24,
            32,
          ),
          decoration: BoxDecoration(
            color: Colors.white
                .withValues(alpha: .96),
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: const Border(
              top: BorderSide(
                color: _Palette.line,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: child,
          ),
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

  static const _items = [
    (
      Icons.home_outlined,
      Icons.home_rounded,
      'Home',
    ),
    (
      Icons.local_offer_outlined,
      Icons.local_offer_rounded,
      'Offers',
    ),
    (
      Icons.history_outlined,
      Icons.history_rounded,
      'Activity',
    ),
    (
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16,
        ),
        child: Container(
          height: 64,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: _Palette.ink,
            borderRadius:
                BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _Palette.ink
                    .withValues(alpha: .25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (index) {
                final selected =
                    index == selectedIndex;

                final item = _items[index];

                return Expanded(
                  child: InkWell(
                    onTap: () =>
                        onSelected(index),
                    borderRadius:
                        BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 220,
                      ),
                      curve: Curves.easeOut,
                      margin:
                          const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      padding:
                          EdgeInsets.symmetric(
                        horizontal:
                            selected ? 12 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? _Palette.primary
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            selected
                                ? item.$2
                                : item.$1,
                            color: selected
                                ? Colors.white
                                : Colors.white
                                    .withValues(
                                      alpha: .60,
                                    ),
                            size: 24,
                          ),

                          if (selected) ...[
                            const SizedBox(width: 8),

                            Flexible(
                              child: Text(
                                item.$3,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
