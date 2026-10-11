import 'package:flutter/material.dart';

class WorkerAvailabilityScreen extends StatefulWidget {
  const WorkerAvailabilityScreen({super.key});

  @override
  State<WorkerAvailabilityScreen> createState() =>
      _WorkerAvailabilityScreenState();
}

class _WorkerAvailabilityScreenState
    extends State<WorkerAvailabilityScreen> {

  bool available = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          SwitchListTile(
            title: const Text('Available for Requests'),
            subtitle: Text(
              available
                  ? 'Customers can send requests'
                  : 'You are currently offline',
            ),
            value: available,
            onChanged: (value) {
              setState(() {
                available = value;
              });
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Working Areas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          CheckboxListTile(
            title: const Text('Panadura'),
            value: true,
            onChanged: (_) {},
          ),

          CheckboxListTile(
            title: const Text('Wadduwa'),
            value: true,
            onChanged: (_) {},
          ),

          CheckboxListTile(
            title: const Text('Kalutara'),
            value: false,
            onChanged: (_) {},
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {},
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}