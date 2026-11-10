import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Edit Field Dialog Function
  void _showEditDialog({
    required String title,
    required String initialValue,
    required String firestoreKey,
  }) {
    final controller = TextEditingController(text: initialValue);
    final uid = _currentUser?.uid;
    if (uid == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit $title', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              await FirebaseFirestore.instance.collection('users').doc(uid).set({
                firestoreKey: newValue,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title updated successfully!'), backgroundColor: _primary),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view profile.')),
      );
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
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() ?? {};
            final name = data['name'] ?? user.displayName ?? user.email?.split('@').first ?? 'Patient';
            final email = user.email ?? 'patient@oneclick.health';
            final bloodGroup = data['bloodGroup'] ?? 'O+';
            final height = data['height'] ?? '172 cm';
            final weight = data['weight'] ?? '68 kg';
            final allergies = data['allergies'] ?? 'None reported';
            final conditions = data['conditions'] ?? 'None reported';
            final emergencyContact = data['emergencyContact'] ?? 'Not added';

            return SingleChildScrollView(
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

                  // Health Vitals Overview (Clickable to Edit)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showEditDialog(title: 'Blood Group', initialValue: bloodGroup, firestoreKey: 'bloodGroup'),
                          borderRadius: BorderRadius.circular(18),
                          child: _vitalCard(
                            icon: Icons.bloodtype_outlined,
                            title: 'Blood Group',
                            value: bloodGroup,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showEditDialog(title: 'Height', initialValue: height, firestoreKey: 'height'),
                          borderRadius: BorderRadius.circular(18),
                          child: _vitalCard(
                            icon: Icons.height_rounded,
                            title: 'Height',
                            value: height,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showEditDialog(title: 'Weight', initialValue: weight, firestoreKey: 'weight'),
                          borderRadius: BorderRadius.circular(18),
                          child: _vitalCard(
                            icon: Icons.monitor_weight_outlined,
                            title: 'Weight',
                            value: weight,
                            color: Colors.orange,
                          ),
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
                      subtitle: allergies,
                      iconColor: Colors.amber[700]!,
                      onTap: () => _showEditDialog(title: 'Allergies', initialValue: allergies, firestoreKey: 'allergies'),
                    ),
                    const Divider(height: 1),
                    _profileListTile(
                      icon: Icons.medical_information_outlined,
                      title: 'Chronic Conditions',
                      subtitle: conditions,
                      iconColor: _primary,
                      onTap: () => _showEditDialog(title: 'Chronic Conditions', initialValue: conditions, firestoreKey: 'conditions'),
                    ),
                    const Divider(height: 1),
                    _profileListTile(
                      icon: Icons.emergency_outlined,
                      title: 'Emergency Contact',
                      subtitle: emergencyContact,
                      iconColor: _red,
                      onTap: () => _showEditDialog(title: 'Emergency Contact', initialValue: emergencyContact, firestoreKey: 'emergencyContact'),
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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications are managed via system settings.')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _profileListTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacy & Security',
                      subtitle: 'Password protection active',
                      iconColor: Colors.indigo,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account secured with Firebase Authentication.')),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Logout Button
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
            );
          },
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