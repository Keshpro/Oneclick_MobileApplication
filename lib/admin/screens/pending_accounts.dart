import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../../shared/models/user_model.dart';

class PendingAccountsScreen extends StatefulWidget {
  const PendingAccountsScreen({Key? key}) : super(key: key);

  @override
  State<PendingAccountsScreen> createState() => _PendingAccountsScreenState();
}

class _PendingAccountsScreenState extends State<PendingAccountsScreen> {
  final AdminService _adminService = AdminService();
  late List<UserModel> _pendingUsers;

  @override
  void initState() {
    super.initState();
    _pendingUsers = _adminService.getPendingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: _pendingUsers.isEmpty
          ? const Center(child: Text('No pending account requests.'))
          : ListView.builder(
              itemCount: _pendingUsers.length,
              itemBuilder: (context, index) {
                final user = _pendingUsers[index];
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
                          onPressed: () {
                            setState(() => _pendingUsers.removeAt(index));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${user.name} Approved!')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                          onPressed: () {
                            setState(() => _pendingUsers.removeAt(index));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${user.name} Rejected!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}