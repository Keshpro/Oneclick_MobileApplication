import 'package:flutter/material.dart';
import 'job_booking_screen.dart'; // Meka aniwaryayenma thiyenna one

class WorkerProfileScreen extends StatelessWidget {
  final Map<String, dynamic> worker;

  const WorkerProfileScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final name = worker['name']?.toString() ?? 'Worker';
    final isAvailable = worker['isAvailable'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: const Text('Professional Profile'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Rate',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    worker['rate'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff032744),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 45,
                width: 150,
                child: ElevatedButton(
                  onPressed: isAvailable
                      ? () {
                          // Dan meken JobBookingScreen ekata yanna puluwan
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobBookingScreen(worker: worker),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff032744),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Book Now', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xff032744).withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'W',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff032744),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? 'Available for work' : 'Currently Busy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(Icons.star, '${worker['rating'] ?? 0}', 'Rating', Colors.amber),
                      _buildStatItem(Icons.task_alt, '45+', 'Jobs Done', Colors.blue),
                      _buildStatItem(Icons.access_time, '5 Yrs', 'Experience', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'I am a highly skilled professional with over 5 years of experience in providing top-notch services. I ensure quality work, timely completion, and complete customer satisfaction. Feel free to book my service for any urgent repairs or installations.',
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Work',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.image, color: Colors.grey.shade400, size: 40),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'View All (${worker['reviews'] ?? 0})',
                        style: const TextStyle(
                          color: Color(0xff032744),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildReviewItem(
                    'Sunil Shantha',
                    'Great service! Arrived on time and fixed the issue quickly.',
                    5,
                  ),
                  const Divider(height: 30),
                  _buildReviewItem(
                    'Amal Perera',
                    'Very professional and clean work. Highly recommended.',
                    4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment, int stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 16,
                  color: index < stars ? Colors.amber : Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          comment,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}