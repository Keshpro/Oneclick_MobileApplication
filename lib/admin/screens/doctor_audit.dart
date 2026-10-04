import 'package:flutter/material.dart';

class DoctorAudit extends StatelessWidget {
  const DoctorAudit({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = [
      {
        'name': 'Dr. Kasun Perera',
        'specialization': 'Cardiologist',
        'status': 'Pending',
      },
      {
        'name': 'Dr. Nimal Silva',
        'specialization': 'Dentist',
        'status': 'Approved',
      },
      {
        'name': 'Dr. Amal Fernando',
        'specialization': 'General Doctor',
        'status': 'Pending',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Audit'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.medical_services),
              ),

              title: Text(
                doctor['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                '${doctor['specialization']}\nStatus: ${doctor['status']}',
              ),

              isThreeLine: true,

              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}