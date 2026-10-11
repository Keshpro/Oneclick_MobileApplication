import 'package:flutter/material.dart';

import 'worker_request_details_screen.dart';

class WorkerRequestsScreen extends StatelessWidget {
  const WorkerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _request(
            context,
            'Electrical Repair',
            'Nimal Perera',
            'Panadura',
            '08 Oct • 10:00 AM',
          ),

          _request(
            context,
            'AC Repair',
            'Saman Silva',
            'Kalutara',
            '08 Oct • 02:00 PM',
          ),

          _request(
            context,
            'CCTV Installation',
            'Amal Fernando',
            'Wadduwa',
            '09 Oct • 09:00 AM',
          ),
        ],
      ),
    );
  }

  Widget _request(
    BuildContext context,
    String service,
    String customer,
    String location,
    String date,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                const CircleAvatar(
                  child: Icon(Icons.person),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        service,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      Text(customer),
                    ],
                  ),
                ),

                const Icon(Icons.pending),
              ],
            ),

            const SizedBox(height: 12),

            Text('📍 $location'),
            Text('📅 $date'),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const WorkerRequestDetailsScreen(),
                    ),
                  );

                },

                child: const Text('View Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}