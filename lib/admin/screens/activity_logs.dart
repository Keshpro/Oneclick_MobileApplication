import 'package:flutter/material.dart';

class ActivityLogs extends StatelessWidget {
  const ActivityLogs({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = [
      'Admin approved a new user',
      'Admin rejected a food delivery',
      'Admin approved grocery item GR002',
      'User account blocked',
      'Doctor profile reviewed',
      'System settings updated',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Logs'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.history),
              ),
              title: Text(logs[index]),
              subtitle: const Text(
                'Today • Admin',
              ),
            ),
          );
        },
      ),
    );
  }
}