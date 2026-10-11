import 'package:flutter/material.dart';

class WorkerRequestDetailsScreen extends StatelessWidget {
  const WorkerRequestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const CircleAvatar(
              radius: 35,
              child: Icon(
                Icons.person,
                size: 35,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Nimal Perera',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              'Customer',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const Divider(height: 35),

            _info(
              'Service',
              'Electrical Repair',
              Icons.build,
            ),

            _info(
              'Problem',
              'Kitchen light is not working',
              Icons.description,
            ),

            _info(
              'Location',
              'Panadura',
              Icons.location_on,
            ),

            _info(
              'Date',
              '08 October 2026',
              Icons.calendar_today,
            ),

            _info(
              'Time',
              '10:00 AM',
              Icons.access_time,
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Reject'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(icon, size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}