
import 'package:flutter/material.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() =>
      _WorkerProfileScreenState();
}

class _WorkerProfileScreenState
    extends State<WorkerProfileScreen> {
  final nameController =
      TextEditingController(text: 'Kasun Perera');
  final usernameController =
      TextEditingController(text: 'worker10001');
  final phoneController =
      TextEditingController(text: '0771234567');
  final categoryController =
      TextEditingController(text: 'Electrician');
  final areaController =
      TextEditingController(text: 'Bentota');
  final experienceController =
      TextEditingController(text: '3');

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    categoryController.dispose();
    areaController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> editProfile() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameController, 'Full Name'),
                _field(usernameController, 'Username'),
                _field(phoneController, 'Phone Number'),
                _field(categoryController, 'Skill / Category'),
                _field(areaController, 'Service Area'),
                _field(
                  experienceController,
                  'Experience (years)',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated locally.'),
                  ),
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit),
            onPressed: editProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 52,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              nameController.text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '@${usernameController.text}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  '4.8 Rating',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.verified, color: Colors.blue),
                SizedBox(width: 4),
                Text('Worker'),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  _infoTile(
                    Icons.phone,
                    'Phone Number',
                    phoneController.text,
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    Icons.build,
                    'Skill / Category',
                    categoryController.text,
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    Icons.location_on,
                    'Service Area',
                    areaController.text,
                  ),
                  const Divider(height: 1),
                  _infoTile(
                    Icons.work_history,
                    'Experience',
                    '${experienceController.text} years',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Skills & Services',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(categoryController.text)),
                  const Chip(label: Text('Repair')),
                  const Chip(label: Text('Installation')),
                  const Chip(label: Text('Maintenance')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: editProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
