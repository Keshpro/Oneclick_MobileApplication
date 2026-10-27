import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _primary = Color(0xff032744);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _notifications = true;
  bool _darkMode = false;
  bool _autoApproval = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load Settings Real-Time from Firestore
  Future<void> _loadSettings() async {
    try {
      final doc = await _firestore
          .collection('system_settings')
          .doc('global_config')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _notifications = data['notificationsEnabled'] ?? true;
            _darkMode = data['darkModeEnabled'] ?? false;
            _autoApproval = data['autoApprovalEnabled'] ?? false;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Save Settings Changes & Log to Firestore
  Future<void> _updateSetting(String key, bool value) async {
    try {
      await _firestore
          .collection('system_settings')
          .doc('global_config')
          .set({key: value}, SetOptions(merge: true));

      // Audit Log Activity
      await _firestore.collection('activity_logs').add({
        'action': 'System Settings Updated',
        'details': 'Updated $key to $value',
        'performedBy': _auth.currentUser?.email ?? 'Admin',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update setting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Change Password Dialog Logic
  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPassword = passwordController.text.trim();
              if (newPassword.length >= 6) {
                try {
                  await _auth.currentUser?.updatePassword(newPassword);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'General Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('System Notifications'),
                        subtitle: const Text(
                          'Receive real-time push and operational alerts',
                        ),
                        secondary: const Icon(Icons.notifications_active_outlined,
                            color: _primary),
                        value: _notifications,
                        activeThumbColor: _primary,
                        onChanged: (value) {
                          setState(() => _notifications = value);
                          _updateSetting('notificationsEnabled', value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Dark Theme'),
                        subtitle: const Text(
                          'Enable dark mode interface across dashboard',
                        ),
                        secondary: const Icon(Icons.dark_mode_outlined,
                            color: _primary),
                        value: _darkMode,
                        activeThumbColor: _primary,
                        onChanged: (value) {
                          setState(() => _darkMode = value);
                          _updateSetting('darkModeEnabled', value);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'System Automation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: SwitchListTile(
                    title: const Text('Auto Approval'),
                    subtitle: const Text(
                      'Automatically approve pending service requests',
                    ),
                    secondary:
                        const Icon(Icons.verified_outlined, color: Colors.green),
                    value: _autoApproval,
                    activeThumbColor: Colors.green,
                    onChanged: (value) {
                      setState(() => _autoApproval = value);
                      _updateSetting('autoApprovalEnabled', value);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Account & Security',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: _primary),
                    title: const Text('Change Account Password'),
                    subtitle: const Text('Update your login security credentials'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showChangePasswordDialog,
                  ),
                ),
              ],
            ),
    );
  }
}