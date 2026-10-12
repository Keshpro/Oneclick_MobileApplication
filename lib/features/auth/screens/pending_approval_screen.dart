import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  bool _navigating = false;

  Future<void> _logOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _goToRoleGate() {
    if (_navigating) return;
    _navigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/role-gate',
        (route) => false,
      );
    });
  }

  Future<String> _getProviderCollection(String uid) async {
    final doctorDoc =
        await FirebaseFirestore.instance.collection('doctors').doc(uid).get();
    if (doctorDoc.exists) return 'doctors';

    final driverDoc =
        await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
    if (driverDoc.exists) return 'drivers';

    return 'users';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff032744).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 60,
                      color: Color(0xff032744),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Session Expired',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please log in again to check your account status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff032744),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Back to Login',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Application Status'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _logOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _getProviderCollection(user.uid),
        builder: (context, collectionSnapshot) {
          if (collectionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final collectionName = collectionSnapshot.data ?? 'users';

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(collectionName)
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ModernStatusCard(
                  icon: Icons.wifi_off_rounded,
                  iconColor: Colors.orange,
                  title: 'Network Error',
                  message: 'Could not fetch status. Check internet connection.',
                  actionLabel: 'Log Out',
                  onAction: _logOut,
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return _ModernStatusCard(
                  icon: Icons.person_off_outlined,
                  iconColor: Colors.red,
                  title: 'Account Not Found',
                  message:
                      'Your provider application was not found in database.',
                  actionLabel: 'Log Out',
                  onAction: _logOut,
                );
              }

              final data = snapshot.data!.data() ?? <String, dynamic>{};
              final name = (data['name'] as String?)?.trim() ?? '';
              final role = (data['role'] as String?)?.trim() ?? '';
              final status = (data['status'] as String?)?.trim() ?? '';

              if (status == 'active' || status == 'approved') {
                _goToRoleGate();
                return const Center(child: CircularProgressIndicator());
              }

              if (status == 'rejected') {
                final reason = (data['rejectionReason'] as String?)?.trim();
                return _ModernStatusCard(
                  icon: Icons.cancel_outlined,
                  iconColor: Colors.red,
                  title: 'Application Rejected',
                  message: reason != null && reason.isNotEmpty
                      ? 'Reason: $reason'
                      : 'Unfortunately, your provider account registration was not approved. Please contact support.',
                  actionLabel: 'Back to Login',
                  onAction: _logOut,
                );
              }

              final roleName = role.isNotEmpty
                  ? role[0].toUpperCase() + role.substring(1)
                  : 'Provider';

              return _ModernStatusCard(
                icon: Icons.hourglass_top_rounded,
                iconColor: Colors.amber.shade800,
                title: 'Approval Pending',
                message:
                    'Hi ${name.isNotEmpty ? name : 'there'}!\n\nYour $roleName account application has been received and is currently under review by our Admin team.\n\nOnce approved, you will be able to access the dashboard automatically.',
                actionLabel: 'Log Out',
                onAction: _logOut,
              );
            },
          );
        },
      ),
    );
  }
}

class _ModernStatusCard extends StatelessWidget {
  const _ModernStatusCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: iconColor),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff032744),
                      side: const BorderSide(color: Color(0xff032744)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onAction,
                    icon: const Icon(Icons.logout, size: 20),
                    label: Text(
                      actionLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}