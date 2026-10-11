import 'package:flutter/material.dart';

class WorkerEarningsScreen extends StatelessWidget {
  const WorkerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Card(
              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  children: const [

                    Text(
                      'This Month',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Rs. 45,500',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text('28 Completed Jobs'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('Completed Jobs'),
              trailing: Text('28'),
            ),

            const ListTile(
              leading: Icon(Icons.pending),
              title: Text('Pending Payment'),
              trailing: Text('Rs. 5,000'),
            ),
          ],
        ),
      ),
    );
  }
}