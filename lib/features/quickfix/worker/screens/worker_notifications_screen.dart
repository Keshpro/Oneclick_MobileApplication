import 'package:flutter/material.dart';

class WorkerNotificationsScreen extends StatelessWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),

      body: ListView(
        children: [

          _notification(
            Icons.assignment,
            'New Service Request',
            'Nimal requested an electrician.',
            '5 min ago',
          ),

          _notification(
            Icons.check_circle,
            'Request Accepted',
            'Your service request was accepted.',
            '1 hour ago',
          ),

          _notification(
            Icons.star,
            'New Review',
            'You received a 5-star rating.',
            'Yesterday',
          ),
        ],
      ),
    );
  }

  Widget _notification(
    IconData icon,
    String title,
    String message,
    String time,
  ) {
    return ListTile(

      leading: CircleAvatar(
        child: Icon(icon),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(message),

      trailing: Text(
        time,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
    );
  }
}