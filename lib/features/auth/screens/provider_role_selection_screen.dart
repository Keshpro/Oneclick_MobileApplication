import 'package:flutter/material.dart';
import '../../groceries/seller/screens/become_seller_screen.dart';

import 'provider_register_screen.dart';

class ProviderRoleSelectionScreen
    extends StatelessWidget {
  const ProviderRoleSelectionScreen({
    super.key,
  });

  void _selectRole(
    BuildContext context,
    ProviderRole role,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderRegisterScreen(
          role: role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FC),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Choose Provider Role',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'How would you like\nto earn?',
                style: TextStyle(
                  color: Color(0xFF17152A),
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Select the service you want to provide through OneClick.',
                style: TextStyle(
                  color: Color(0xFF747187),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              _ProviderRoleCard(
                title: 'Doctor',
                description:
                    'Provide healthcare services and receive appointment requests.',
                icon:
                    Icons.medical_services_rounded,
                colors: const [
                  Color(0xFF11D999),
                  Color(0xFF059669),
                ],
                onTap: () => _selectRole(
                  context,
                  ProviderRole.doctor,
                ),
              ),

              const SizedBox(height: 16),

              _ProviderRoleCard(
                title: 'Driver',
                description:
                    'Join the driver network and receive customer ride requests.',
                icon:
                    Icons.directions_car_rounded,
                colors: const [
                  Color(0xFFA78BFA),
                  Color(0xFF7C3AED),
                ],
                onTap: () => _selectRole(
                  context,
                  ProviderRole.driver,
                ),
              ),

              const SizedBox(height: 16),

              _ProviderRoleCard(
                title: 'Grocery Seller',
                description:
                    'Sell groceries and receive orders from customers.',
                icon:
                    Icons.local_grocery_store_rounded,
                colors: const [
                  Color(0xFFFFD54F),
                  Color(0xFFFFA000),
                ],
              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const BecomeSellerScreen(),
    ),
  );
},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderRoleCard
    extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ProviderRoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE4E2EC),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: colors),
                  borderRadius:
                      BorderRadius.circular(19),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color:
                            Color(0xFF17152A),
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color:
                            Color(0xFF747187),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF5B4DFF),
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}