import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkersListScreen extends StatelessWidget {
  final String categoryName;

  const WorkersListScreen({super.key, required this.categoryName});

  static const Color _navy = Color(0xFF1E293B);

  void _showBookingDialog(BuildContext context, Map<String, dynamic> workerData, String workerDocId) {
    final addressController = TextEditingController();
    final issueController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Book ${workerData['name'] ?? 'Worker'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: issueController,
                decoration: const InputDecoration(
                  labelText: 'Describe the Issue',
                  hintText: 'e.g., Water leakage in kitchen pipe',
                  prefixIcon: Icon(Icons.build_circle_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Your Address',
                  hintText: 'e.g., No 12, Main St, Colombo',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
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
            onPressed: () async {
              final issue = issueController.text.trim();
              final address = addressController.text.trim();

              if (issue.isNotEmpty && address.isNotEmpty) {
                try {
                  // Save Quick Fix Booking Request to 'work_appointments' collection
                  await FirebaseFirestore.instance.collection('work_appointments').add({
                    'category': categoryName,
                    'workerId': workerDocId,
                    'workerName': workerData['name'] ?? 'Technician',
                    'customerId': currentUser?.uid ?? '',
                    'customerEmail': currentUser?.email ?? 'Customer',
                    'issue': issue,
                    'address': address,
                    'status': 'Pending',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quick Fix Request Sent Successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to book: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('$categoryName Experts'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Fetch Workers from 'workers' collection matching selected Category
        stream: FirebaseFirestore.instance
            .collection('workers')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No $categoryName experts available right now.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final workerDoc = docs[index];
              final worker = workerDoc.data();
              final name = worker['name'] ?? 'Expert Technician';
              final providerDetails = worker['providerDetails'] as Map<String, dynamic>? ?? {};
              final experience = providerDetails['experienceYears'] ?? '3+ Years';
              final hourlyRate = providerDetails['hourlyRate'] ?? '1500';

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: _navy.withValues(alpha: 0.1),
                        child: const Icon(Icons.handyman_rounded, color: _navy, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Exp: $experience yrs • LKR $hourlyRate/hr',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showBookingDialog(context, worker, workerDoc.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Book'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}