import 'package:flutter/material.dart';

class Category4Audit extends StatefulWidget {
  const Category4Audit({super.key});

  @override
  State<Category4Audit> createState() => _Category4AuditState();
}

class _Category4AuditState extends State<Category4Audit> {
  final List<Map<String, dynamic>> items = [
    {
      'id': 'GR001',
      'seller': 'Fresh Mart',
      'item': 'Rice 5kg',
      'category': 'Grocery',
      'price': 'Rs. 1450',
      'status': 'Pending',
    },
    {
      'id': 'GR002',
      'seller': 'City Grocery',
      'item': 'Milk Powder',
      'category': 'Dairy',
      'price': 'Rs. 1250',
      'status': 'Approved',
    },
    {
      'id': 'GR003',
      'seller': 'Super Foods',
      'item': 'Sugar 1kg',
      'category': 'Grocery',
      'price': 'Rs. 320',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category 4 - Grocery Items Audit'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

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
                        Icons.shopping_cart,
                        color: Colors.purple,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Item ${item['id']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _status(item['status']),
                    ],
                  ),

                  const Divider(),

                  Text('Seller: ${item['seller']}'),
                  Text('Item: ${item['item']}'),
                  Text('Category: ${item['category']}'),
                  Text('Price: ${item['price']}'),

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
      items[index]['status'] = 'Approved';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grocery item approved'),
      ),
    );
  }

  void _reject(int index) {
    setState(() {
      items[index]['status'] = 'Rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Grocery item rejected'),
      ),
    );
  }
}