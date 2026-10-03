import 'package:flutter/material.dart';

class FoodApplicationStatusScreen extends StatelessWidget {
  const FoodApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Status')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Status Icon
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 48,
                color: Colors.orange.shade700,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Application Submitted!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              'Thank you for applying to become a Oneclick Food Seller.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.pending_actions_rounded,
                    size: 35,
                    color: Colors.orange.shade700,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Under Review',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Our admin team will review your business information and documents before approving your seller account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Process
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Verification Process',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            _StatusStep(
              icon: Icons.check_circle_rounded,
              title: 'Application Submitted',
              description: 'Your seller application has been received.',
              completed: true,
            ),

            _StatusStep(
              icon: Icons.hourglass_top_rounded,
              title: 'Admin Review',
              description: 'Our team is reviewing your documents.',
              completed: false,
              current: true,
            ),

            _StatusStep(
              icon: Icons.verified_rounded,
              title: 'Seller Approval',
              description: 'You can start selling once approved.',
              completed: false,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Back to Food',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool completed;
  final bool current;

  const _StatusStep({
    required this.icon,
    required this.title,
    required this.description,
    this.completed = false,
    this.current = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 28,
            color: completed
                ? Colors.green
                : current
                ? Colors.orange
                : Colors.grey.shade400,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
