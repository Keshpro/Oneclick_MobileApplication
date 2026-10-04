import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  final String title;

  const UserManagementScreen({
    super.key,
    required this.title,
  });

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends State<UserManagementScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Amal Perera',
      'email': 'amal@gmail.com',
      'role': 'Customer',
      'status': 'Active',
    },
    {
      'name': 'Kamal Silva',
      'email': 'kamal@gmail.com',
      'role': 'Driver',
      'status': 'Active',
    },
    {
      'name': 'Nimal Fernando',
      'email': 'nimal@gmail.com',
      'role': 'Seller',
      'status': 'Blocked',
    },
    {
      'name': 'Kasun Peris',
      'email': 'kasun@gmail.com',
      'role': 'Doctor',
      'status': 'Active',
    },
  ];

  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = List.from(users);

    searchController.addListener(_searchUsers);
  }

  void _searchUsers() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredUsers = users.where((user) {
        return user['name']
                .toString()
                .toLowerCase()
                .contains(query) ||
            user['email']
                .toString()
                .toLowerCase()
                .contains(query) ||
            user['role']
                .toString()
                .toLowerCase()
                .contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        user['name'][0],
                      ),
                    ),

                    title: Text(
                      user['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      '${user['email']}\n'
                      '${user['role']} • ${user['status']}',
                    ),

                    isThreeLine: true,

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'block') {
                          _changeStatus(index, 'Blocked');
                        }

                        if (value == 'activate') {
                          _changeStatus(index, 'Active');
                        }

                        if (value == 'delete') {
                          _deleteUser(index);
                        }
                      },
                      itemBuilder: (_) => [
                        if (user['status'] == 'Active')
                          const PopupMenuItem(
                            value: 'block',
                            child: Text('Block User'),
                          ),

                        if (user['status'] == 'Blocked')
                          const PopupMenuItem(
                            value: 'activate',
                            child: Text('Activate User'),
                          ),

                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete User'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _changeStatus(int index, String status) {
    final userName = filteredUsers[index]['name'];

    setState(() {
      final actualIndex = users.indexOf(filteredUsers[index]);

      users[actualIndex]['status'] = status;

      filteredUsers[index]['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$userName is now $status'),
      ),
    );
  }

  void _deleteUser(int index) {
    final userName = filteredUsers[index]['name'];

    setState(() {
      users.remove(filteredUsers[index]);
      filteredUsers.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$userName deleted'),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}