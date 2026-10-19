import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _text = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _primary = Color(0xFF059669);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _red = Color(0xFFEF4444);

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    String name = 'OneClick Patient';
    String email = 'patient@oneclick.health';

    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        name = user.displayName!;
      } else if (user.email != null) {
        name = user.email!.split('@').first;
      }
      if (user.email != null) email = user.email!;
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _text,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: _primary,
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(fontSize: 12, color: _muted),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Verified Account',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Health Vitals Overview
              Row(
                children: [
                  Expanded(
                    child: _vitalCard(
                      icon: Icons.bloodtype_outlined,
                      title: 'Blood Group',
                      value: 'O+',
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _vitalCard(
                      icon: Icons.height_rounded,
                      title: 'Height',
                      value: '172 cm',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _vitalCard(
                      icon: Icons.monitor_weight_outlined,
                      title: 'Weight',
                      value: '68 kg',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Medical Records Info
              const Text(
                'MEDICAL INFORMATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              _sectionContainer([
                _profileListTile(
                  icon: Icons.warning_amber_rounded,
                  title: 'Allergies',
                  subtitle: 'Penicillin, Peanuts',
                  iconColor: Colors.amber[700]!,
                  onTap: () {},
                ),
                const Divider(height: 1),
                _profileListTile(
                  icon: Icons.medical_information_outlined,
                  title: 'Chronic Conditions',
                  subtitle: 'None reported',
                  iconColor: _primary,
                  onTap: () {},
                ),
                const Divider(height: 1),
                _profileListTile(
                  icon: Icons.emergency_outlined,
                  title: 'Emergency Contact',
                  subtitle: '+94 77 123 4567 (Spouse)',
                  iconColor: _red,
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),

              // Account Settings
              const Text(
                'SETTINGS & PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: _muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              _sectionContainer([
                _profileListTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification Settings',
                  subtitle: 'Reminders & SMS Alerts',
                  iconColor: Colors.purple,
                  onTap: () {},
                ),
                const Divider(height: 1),
                _profileListTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy & Security',
                  subtitle: 'Change password & Biometrics',
                  iconColor: Colors.indigo,
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),

              // Logout Button
              if (user != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout_rounded, color: _red),
                    label: const Text(
                      'Logout Account',
                      style: TextStyle(
                        color: _red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vitalCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: _muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(children: children),
    );
  }

  Widget _profileListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: _text,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: _muted),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: _muted,
        size: 20,
      ),
    );
  }
}