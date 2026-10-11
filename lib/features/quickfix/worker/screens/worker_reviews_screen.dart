import 'package:flutter/material.dart';

class WorkerReviewsScreen extends StatelessWidget {
  const WorkerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Center(
            child: Text(
              '⭐ 4.8',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Center(
            child: Text('126 Reviews'),
          ),

          const SizedBox(height: 25),

          _review(
            'Nimal Perera',
            'Very good service. Arrived on time.',
            5,
          ),

          _review(
            'Saman Silva',
            'Good work and professional.',
            5,
          ),

          _review(
            'Amal Fernando',
            'Service was good.',
            4,
          ),
        ],
      ),
    );
  }

  Widget _review(
    String name,
    String message,
    int rating,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text(message),
        trailing: Text('⭐ $rating'),
      ),
    );
  }
}