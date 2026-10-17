import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'worker_profile_screen.dart'; // Import Worker Profile Screen
import 'package:oneclick/core/theme/app_theme.dart'; // UI only: Fresh Teal tokens

class WorkersListScreen extends StatelessWidget {
  final String categoryName;

  const WorkersListScreen({super.key, required this.categoryName});

  void _navigateToWorkerProfile(
      BuildContext context, Map<String, dynamic> workerData, String workerDocId) {
    final Map<String, dynamic> fullData = Map.from(workerData);
    fullData['id'] = workerDocId;
    fullData['category'] = categoryName;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkerProfileScreen(worker: fullData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$categoryName Experts'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Fetch Workers from 'workers' collection matching selected Category
        stream: FirebaseFirestore.instance
            .collection('workers')
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.6)),
                    const SizedBox(height: 12),
                    Text(
                      'No $categoryName experts available right now.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final workerDoc = docs[index];
              final worker = workerDoc.data();
              final name = worker['name'] ?? 'Expert Technician';
              final providerDetails =
                  worker['providerDetails'] as Map<String, dynamic>? ?? {};
              final experience =
                  providerDetails['experienceYears'] ?? '3+';
              final hourlyRate =
                  providerDetails['hourlyRate'] ?? worker['hourlyRate'] ?? '1500';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: () => _navigateToWorkerProfile(
                        context, worker, workerDoc.id),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textDark.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            child: const Icon(Icons.handyman_rounded,
                                color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Exp: $experience yrs • LKR $hourlyRate/hr',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
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