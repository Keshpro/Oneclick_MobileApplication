import 'package:flutter/material.dart';
import 'package:oneclick/features/auth/screens/pending_approval_screen.dart';

import 'user_management.dart';
import '../../features/auth/screens/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Pending Account Approvals
            Card(
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),

                leading: const Icon(
                  Icons.verified_user,
                  color: Colors.orange,
                  size: 40,
                ),

                title: const Text(
                  'Pending Account Approvals',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),

                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('ලියාපදිංචි වූ නව ගිණුම් පරීක්ෂා කර අනුමත කරන්න'),
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PendingAccountsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // User Management
            Card(
              elevation: 3,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),

                leading: const Icon(Icons.people, color: Colors.blue, size: 40),

                title: const Text(
                  'User Management',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),

                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('සියලුම Users ලා පාලනය කරන්න (CRUD)'),
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserManagementScreen(),
                    ),
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

class LoginScreen {
  const new();
}
