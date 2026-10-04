import 'package:flutter/material.dart';

class PendingAccounts extends StatefulWidget {
  const PendingAccounts({super.key});

  @override
  State<PendingAccounts> createState() => _PendingAccountsState();
}

class _PendingAccountsState extends State<PendingAccounts> {
  final List<Map<String, String>> accounts = [
    {
      'name': 'John Perera',
      'email': 'john@gmail.com',
      'role': 'Driver',
    },
    {
      'name': 'Kasun Silva',
      'email': 'kasun@gmail.com',
      'role': 'Seller',
    },
    {
      'name': 'Nimal Fernando',
      'email': 'nimal@gmail.com',
      'role': 'Doctor',
    },
    {
      'name': 'Amal Peris',
      'email': 'amal@gmail.com',
      'role': 'Delivery Rider',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Accounts'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: accounts.isEmpty
          ? const Center(
              child: Text('No pending accounts'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.person),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account['name']!,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(account['email']!),
                                  Text(
                                    'Role: ${account['role']}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                _rejectAccount(index);
                              },
                              child: const Text(
                                'Reject',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton(
                              onPressed: () {
                                _approveAccount(index);
                              },
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _approveAccount(int index) {
    final name = accounts[index]['name'];

    setState(() {
      accounts.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name approved successfully'),
      ),
    );
  }

  void _rejectAccount(int index) {
    final name = accounts[index]['name'];

    setState(() {
      accounts.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name rejected'),
      ),
    );
  }
}