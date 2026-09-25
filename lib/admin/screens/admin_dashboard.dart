import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'pending_accounts.dart';
import 'user_management.dart';
import '../../features/auth/screens/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.pending_actions, color: Colors.orange, size: 36),
                title: const Text('Pending Approvals'),
                subtitle: const Text('Review & approve newly registered accounts'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PendingAccountsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.manage_accounts, color: Colors.indigo, size: 36),
                title: const Text('User Management'),
                subtitle: const Text('View, update, or remove users (CRUD)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
=======

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Admin dashboard')));
}
>>>>>>> Stashed changes
