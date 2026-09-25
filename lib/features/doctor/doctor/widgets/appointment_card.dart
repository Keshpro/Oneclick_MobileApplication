import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) =>
      const Card(child: ListTile(title: Text('Appointment')));
}
