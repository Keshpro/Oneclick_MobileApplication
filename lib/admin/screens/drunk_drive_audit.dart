import 'package:flutter/material.dart';

class DrunkDriveAudit extends StatelessWidget {
  const DrunkDriveAudit({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = [
      {
        'driver': 'Kamal Silva',
        'vehicle': 'CAB-1234',
        'location': 'Colombo',
        'status': 'Pending',
      },
      {
        'driver': 'Nimal Perera',
        'vehicle': 'CAR-5678',
        'location': 'Kandy',
        'status': 'Reviewed',
      },
      {
        'driver': 'Amal Fernando',
        'vehicle': 'VAN-9988',
        'location': 'Galle',
        'status': 'Pending',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drunk Drive Audit'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.warning,
                  color: Colors.white,
                ),
              ),

              title: Text(
                report['driver']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Vehicle: ${report['vehicle']}\n'
                'Location: ${report['location']}\n'
                'Status: ${report['status']}',
              ),

              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}