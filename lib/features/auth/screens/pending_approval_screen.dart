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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Approval status')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log in'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval status'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _logOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _StatusContent(
              icon: Icons.wifi_off_rounded,
              title: 'Could not load your status',
              message: 'Check your connection and try again.',
              actionLabel: 'Log out',
              onAction: _logOut,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final document = snapshot.data;

          if (document == null || !document.exists) {
            return _StatusContent(
              icon: Icons.person_off_outlined,
              title: 'Profile not found',
              message: 'Your account profile is unavailable.',
              actionLabel: 'Log out',
              onAction: _logOut,
            );
          }

          final data = document.data() ?? <String, dynamic>{};
          final name = (data['name'] as String?)?.trim() ?? '';
          final role = (data['role'] as String?)?.trim() ?? '';
          final status = (data['status'] as String?)?.trim() ?? '';

          if (status == 'active') {
            _goToRoleGate();

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (status == 'rejected') {
            final rejectionReason =
                (data['rejectionReason'] as String?)?.trim();

            return _StatusContent(
              icon: Icons.cancel_outlined,
              title: 'Registration rejected',
              message: rejectionReason != null &&
                      rejectionReason.isNotEmpty
                  ? rejectionReason
                  : 'Your registration was not approved. '
                      'Please contact support for more information.',
              actionLabel: 'Log out',
              onAction: _logOut,
            );
          }

          if (status != 'pending') {
            return _StatusContent(
              icon: Icons.info_outline,
              title: 'Status unavailable',
              message: 'Please contact support about your account.',
              actionLabel: 'Log out',
              onAction: _logOut,
            );
          }

          final roleName = switch (role) {
            'doctor' => 'doctor',
            'driver' => 'driver',
            _ => 'user',
          };

          return _StatusContent(
            icon: Icons.hourglass_top_rounded,
            title: 'Approval pending',
            message: [
              if (name.isNotEmpty) 'Hi $name!',
              'Your $roleName registration is being reviewed by an admin.',
              'This page will update automatically once a decision is made.',
            ].join('\n\n'),
            actionLabel: 'Log out',
            onAction: _logOut,
          );
        },
      ),
    );
  }
}

class _StatusContent extends StatelessWidget {
  const _StatusContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  child: Icon(icon, size: 42),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.logout),
                    label: Text(actionLabel),
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