import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'New Pending Account',
        'message': 'A new seller account is waiting for approval.',
      },
      {
        'title': 'Food Delivery Audit',
        'message': '5 food delivery requests need your attention.',
      },
      {
        'title': 'Grocery Audit',
        'message': '8 grocery items are waiting for approval.',
      },
      {
        'title': 'System Update',
        'message': 'System backup completed successfully.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.notifications),
              ),
              title: Text(
                notification['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                notification['message']!,
              ),
            ),
          );
        },
      ),
    );
  }
}