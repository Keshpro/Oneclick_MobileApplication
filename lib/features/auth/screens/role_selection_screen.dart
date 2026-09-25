import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import '../../../shared/models/user_model.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  void _goToRegister(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose your account type:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _roleTile(context, 'Doctor', Icons.medical_services, UserRole.doctor),
            _roleTile(context, 'Patient', Icons.person, UserRole.patient),
            _roleTile(context, 'Driver', Icons.directions_car, UserRole.driver),
            _roleTile(context, 'Passenger', Icons.airline_seat_recline_normal, UserRole.passenger),
          ],
        ),
      ),
    );
  }

  Widget _roleTile(BuildContext context, String title, IconData icon, UserRole role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _goToRegister(context, role),
      ),
    );
  }
}
=======

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Select role')));
}
>>>>>>> Stashed changes
