import 'package:flutter/material.dart';

import 'worker_dashboard_screen.dart';
import '../services/worker_auth_service.dart';
import 'worker_login_screen.dart';

class WorkerMainScreen extends StatelessWidget {
  const WorkerMainScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await WorkerAuthService.instance.logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WorkerLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const WorkerDashboardScreen(),
    );
  }
}
