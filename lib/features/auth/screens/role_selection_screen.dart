import 'package:flutter/material.dart';
import '../../../shared/models/user_model.dart';
import 'register_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  void _selectRole(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(selectedRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('තෝරාගන්න (Role Selection)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ඔබගේ ගිණුම් වර්ගය තෝරන්න',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.medical_services),
              label: const Text('Doctor'),
              onPressed: () => _selectRole(context, UserRole.doctor),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Patient'),
              onPressed: () => _selectRole(context, UserRole.patient),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('Driver'),
              onPressed: () => _selectRole(context, UserRole.driver),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.airline_seat_recline_normal),
              label: const Text('Passenger'),
              onPressed: () => _selectRole(context, UserRole.passenger),
            ),
          ],
        ),
      ),
    );
  }
}