import 'package:flutter/material.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  final List<Map<String, dynamic>> users = [
    {
      'name': 'Amal Silva',
      'email': 'amal@gmail.com',
      'type': 'Customer',
      'date': '2026-10-01',
    },
    {
      'name': 'Kamal Perera',
      'email': 'kamal@gmail.com',
      'type': 'Seller',
      'date': '2026-10-02',
    },
    {
      'name': 'Nimal Fernando',
      'email': 'nimal@gmail.com',
      'type': 'Driver',
      'date': '2026-10-03',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Users'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),

              title: Text(
                user['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email']),
                  Text('Type: ${user['type']}'),
                  Text('Date: ${user['date']}'),
                ],
              ),

              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'approve') {
                    _approve(index);
                  } else {
                    _reject(index);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'approve',
                    child: Text('Approve'),
                  ),
                  PopupMenuItem(
                    value: 'reject',
                    child: Text('Reject'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _approve(int index) {
    final name = users[index]['name'];

    setState(() {
      users.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name approved')),
    );
  }

  void _reject(int index) {
    final name = users[index]['name'];

    setState(() {
      users.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name rejected')),
    );
  }
}