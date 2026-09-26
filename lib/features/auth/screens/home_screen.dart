import 'package:flutter/material.dart';

import 'services_screen.dart';
import 'explore_screen.dart';
import '../../doctor/patient/screens/patient_home_screen.dart';
import '../../doctor/patient/screens/doctor_entry_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  int _selectedIndex = 0;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Doctor',
      'description': 'Find doctors, book appointments and get medical support.',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFF2563EB),
    },
    {
      'title': 'Drunk & Drive',
      'description': 'Find a trusted driver and get home safely.',
      'icon': Icons.directions_car_filled_rounded,
      'color': const Color(0xFF7C3AED),
    },
    {
      'title': 'Service 03',
      'description': 'Explore more services available through OneClick.',
      'icon': Icons.home_repair_service_rounded,
      'color': const Color(0xFF059669),
    },
    {
      'title': 'Service 04',
      'description': 'Discover another service available in OneClick.',
      'icon': Icons.local_mall_rounded,
      'color': const Color(0xFFEA580C),
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_searchQuery.trim().isEmpty) {
      return _services;
    }

    final query = _searchQuery.toLowerCase();

    return _services.where((service) {
      final title = service['title'].toString().toLowerCase();
      final description = service['description'].toString().toLowerCase();

      return title.contains(query) || description.contains(query);
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
      backgroundColor: const Color(0xFFF8FAFC),

      // =========================
      // MAIN CONTENT
      // =========================
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // =========================
            // HEADER
            // =========================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // App name
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OneClick',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Everything in one place',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Login
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Register
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // HERO
            // =========================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'ONE APP • MULTIPLE SERVICES',
                          style: TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'What do you\nneed today?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          height: 1.08,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Discover services, find the right people and get things done with OneClick.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Search
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search services...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF64748B),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();

                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: const Icon(Icons.close_rounded),
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
              ),
            ),

            // =========================
            // SERVICES TITLE
            // =========================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Explore Services',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${_filteredServices.length} Categories',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // SERVICE CARDS
            // =========================
            if (_filteredServices.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final service = _filteredServices[index];

                    return ServiceCard(
                      title: service['title'],
                      description: service['description'],
                      icon: service['icon'],
                      color: service['color'],
                      onTap: () {
                        if (service['title'] == 'Doctor') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorEntryScreen(),
                            ),
                          );
                        } else {
                          _showLoginRequired(service['title']);
                        }
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
                        size: 50,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No services found',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // =========================
            // JOIN SECTION
            // =========================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 35),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Color(0xFF2563EB),
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Ready to get started?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Create an account to access services and manage everything from one place.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
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
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 68,
            elevation: 0,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFDBEAFE),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onNavigationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  color: Color(0xFF2563EB),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF2563EB),
                ),
                label: 'Services',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(
                  Icons.explore_rounded,
                  color: Color(0xFF2563EB),
                ),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: Color(0xFF2563EB),
                ),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // BOTTOM NAVIGATION LOGIC
  // =========================

  void _onNavigationSelected(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ServicesScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });

      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExploreScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
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

  // =========================
  // SERVICE LOGIN REQUIRED
  // =========================

  void _showLoginRequired(String serviceName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bottomSheetHandle(),

                const SizedBox(height: 25),

                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF2563EB),
                    size: 31,
                  ),
                ),

                const SizedBox(height: 17),

                Text(
                  'Access $serviceName',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login or create an account to continue using this service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
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
                      style: TextStyle(fontWeight: FontWeight.w700),
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
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted && _selectedIndex != 0) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  // =========================
  // ACCOUNT BOTTOM SHEET
  // =========================

  void _showAccountOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bottomSheetHandle(),

                const SizedBox(height: 25),

                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),

                const SizedBox(height: 17),

                const Text(
                  'Welcome to OneClick',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login to access your account and personalized services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
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
                      style: TextStyle(fontWeight: FontWeight.w700),
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
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  Widget _bottomSheetHandle() {
    return Container(
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

// =========================
// SERVICE CARD
// =========================

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 27),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
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
                  color: Color(0xFF64748B),
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
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: color, size: 17),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
