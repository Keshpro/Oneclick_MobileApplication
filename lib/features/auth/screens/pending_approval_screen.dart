import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../../shared/models/user_model.dart';

class PendingAccountsScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  PendingAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Account Approvals')),
      body: StreamBuilder<List<UserModel>>(
        stream: _adminService.getPendingUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('අනුමත කිරීමට ගිණුම් නොමැත.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${user.email}\nRole: ${user.role.name.toUpperCase()}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                        onPressed: () => _adminService.updateUserStatus(
                          user.uid,
                          AccountStatus.approved,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                        onPressed: () => _adminService.updateUserStatus(
                          user.uid,
                          AccountStatus.rejected,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}