import 'package:flutter/material.dart';

class Category3Audit extends StatefulWidget {
  const Category3Audit({super.key});

  @override
  State<Category3Audit> createState() => _Category3AuditState();
}

class _Category3AuditState extends State<Category3Audit> {
  final List<Map<String, dynamic>> orders = [
    {
      'id': 'FD001',
      'customer': 'Amal Perera',
      'restaurant': 'Pizza House',
      'item': 'Chicken Pizza',
      'amount': 'Rs. 3500',
      'status': 'Pending',
    },
    {
      'id': 'FD002',
      'customer': 'Nimal Silva',
      'restaurant': 'Burger Point',
      'item': 'Cheese Burger',
      'amount': 'Rs. 1800',
      'status': 'Approved',
    },
    {
      'id': 'FD003',
      'customer': 'Kamal Fernando',
      'restaurant': 'Rice & Curry',
      'item': 'Rice & Chicken',
      'amount': 'Rs. 1500',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 3 - Food Delivery Audit'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.fastfood,
                        color: Colors.green,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Order ${order['id']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _status(order['status']),
                    ],
                  ),

                  const Divider(),

                  Text('Customer: ${order['customer']}'),
                  Text('Restaurant: ${order['restaurant']}'),
                  Text('Food: ${order['item']}'),
                  Text('Amount: ${order['amount']}'),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _reject(index);
                        },
                        child: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: () {
                          _approve(index);
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

  Widget _status(String status) {
    final bool approved = status == 'Approved';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: approved
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: approved ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _approve(int index) {
    setState(() {
      orders[index]['status'] = 'Approved';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food delivery approved'),
      ),
    );
  }

  void _reject(int index) {
    setState(() {
      orders[index]['status'] = 'Rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Food delivery rejected'),
      ),
    );
  }
}