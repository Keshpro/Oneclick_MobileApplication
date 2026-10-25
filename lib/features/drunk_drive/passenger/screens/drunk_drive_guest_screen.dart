import 'package:flutter/material.dart';

/// Public introduction to Drunk & Drive. Does not access Firebase or bookings.
class DrunkDriveGuestScreen extends StatelessWidget {
  const DrunkDriveGuestScreen({super.key});

  static const _teal = Color(0xFF076B75);
  static const _ink = Color(0xFF122B35);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9),
      appBar: AppBar(
        title: const Text('Drunk & Drive'),
        backgroundColor: const Color(0xFFF4F9F9),
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF087F8C), Color(0xFF07545E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shield_rounded, color: Color(0xFFB8F5E7)),
                            SizedBox(width: 8),
                            Text('ONECLICK  •  DRUNK & DRIVE',
                                style: TextStyle(color: Colors.white, fontSize: 12,
                                    letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_car_filled_rounded,
                                color: Colors.white, size: 65),
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text('Your way home,\nmade safer.',
                            style: TextStyle(color: Colors.white,
                                fontSize: 30, fontWeight: FontWeight.w900, height: 1.13)),
                        const SizedBox(height: 12),
                        const Text(
                          'Need someone to drive your car? Book an approved driver and travel home in your own vehicle.',
                          style: TextStyle(color: Color(0xFFE1F7F5), fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text('How it works',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink)),
                  const SizedBox(height: 15),
                  const _GuestFeature(
                    icon: Icons.location_on_outlined,
                    title: 'Choose your journey',
                    description: 'Enter your pickup and destination locations.',
                  ),
                  const SizedBox(height: 10),
                  const _GuestFeature(
                    icon: Icons.verified_user_outlined,
                    title: 'Connect with a driver',
                    description: 'Request a driver approved by OneClick.',
                  ),
                  const SizedBox(height: 10),
                  const _GuestFeature(
                    icon: Icons.route_outlined,
                    title: 'Manage your trip',
                    description: 'View trip progress and recorded payment details.',
                  ),
                  const SizedBox(height: 28),
                  const Text('Ready to get started?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _ink)),
                  const SizedBox(height: 7),
                  const Text('Log in to request a driver, or create an account to join OneClick.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Color(0xFF607880))),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/login'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Log In',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _teal,
                        side: const BorderSide(color: _teal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Create Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBDE1DA)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_taxi_rounded, color: _teal, size: 29),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Interested in becoming a driver?',
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Join the OneClick Drunk & Drive driver network. '
                          'Sign in with your existing account or create one, '
                          'then submit a driver application for admin review.',
                          style: TextStyle(
                            color: Color(0xFF456A72),
                            fontSize: 13.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/login'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _teal,
                              side: const BorderSide(color: _teal, width: 1.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.drive_eta_rounded),
                            label: const Text(
                              'Become a Driver — Log In',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'After login: Drunk & Drive → Drunk & Drive Driver Registration',
                          style: TextStyle(fontSize: 12, color: Color(0xFF456A72)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Drive responsibly. Never drive while impaired.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF607880))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestFeature extends StatelessWidget {
  const _GuestFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDCE9E9)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: DrunkDriveGuestScreen._teal),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                        color: DrunkDriveGuestScreen._ink)),
                const SizedBox(height: 3),
                Text(description,
                    style: const TextStyle(fontSize: 12.5,
                        height: 1.4, color: Color(0xFF607880))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
