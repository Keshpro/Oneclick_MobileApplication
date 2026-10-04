import 'package:flutter/material.dart';
import 'worker_profile_screen.dart'; // Profile screen eka import karanna
import 'job_booking_screen.dart';    // Booking screen eka import karanna

class WorkersListScreen extends StatelessWidget {
  final String categoryName;

  const WorkersListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Danata UI eka check karanna dapu dummy workers data
    final List<Map<String, dynamic>> workers = [
      {
        'name': 'Kamal Perera',
        'rating': 4.8,
        'reviews': 124,
        'distance': '2.5 km',
        'rate': 'Rs. 1500/hr',
        'isAvailable': true,
      },
      {
        'name': 'Nimal Silva',
        'rating': 4.5,
        'reviews': 89,
        'distance': '3.2 km',
        'rate': 'Rs. 1200/hr',
        'isAvailable': true,
      },
      {
        'name': 'Saman Kumara',
        'rating': 4.9,
        'reviews': 210,
        'distance': '5.0 km',
        'rate': 'Rs. 1800/hr',
        'isAvailable': false, // Meka false nisa hire button eka disable wenawa
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        title: Text('$categoryName Professionals'),
        backgroundColor: const Color(0xff032744),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter & Sort Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${workers.length} providers found nearby',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                ),
                Icon(Icons.filter_list, color: Colors.grey.shade700),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Workers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return _buildWorkerCard(context, worker);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, Map<String, dynamic> worker) {
    final bool isAvailable = worker['isAvailable'] == true;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Worker Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xff032744).withOpacity(0.1),
                  child: Text(
                    worker['name'].substring(0, 1),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff032744),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Worker Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            worker['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            worker['rate'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff032744),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${worker['rating']} (${worker['reviews']} reviews)',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey.shade500, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            worker['distance'],
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAvailable ? 'Available Now' : 'Busy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const Spacer(),
                
                // View Profile Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerProfileScreen(worker: worker),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff032744),
                    side: const BorderSide(color: Color(0xff032744)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('View Profile'),
                ),
                const SizedBox(width: 8),

                // Hire Button
                ElevatedButton(
                  onPressed: isAvailable 
                      ? () {
                          // Kelinma Job Booking Screen ekata yanawa
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Hire'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}