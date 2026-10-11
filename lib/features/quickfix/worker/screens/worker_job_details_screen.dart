import 'package:flutter/material.dart';

class WorkerJobDetailsScreen extends StatefulWidget {
  const WorkerJobDetailsScreen({super.key});

  @override
  State<WorkerJobDetailsScreen> createState() =>
      _WorkerJobDetailsScreenState();
}

class _WorkerJobDetailsScreenState
    extends State<WorkerJobDetailsScreen> {

  int currentStep = 1;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              'Electrical Repair',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text('Customer: Nimal Perera'),
            const Text('Location: Panadura'),
            const Text('Today • 10:00 AM'),

            const SizedBox(height: 30),

            const Text(
              'Job Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _step(
              1,
              'Request Accepted',
              currentStep >= 1,
            ),

            _step(
              2,
              'On The Way',
              currentStep >= 2,
            ),

            _step(
              3,
              'Service Started',
              currentStep >= 3,
            ),

            _step(
              4,
              'Service Completed',
              currentStep >= 4,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  if (currentStep < 4) {
                    setState(() {
                      currentStep++;
                    });
                  }

                },

                child: Text(
                  currentStep == 1
                      ? 'I\'m On The Way'
                      : currentStep == 2
                          ? 'Start Service'
                          : currentStep == 3
                              ? 'Complete Service'
                              : 'Completed',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(
    int number,
    String title,
    bool completed,
  ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Row(
        children: [

          CircleAvatar(
            radius: 15,

            child: completed
                ? const Icon(
                    Icons.check,
                    size: 18,
                  )
                : Text('$number'),
          ),

          const SizedBox(width: 15),

          Text(
            title,
            style: TextStyle(
              fontWeight: completed
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}