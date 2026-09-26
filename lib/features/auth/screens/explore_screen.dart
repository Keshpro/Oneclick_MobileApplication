import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  void _loginRequired(
    BuildContext context,
    String feature,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            14,
            24,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 24),

                const Icon(
                  Icons.lock_outline_rounded,
                  size: 50,
                  color: Color(0xFF2563EB),
                ),

                const SizedBox(height: 16),

                Text(
                  '$feature requires an account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Login or create your OneClick account to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(
                        context,
                        '/login',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(
                      context,
                      '/register',
                    );
                  },
                  child: const Text(
                    'Create Account',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Doctor',
        'subtitle':
            'Find doctors and manage appointments',
        'icon': Icons.medical_services_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'title': 'Safe Ride',
        'subtitle':
            'Find a trusted driver when you need one',
        'icon': Icons.directions_car_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'title': 'Nearby Services',
        'subtitle':
            'Discover useful services around you',
        'icon': Icons.location_on_rounded,
        'color': const Color(0xFF059669),
      },
      {
        'title': 'More Services',
        'subtitle':
            'Explore everything available in OneClick',
        'icon': Icons.apps_rounded,
        'color': const Color(0xFFEA580C),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Discover OneClick',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.explore_rounded,
                  color: Color(0xFF93C5FD),
                  size: 36,
                ),
                SizedBox(height: 18),
                Text(
                  'Discover what\nOneClick can do.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore services designed to make everyday tasks easier.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Discover Services',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'See what is available through OneClick.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(18),
                  onTap: () {
                    _loginRequired(
                      context,
                      item['title'],
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color)
                                .withValues(alpha: 0.10),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['color'],
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  color:
                                      Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['subtitle'],
                                style: const TextStyle(
                                  color:
                                      Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF2563EB),
                  size: 32,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Unlock all services',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Create your OneClick account to start using available services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
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
                      backgroundColor:
                          const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
