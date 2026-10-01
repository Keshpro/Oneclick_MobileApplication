import 'package:flutter/material.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD001',
      'customer': 'Customer 01',
      'total': 2450.00,
      'status': 'Pending',
    },
    {
      'id': 'ORD002',
      'customer': 'Customer 02',
      'total': 1800.00,
      'status': 'Processing',
    },
    {
      'id': 'ORD003',
      'customer': 'Customer 03',
      'total': 3200.00,
      'status': 'Completed',
    },
  ];

  void _changeStatus(int index, String status) {
    setState(() {
      _orders[index]['status'] = status;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Order status changed to $status')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order: ${order['id']}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Customer: ${order['customer']}'),
                  Text('Total: Rs. ${order['total'].toStringAsFixed(2)}'),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status: ${order['status']}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (status) {
                          _changeStatus(index, status);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'Pending',
                            child: Text('Pending'),
                          ),
                          PopupMenuItem(
                            value: 'Processing',
                            child: Text('Processing'),
                          ),
                          PopupMenuItem(
                            value: 'Completed',
                            child: Text('Completed'),
                          ),
                        ],
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
}
