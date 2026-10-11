import 'package:flutter/material.dart';

class WorkerEditProfileScreen extends StatelessWidget {
  const WorkerEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Experience',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {},
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}