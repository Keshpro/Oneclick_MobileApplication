import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../../shared/models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminService _adminService = AdminService();
  late List<UserModel> _allUsers;

  @override
  void initState() {
    super.initState();
    _allUsers = _adminService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView.builder(
        itemCount: _allUsers.length,
        itemBuilder: (context, index) {
          final user = _allUsers[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text('${user.email} | Role: ${user.role.name}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() => _allUsers.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user.name} deleted')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}