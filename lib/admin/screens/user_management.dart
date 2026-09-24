import 'package:flutter/material.dart';
import '../services/services/admin_service.dart';
import '../shared/models/user_model.dart';

class UserManagementScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management (CRUD)')),
      body: StreamBuilder<List<UserModel>>(
        stream: _adminService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text('${user.email} | Status: ${user.status.name}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('ගිණුම ඉවත් කරන්නද?'),
                        content: Text('${user.name} ගේ ගිණුම සම්පූර්ණයෙන් මකා දැමීමට අවශ්‍යද?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('නැත'),
                          ),
                          TextButton(
                            onPressed: () {
                              _adminService.deleteUser(user.uid);
                              Navigator.pop(ctx);
                            },
                            child: const Text('ඔවු', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}