
import 'package:flutter/material.dart';

class IncomingRequestsScreen extends StatefulWidget {
  const IncomingRequestsScreen({super.key});

  @override
  State<IncomingRequestsScreen> createState() =>
      _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState
    extends State<IncomingRequestsScreen> {
  final List<Map<String, String>> requests = [
    {
      'name': 'Kasun Perera',
      'category': 'Electrician',
      'area': 'Bentota',
      'description': 'Repair a broken ceiling fan.',
      'phone': '0771234567',
    },
    {
      'name': 'Nimali Silva',
      'category': 'Electrician',
      'area': 'Aluthgama',
      'description': 'Check a faulty power outlet.',
      'phone': '0711234567',
    },
    {
      'name': 'Amal Fernando',
      'category': 'Electrician',
      'area': 'Bentota',
      'description': 'Install two new lights.',
      'phone': '0761234567',
    },
  ];

  void acceptRequest(int index) {
    final request = requests[index];

    setState(() {
      requests.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Request from ${request['name']} accepted.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Requests'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: requests.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No incoming requests',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                request['name']!,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Chip(
                              label: Text('Pending'),
                              backgroundColor: Color(0xFFFFE0B2),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _detail(
                          Icons.build,
                          request['category']!,
                        ),
                        _detail(
                          Icons.location_on,
                          request['area']!,
                        ),
                        _detail(
                          Icons.phone,
                          request['phone']!,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Service Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(request['description']!),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                acceptRequest(index),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Accept Request'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _detail(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
