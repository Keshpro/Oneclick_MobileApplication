import 'dart:ui';

import 'package:flutter/material.dart';

import 'services_screen.dart';
import 'explore_screen.dart';

import '../../doctor/patient/screens/doctor_entry_screen.dart';
import '../../drunk_drive/passenger/screens/drunk_drive_home_screen.dart';
import '../../Personal Vault/screens/dashboard.dart' as personal_vault;
import '../../food/screens/food_home_screen.dart';

// ============================================================
// PALETTE
// ============================================================

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

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0;
  String _searchQuery = '';

  // ============================================================
  // SERVICES
  // ============================================================

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
      'title': 'Personal Vault',
      'description':
          'Keep your personal documents and important information secure.',
      'icon': Icons.shield_rounded,
      'gradient': const [Color(0xFF38BDF8), Color(0xFF0369A1)],
    },
  ];

  // ============================================================
  // FILTER
  // ============================================================

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.trim().isEmpty) {
      return _services;
    }

    final query = _searchQuery.trim().toLowerCase();

    return _services.where((service) {
      final title = service['title'].toString().toLowerCase();

      final description = service['description'].toString().toLowerCase();

      return title.contains(query) || description.contains(query);
    }).toList();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

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
            // ==================================================
            // HEADER
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_Palette.primary, _Palette.primaryDeep],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: _Palette.primary.withValues(alpha: 0.35),
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
                              letterSpacing: -0.3,
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

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _Palette.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),

                    const SizedBox(width: 2),

                    _GradientButton(
                      label: 'Register',
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // HERO
            // ==================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: _HeroCard(
                  searchController: _searchController,
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
              ),
            ),

            // ==================================================
            // SERVICES TITLE
            // ==================================================
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
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _Palette.primary.withValues(alpha: 0.08),
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
                    childAspectRatio: 0.86,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final service = _filteredServices[index];

                    return _ServiceCard(
                      title: service['title'].toString(),
                      description: service['description'].toString(),
                      icon: service['icon'] as IconData,
                      gradient: List<Color>.from(service['gradient']),
                      onTap: () {
                        _openService(service['title'].toString());
                      },
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

            // ==================================================
            // CREATE ACCOUNT SECTION
            // ==================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_Palette.primary, _Palette.primaryDeep],
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: _Palette.primary.withValues(alpha: 0.30),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Ready to get started?',
                        textAlign: TextAlign.center,
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
                          color: Colors.white.withValues(alpha: 0.78),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _Palette.primaryDeep,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM NAV
      // ========================================================
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: _selectedIndex,
        onSelected: _onNavigationSelected,
      ),
    );
  }

  // ============================================================
  // SERVICE NAVIGATION
  // ============================================================

  void _openService(String serviceTitle) {
    switch (serviceTitle) {
      // --------------------------------------------------------
      // DOCTOR
      // --------------------------------------------------------

      case 'Doctor':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DoctorEntryScreen()),
        );
        break;

      // --------------------------------------------------------
      // DRUNK & DRIVE
      // --------------------------------------------------------

      case 'Drunk & Drive':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DrunkDriveHomeScreen()),
        );
        break;

      // --------------------------------------------------------
      // FOOD
      // --------------------------------------------------------

      case 'Food':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FoodHomeScreen()),
        );
        break;

      // --------------------------------------------------------
      // PERSONAL VAULT
      // FIXED:
      // PersonalDashboardScreen is the actual Widget.
      // --------------------------------------------------------

      case 'Personal Vault':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const personal_vault.PersonalDashboardScreen(),
          ),
        );
        break;

      // --------------------------------------------------------
      // GROCERIES
      // --------------------------------------------------------

      case 'Groceries':
        _showLoginRequired('Groceries');
        break;

      default:
        _showLoginRequired(serviceTitle);
    }
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onNavigationSelected(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      setState(() {
        _selectedIndex = 1;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServicesScreen()),
      ).then((_) {
        if (!mounted) return;

        setState(() {
          _selectedIndex = 0;
        });
      });

      return;
    }

    if (index == 2) {
      setState(() {
        _selectedIndex = 2;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExploreScreen()),
      ).then((_) {
        if (!mounted) return;

        setState(() {
          _selectedIndex = 0;
        });
      });

      return;
    }

    if (index == 3) {
      setState(() {
        _selectedIndex = 3;
      });

      _showAccountOptions();
    }
  }

  // ============================================================
  // LOGIN REQUIRED SHEET
  // ============================================================

  void _showLoginRequired(String serviceName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _GlassSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomSheetHandle(),

              const SizedBox(height: 25),

              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_Palette.primary, _Palette.primaryDeep],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 17),

              Text(
                'Access $serviceName',
                textAlign: TextAlign.center,
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

              const SizedBox(height: 22),

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

              const SizedBox(height: 7),

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
        );
      },
    ).whenComplete(() {
      if (!mounted) return;

      if (_selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  // ============================================================
  // ACCOUNT SHEET
  // ============================================================

  void _showAccountOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _GlassSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomSheetHandle(),

              const SizedBox(height: 25),

              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_Palette.primary, _Palette.primaryDeep],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 17),

              const Text(
                'Welcome to OneClick',
                style: TextStyle(
                  color: _Palette.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Login to access your account and personalized services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _Palette.inkSoft,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

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

              const SizedBox(height: 7),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);

                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _Palette.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      if (!mounted) return;

      setState(() {
        _selectedIndex = 0;
      });
    });
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _bottomSheetHandle() {
    return Container(
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: _Palette.line,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _Palette.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

// ============================================================
// GRADIENT BUTTON
// ============================================================

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
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_Palette.primary, _Palette.primaryDeep],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _Palette.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
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
}

// ============================================================
// HERO CARD
// ============================================================

class _HeroCard extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;

  const _HeroCard({
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: _Palette.primary.withValues(alpha: 0.30),
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
                  color: _Palette.accent2.withValues(alpha: 0.25),
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
                  color: _Palette.accent.withValues(alpha: 0.20),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'ONE APP • MULTIPLE SERVICES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
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
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Discover services, find the right people and get things done with OneClick.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
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
}

// ============================================================
// SERVICE CARD
// ============================================================

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
    return Material(
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
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.last.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
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
                  letterSpacing: -0.2,
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
}

// ============================================================
// GLASS SHEET
// ============================================================

class _GlassSheet extends StatelessWidget {
  final Widget child;

  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: const Border(top: BorderSide(color: _Palette.line)),
          ),
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}

// ============================================================
// FLOATING NAVIGATION BAR
// ============================================================

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
  Widget build(BuildContext context) {
    return SafeArea(
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
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _Palette.line),
                boxShadow: [
                  BoxShadow(
                    color: _Palette.ink.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (index) {
                  final selected = index == selectedIndex;

                  final item = _items[index];

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        onSelected(index);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 4,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: selected ? 14 : 0,
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
}
